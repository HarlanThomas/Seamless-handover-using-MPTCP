%% Auto conceptor ESN 的代码实现
%  edited by haonan tong in 2019/12/18
%  added the input data as seq by thn in  2019/12/21
%  
% 
clear;
%% 随机序列的产生
x1 = 0.5 + 0.5 * cos(0.2*(1:1000));
x2 = 0.5 + 0.5 * sin(0.2 * (1:1000));
cyc = [x1 ; x2]';

u1= 0.05 * randn(1000,2);
u2= 0.5 * randn(1000,2);


u3 =[ ];
swithch_len = 100;
for i = 1:1000/swithch_len
    u3 (swithch_len*(i-1) +1 : swithch_len*(i-1) + swithch_len/2 , :) = u2(swithch_len*(i-1) +1 : swithch_len*(i-1) + swithch_len/2, :);
    u3 (swithch_len*(i-1) +swithch_len/2 +1 : swithch_len*i , :) = u1(swithch_len*(i-1) +swithch_len/2 +1 : swithch_len*i , :);
end
u_allpattern = {cyc; u3};
%%  将输入数据进行 堆砌    四个数据对应一个数据输出                
n_old = 4;
uu =zeros(2,995,8);  yy = zeros(2,995,2);
% uu = { }; yy = { };
for i = 1 : size (u_allpattern, 1)
    %  分别取出 两种模式 排成一列
    in_data = [ ];
    label_data = [ ];
    u = cell2mat(u_allpattern(i));  % 读取一种模式
    for j = 1: size(u,1) - (n_old + 1)
        in_data = [in_data ; 
                        reshape( u( j : j + n_old - 1,:) ,[1,8])   ];
        label_data = [label_data ;
                                u(j + n_old, :)];
    end
%     uu = {uu; in_data};
%     yy = {yy; in_data};
    uu(i,:,:) =  in_data ;
    yy(i,:,:) =  label_data ;
end

%% 
time  = 1:1000;
% figure;
% plot(time,u1,time,u3);
NpLoad  = 2;

%% ESN 的初始配置
N = 200; SR = 1.5;
WinScaling = 1.5;       % scaling of pattern feeding weights
biasScaling = 0.5;   
    if N <= 20
        Cconnectivity = 1;
    else
        Cconnectivity = 10/N;
    end
    WRaw = generate_internal_weights(N, Cconnectivity);
    u_temp = squeeze(uu(1,:,:));
    y_temp =  squeeze(yy(1,:,:));
    dim_in = size(u_temp(1,:),2);
    dim_out = size(y_temp, 2);
    WinRaw = randn(N, dim_in);
    biasRaw = randn(N, 1);
W = SR * WRaw;
Win = WinScaling * WinRaw;
bias = biasScaling * biasRaw;
% 有关 时期的限定 
trainWashoutLength = 100;
learnWLength = 500;
allTrainArgs = zeros(N, NpLoad * learnWLength);
allTrainYTargs = zeros(dim_out, NpLoad * learnWLength);
all_predict = zeros(dim_out, NpLoad * learnWLength);
% pTemplates = zeros(measureTemplateLength, NpLoad);

for p = 1 
            XCue = zeros(N,learnWLength);   
            XOldCue = zeros(N,learnWLength);
%             pTemplate = zeros(learnWLength,dim_in);
            
            x = zeros(N, 1);   % 状态 初始化

%         u = cell2mat(u_allpattern(p));  % 读取一种模式
            u = squeeze( uu(p,:,:) );  
            y = squeeze(  yy(p,:,:) );            
