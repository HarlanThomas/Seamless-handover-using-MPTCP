%% Auto conceptor ESN 的代码实现
%  edited by haonan tong in 2019/12/18
%  added the input data as seq by thn in  2019/12/21 named thn_8_input_seq
%  added the user trajectory data by thn in 2019/12/22 named thn_seq8_infer
% 
% 
% % 
clear;
% %  从文件夹中读取数据
% 
Path_mv = './mv_more_400/' ;                    % 设置数据存放的文件夹路径
Path_pp = './pp_less_50/' ; 
Path_tot = './data/cooked_trajectory_less_2k/' ;
File1 = dir(fullfile(Path_mv,'*.txt'));  % 显示文件夹下所有符合后缀名为.txt文件的完整信息
File2 = dir(fullfile(Path_pp,'*.txt'));
File3 = dir(fullfile(Path_tot,'*.txt'));
FileNames = {};
FileNames1 = {File1.name}' ;            % 提取符合后缀名为.txt的所有文件的文件名，转换为n行1列
FileNames2 = {File2.name}' ;
FileNames3 = {File3.name}' ;
num_files =  [ ];
num_files(1) = size(FileNames1,1);
num_files(2) = size(FileNames2,1);
num_files(3) = size(FileNames3,1);
%%   所有数据排成一个矩阵
input_seq =cell(3,1);
output_seq =cell(3,1);

for i =1: 3
    n_old = 4;
    in_tmp = [ ];
    out_tmp = [ ];
        for file = 1 : num_files(i)
                switch i 
                    case 1
                        trace_data = load(cell2mat([Path_mv, FileNames1(file)]));
                    case 2
                        trace_data = load(cell2mat([Path_pp, FileNames2(file)]));
                    case 3
                        trace_tmp = load(cell2mat([Path_tot,FileNames3(file)]));    % 去除时间列
                        trace_data = trace_tmp(:,2:3);
                end
                seq_len = size(trace_data,1) ;   
               %% 一个文件
                for j = 1: seq_len - (n_old + 1)
                    in_tmp = [in_tmp ; 
                                    reshape( trace_data( j : j + n_old - 1,:) ,[1,8])   ];
                    out_tmp = [out_tmp ;
                                            trace_data(j + n_old, :)];
                end
        %     [input_seq_temp,output_seq_temp,~]=generate_sequence(seq_len,trace_data);
        %     input_seq = [input_seq, input_seq_temp];
        %     output_seq = [output_seq, output_seq_temp];
        end
         in_tmp(:, 1:4 ) = (in_tmp(:, 1:4 ) + 2000 ) / 4000;  in_tmp(:, 5:8 ) = (in_tmp(:, 5:8 ) + 1000 ) / 4000;
         out_tmp (:, 1) = (out_tmp (:, 1)+ 2000 ) / 4000;  out_tmp (:, 2) = (out_tmp (:, 2)+ 1000 ) / 4000;
         input_seq{i} = in_tmp  ;                     % 归一化矩阵  
         output_seq{i} = out_tmp;                 % 归一化矩阵
end
save('data3.mat', 'input_seq','output_seq');

%%  加载已经保存的数据
load('data1.mat');


%%  从所有的数据中进行分割，分出训练数据与测试数据  28 定律
% 
% trainLength = floor(size(input_seq,2) * 1)
% % testLength = floor(size(input_seq,2) / 10)
% %%%% generate an esn 
% nInputUnits = 2*Ns; nInternalUnits = 32; nOutputUnits = 2*Nt; 

%% 随机序列的产生
% u1= 0.05 * randn(1000,2);
% u2= 0.5 * randn(1000,2);
% u3 =[ ];
% swithch_len = 100;
% for i = 1:1000/swithch_len
%     u3 (swithch_len*(i-1) +1 : swithch_len*(i-1) + swithch_len/2 , :) = u2(swithch_len*(i-1) +1 : swithch_len*(i-1) + swithch_len/2, :);
%     u3 (swithch_len*(i-1) +swithch_len/2 +1 : swithch_len*i , :) = u1(swithch_len*(i-1) +swithch_len/2 +1 : swithch_len*i , :);
% end
% u_allpattern = {u1; u3};