%% ESN的 washout
            for n = 1:trainWashoutLength
                u_n = u(n,:);
                x =  tanh(W * x + Win * u_n' + bias);
            end
            for n = 1: learnWLength
                u_n = u(n + trainWashoutLength, :);
                out = y(n,:);
                XOldCue(:,n) = x;   % 历史的 训练数据  做保存（X（n））
                x = tanh(W * x + Win * u_n' + bias);   % 继续传值 
                XCue(:,n) = x;   % cue 阶段的数据集   当下的    X(n+1)
                pTemplate(n,:) = u_n;  % 动力学模型的缓冲？  输入的保存
                Predict(n, :) = out;
            end
            
            
%%              所有模式的输入进行缓存 
%             pTemplates(:,p) = pTemplate(end-measureTemplateLength+1:end);
            allTrainArgs(:, (p-1)*learnWLength+1:p*learnWLength) = ...                  % 200*5k  （神经元数目*模式*训练长度）
            XCue;
            allTrainOldArgs(:, (p-1)*learnWLength+1:p*learnWLength) = ...
            XOldCue;
            allTrainDTargs(:, (p-1)*learnWLength+1:p*learnWLength) = ...            % 所有的数据是 200* 5k    状态的缓存 叫做 DT
            Win * pTemplate';                       %    将来的下一响应
            allTrainYTargs(:, (p-1)*learnWLength+1:p*learnWLength) = ...            % 训练使用的标签 1*5k
            Predict';
end

TychonovAlphaD = .001;
%%% pattern readout learning
TychonovAlphaWout = 0.01;
I = eye(N);  % 储备池节点数

D = (inv(allTrainOldArgs * allTrainOldArgs' + TychonovAlphaD * I) ...    % D矩阵的 参数
        * allTrainOldArgs * allTrainDTargs')';
    NRMSED = mean(nrmse(allTrainDTargs, D * allTrainOldArgs));      % 矩阵D的NRMSE 
%% compute mean variance of x
varx = mean(var(allTrainArgs'));
%% cmpute Wout
Wout = (inv(allTrainArgs * allTrainArgs' + TychonovAlphaWout * I) ...       % 岭回归
    * allTrainArgs * allTrainYTargs')';             
NRMSEWout =  sum( nrmse(allTrainYTargs, Wout * allTrainArgs) ) / dim_out ;
fprintf('NRMSE   Wout = %0.2g  D = %0.2g \n ', NRMSEWout, NRMSED);   

%% 得到 D Wout 矩阵之后
%% ESN的 Cue 过程 
NpTest = NpLoad;
NpTestEff = NpLoad;
SNRTests = [1];  


measureWashout = 50;
measureTemplateLength = 20;
measureRL = 100; % runlength for measuring output NRMSE.
CadaptRateCue = 0.01;
aperture = 1000;
initialWashout = 100;
cueLength = 100;
cueNL = 0.0;
    
yTest_PL_cue = zeros(measureRL, NpTest, dim_out);  %  （检测的长度，检测的模式数，序列的列数+1）
yTest_PL_recall = zeros(measureRL, NpTest, dim_out);
SV_PL = zeros(N,NpTest, size(SNRTests,2)+1);
    
for p = 1
    % C learning and testing
        x = zeros(N,1);
%         u = cell2mat(u_allpattern(p));  % 读取一种模式
           % washout 
        u = squeeze( uu(p,:,:) );
        y = squeeze( yy(p,:,:) );
        for n = 1:initialWashout
            u_n = u(n,:);
            x =  tanh(W * x + Win * u_n' + bias);
        end
        % compute C 
        C = zeros(N,N);
        SNRCue = Inf;
        b = sqrt(varx /  SNRCue);   
        %% b）cue 过程 
        figure()
        tmp = [ ];
        for n = 1:cueLength
            u_n  = u(n + initialWashout , :) ;
            x =  tanh(W * x + Win * u_n' + bias ) + b * randn(N,1);
            C = C + CadaptRateCue * ((x - C*x)*x' - aperture^(-2)*C);
            tmp  = [tmp; u_n];
        end
            t = 100:200;
        plot(label_data(t,1)', label_data(t,2)', '-*'); hold on;   % 原始信号
        
        [U S V] = svd(C);             % C奇异值分解
        SV_PL(:,p,1) = diag(S);    % C的特征值    
         
        
%%  b)   cue 阶段
        xBeforeMeasure = x;   % 先 C cue 训完保存起来

        for n = 1 : measureWashout
               x = C * tanh(W *  x + D * x + bias);
        end
%         t = 1:200;
%         plot (t, x); hold on;r
        tmp = [  ];        
        for n = 1:measureRL   % runlen
                r = tanh(W *  x + D * x + bias);
                x = C * r;
                yTest_PL_cue(n,p,:) = Wout * r;  % 测量回声中的输出。。。用r？
        end
        time_bias = initialWashout + cueLength;
        t = cueLength + 1 +initialWashout : cueLength + measureRL + initialWashout;
%         plot( t , yTest_PL(:,p,1),'-+');
        plot(yTest_PL_cue(1:10,p,1)', yTest_PL_cue(1:10,p,2)', '-+m'); hold on;   % 原始信号
        plot(yTest_PL_cue(10:end,p,1)', yTest_PL_cue(10:end,p,2)', '-+r' ); hold on;   % 原始信号


        x = xBeforeMeasure;  % x 又回去了

      %% Autoconcetptor
        RLs = [1];  % recall 的次数应该和 周期紧密  相关

      for i = 1:size(RLs,2)
            % state and noise scaling factors a and b
            b = sqrt(varx /  SNRTests(i));      % 噪声系数
            RL = RLs(i);      % runlen
            CadaptRateAfterCue = 0.01; % C adaptation rate

            
            [U S V] = svd(C);
            SV_PL(:,p,i+1) = diag(S);

            xBeforeMeasure = x;
            for n = 1:measureWashout
                x = C * tanh(W *  x + D * x + bias);
            end
            tmp=[  ];
            for n = 1:measureRL
                u_n = u(n + initialWashout +cueLength -1,: );
                r = tanh(W *  x +  Win * u_n' + bias);
%                 r = tanh(W *  x + D * x + bias);
                x = C * r;
                yTest_PL_recall(n,p,:) = Wout * r;   % 存在了第2 深度
                 for nn = 1:RL
                        x = C * (tanh(W *  x + D * x + bias )+ b*randn(N,1));
                        C = C + CadaptRateAfterCue * ((x - C*x)*x' - aperture^(-2)*C);
%                         x = a * x + b * randn(N,1);
                 end
                tmp = [tmp;   y(n + initialWashout +cueLength -1,:) ];
            end
            
            plot(yTest_PL_recall(:,p,1)', yTest_PL_recall(:,p,2)', '--g', 'linewidth', 1); hold on;   
%             plot(t, yTest_PL_recall( :, p, :), '--', 'linewidth', 1);   hold on;
           plot( tmp(:,1)',  tmp(:,2)', 'o-m'  );    hold on;
            x = xBeforeMeasure;
            title( ['Autoconceptor  RL = ', num2str(RL) ]);
      end
end

%% test 