%%  将输入数据进行 堆砌    四个数据对应一个数据输出                
% 
% n_old = 4;
% uu =zeros(2,995,8);  yy = zeros(2,995,2);
% % uu = { }; yy = { };
% for i = 1 : size (u_allpattern, 1)
%     %  分别取出 两种模式 排成一列
%     in_data = [ ];
%     label_data = [ ];
%     u = cell2mat(u_allpattern(i));  % 读取一种模式
%     for j = 1: size(u,1) - (n_old + 1)
%         in_data = [in_data ; 
%                         reshape( u( j : j + n_old - 1,:) ,[1,8])   ];
%         label_data = [label_data ;
%                                 u(j + n_old, :)];
%     end
% %     uu = {uu; in_data};
% %     yy = {yy; in_data};
%     uu(i,:,:) =  in_data ;
%     yy(i,:,:) =  label_data ;
% end


%%    模型部分
time  = 1:1000;
% figure;
% plot(time,u1,time,u3);
NpLoad  = 2;

%% ESN 的初始配置
N = 156; SR = 1.5;
WinScaling = 1.5;       % scaling of pattern feeding weights
biasScaling = 0.5;   
    if N <= 20
        Cconnectivity = 1;
    else
        Cconnectivity = 10/N;
    end
    WRaw = generate_internal_weights(N, Cconnectivity);
    u_temp = squeeze(input_seq(1));
    y_temp =  squeeze(output_seq(1));
    dim_in = size(cell2mat(u_temp(1,:)),2);
    dim_out = size(cell2mat(y_temp(1,:)), 2);
    WinRaw = randn(N, dim_in);
    biasRaw = randn(N, 1);
W = SR * WRaw;
Win = WinScaling * WinRaw;
bias = biasScaling * biasRaw;
bias = 0;
% 有关 时期的限定 
trainWashoutLength = 60;
learnWLength = 3450;
allTrainArgs = zeros(N, NpLoad * learnWLength);
allTrainYTargs = zeros(dim_out, NpLoad * learnWLength);
all_predict = zeros(dim_out, NpLoad * learnWLength);
% pTemplates = zeros(measureTemplateLength, NpLoad);
all_train =0;
    %% 训练阶段
for p =  1 : 2
        figure ()
            XCue = zeros(N,learnWLength);   
            XOldCue = zeros(N,learnWLength);
%             pTemplate = zeros(learnWLength,dim_in);
            x = zeros(N, 1);   % 状态 初始化

%         u = cell2mat(u_allpattern(p));  % 读取一种模式
            u = cell2mat(squeeze( input_seq(p) ));  
            y = cell2mat(squeeze(  output_seq(p) ));       
            
            all_train = floor(0.5 * size(y,1)) ;
            a = randi ([1, all_train]);
            a = 0;
            fprintf('cue stage, a= %i \n', a);   

%% ESN的 washout
            for n = 1:trainWashoutLength
                u_n = u( a+ n ,:);
                x =  tanh(W * x + Win * u_n' + bias);
            end
            
            
            for n = 1: learnWLength
                u_n = u(n+ trainWashoutLength + a, :);
                out = y(n+ trainWashoutLength + a ,:);
                XOldCue(:,n) = x;   % 历史的 训练数据  做保存（X（n））
                x = tanh(W * x + Win * u_n' + bias);   % 继续传值 
                XCue(:,n) = x;   % cue 阶段的数据集   当下的    X(n+1)
                pTemplate( n , : ) = u_n;  % 动力学模型的缓冲？  输入的保存
                Predict(n, :) = out;
            end
            
            plot(pTemplate( : ,4)', pTemplate( : , 8)', '-+b'); hold on;   % 原始信号
            plot(Predict( : , 1)', Predict( : , 2)', 'o-m' ); hold on;   % 原始信号
            
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

% save('weight_mix','D','Wout','Win','W');


%% 得到 D Wout 矩阵之后x
%% ESN的 Cue 过程 
NpTest = NpLoad;
NpTestEff = 3;   % 加入  单个用户的 多模序列
SNRTests = [1];  
measureWashout = 30;
measureTemplateLength = 20;
measureRL = 60; % runlength for measuring output NRMSE.
CadaptRateCue = 0.01;
aperture = 100000;
initialWashout = 60;
cueLength = 100;
cueNL = 0.0;
    
yTest_PL_cue = zeros(measureRL, NpTest, dim_out);  %  （检测的长度，检测的模式数，序列的列数+1）
yTest_PL_recall = zeros(measureRL, NpTest, dim_out);
SV_PL = zeros(N,NpTest, size(SNRTests,2)+1);
%     
%  load('weight_mv.mat');
%  C_mv = C;  Wout_mv = Wout;
%  load('weight_pp.mat');
%  C_pp = C;   Wout_pp = Wout;
%  load('weight_mix.mat');
%  C_mix = C; Wout_mix = Wout;

for p = 1:NpTestEff
    % C learning and testing
%         switch p
%             case 1
%                  load('weight_mv.mat');
%             case 2
%                 load('weight_pp.mat');
%             case 3
%                 load('weight_mix.mat');
%         end
        x = zeros(N,1);
%         u = cell2mat(u_allpattern(p));  % 读取一种模式
           % washout 
         u = cell2mat(squeeze( input_seq(p) ));  
         y = cell2mat(squeeze(  output_seq(p) ));    
         all_train = floor(0.8 * size(y,1)) ;
         
         a = randi ([ floor(0.7 * all_train), floor(1.1 * all_train )]);
         fprintf('cue stage, a= %i \n', a);   
         
        for n = 1:initialWashout
            u_n = u(n + a,:);
            x =  tanh(W * x + Win * u_n' + bias);
        end
        % compute C 
        C = zeros(N,N);
        SNRCue = Inf;
%         b = sqrt(varx /  SNRCue);   
        b = 0;
        
         

        %% b）cue 过程 
%         figure()
        tmp = [ ];
        for n = 1:cueLength
            u_n  = u(n + initialWashout +a , :) ;
            x =  tanh(W * x + Win * u_n' + bias ) + b * randn(N,1);
            C = C + CadaptRateCue * ((x - C*x)*x' - aperture^(-2)*C);
            tmp  = [tmp; u_n];
        end
            t = 1:100;
%         plot(label_data(t,1)', label_data(t,2)', '-*'); hold on;   % 原始信号
        
        [U S V] = svd(C);             % C奇异值分解
        SV_PL(:,p,1) = diag(S);    % C的特征值    
        
         
        
        
        
%%  b)   cue 阶段
        xBeforeMeasure = x;   % 先 C cue 训完保存起来

%         for n = 1 : measureWashout
%                x = C * tanh(W *  x + D * x + bias);
%         end
%         t = 1:200;
%         plot (t, x); hold on;r
        tmp = [  ];         
        for n = 1:measureRL   % runlen
                r = tanh(W *  x + D * x + bias);
                x = C * r;
                yTest_PL_cue(n,p,:) = Wout * x;  % 测量回声中的输出。。。用r？
        end
        time_bias = initialWashout + cueLength;
        t = cueLength + 1 +initialWashout : cueLength + measureRL + initialWashout;
% %         plot( t , yTest_PL(:,p,1),'-+');
%         plot(yTest_PL_cue(1:10,p,1)', yTest_PL_cue(1:10,p,2)', '-+m'); hold on;   % 原始信号
%         plot(yTest_PL_cue(10:end,p,1)', yTest_PL_cue(10:end,p,2)', '-+r' ); hold on;   % 原始信号
        C_cue = C;

        x = xBeforeMeasure;  % x 又回去了
        
      %% Autoconcetptor
        RLs = [0];  % recall 的次数应该和 周期紧密  相关

      for i = 1:size(RLs,2)
            figure();
            % state and noise scaling factors a and b
            b =1;
%             b = sqrt(varx /  SNRTests(i));      % 噪声系数
            RL = RLs(i);      % runlen
            CadaptRateAfterCue = 0.01; % C adaptation rate

            
            [U S V] = svd(C);
            SV_PL(:,p,i+1) = diag(S);

            xBeforeMeasure = x;
%             for n = 1:measureWashout
%                 x = C * tanh(W *  x + D * x + bias);
%             end
            tmp=[  ];
            if  p == 3
                measureRL = 10000;        % 多模式时候，多测
            end
                            %% 原版的Autoconceptor
%             for n = 1:measureRL
%                 u_n = u(n + initialWashout +cueLength -1,: );
%                 r = tanh(W *  x +  Win * u_n' + bias);
% %                 r = tanh(W *  x + D * x + bias);
%                 x = C * r;
%                 yTest_PL_recall(n,p,:) = Wout * r;   % 存在了第2 深度
%                  for nn = 1:RL
%                         x = C * (tanh(W *  x + D * x + bias )+ b*randn(N,1));
%                         C = C + CadaptRateAfterCue * ((x - C*x)*x' - aperture^(-2)*C);
% %                         x = a * x + b * randn(N,1);
%                  end
%                 tmp = [tmp;   y(n + initialWashout +cueLength -1 + a,:) ];
%             end
                                %%  自己的
            for n = 1:measureRL
                u_n = u(n + initialWashout +cueLength -1 + a,: );
                x = tanh(W *  x +  Win * u_n' + bias);
                 
                r = tanh(W *  x + D * x + bias);
                if (p ==3) 
                    if (r' * C_mv * r) > (r' * C_pp * r)
                         x = C_mv* r;
                    else
                        x = C_pp* r;
                    end
                else
                    x = C * r;
                end
%                 r = tanh(W *  x + D * x + bias);
%                 for nn = 1 : RL
%                     C = C + CadaptRateCue * ((x - C*x)*x' - aperture^(-2)*C);
%                      x = C * x;
%                 end
                yTest_PL_recall(n,p,:) = Wout * x;   % 存在了第2 深度
%                  for nn = 1:RL
%                         x = C * (tanh(W *  x + D * x + bias )+ b*randn(N,1));
%                         C = C + CadaptRateAfterCue * ((x - C*x)*x' - aperture^(-2)*C);
% %                         x = a * x + b * randn(N,1);
%                  end
                tmp = [tmp;   y(n + initialWashout +cueLength -1 + a,:) ];
                
            end
            C_auto = C;
            C_d = C_auto - C_cue;
            plot(yTest_PL_recall(:,p,1)', yTest_PL_recall(:,p,2)', 'o-g', 'linewidth', 1); hold on;   
%             plot(t, yTest_PL_recall( :, p, :), '--', 'linewidth', 1);   hold on;
           plot( tmp(:,1)',  tmp(:,2)', 'o-m'  );    hold on;
                nrmsex = mean(nrmse( yTest_PL_recall(:,p,1)' , tmp(:,1)' ));
                nrmsey = mean(nrmse( yTest_PL_recall(:,p,2)' , tmp(:,2)' ));
                nrmse_ = mean([ nrmsex nrmsey ]);
                fprintf(' autoconceptor nrmse= %.4g ， pattern = % i \n ', nrmse_,  p);
            x = xBeforeMeasure;
            title( ['Autoconceptor  RL = ', num2str(RL) ]);
            figure();
                subplot(1,3,1); imshow(C_cue * 100);
                subplot(1,3,2); imshow(C_auto * 100);
                subplot(1,3,3); imshow(C_d * 1000);
%            if p ==3
%                figure();
%                 subplot(1,3,p); imshow();
%                 subplot(1,3,p); imshow();
%                 subplot(1,3,p); imshow();
%            end
                
      end
      
end

%% test 
