clear;
load('data1.mat');
NpLoad  = 3;

%% ESN 的初始配置
N = 32; SR = 1.5;
WinScaling = 1.5;       % scaling of pattern feeding weights
biasScaling = 0.5;   
        if N <= 20
            Cconnectivity = 1;
        else
            Cconnectivity = 10/N;
        end
%         WRaw = generate_internal_weights(N, Cconnectivity);
        WRaw = generate_cycle_weights(N,Cconnectivity);
        u_temp = squeeze(input_seq(1));
        y_temp =  squeeze(output_seq(1));
        dim_in = size(cell2mat(u_temp(1,:)),2);
        dim_out = size(cell2mat(y_temp(1,:)), 2);
        WinRaw = randn(N, dim_in)  ;
        biasRaw = randn(N, 1) ;
W = SR * WRaw;
Win = WinScaling * WinRaw;
bias = biasScaling * biasRaw;
% 有关 时期的限定 
trainWashoutLength = 60;
learnWLength = 3400;
allTrainArgs = zeros(N, NpLoad * learnWLength);
allTrainYTargs = zeros(dim_out, NpLoad * learnWLength);
all_predict = zeros(dim_out, NpLoad * learnWLength);

all_mp_prediction = zeros(2, NpLoad * learnWLength);
%  pTemplates = zeros(measureTemplateLength, NpLoad);
all_train =0;
Input = zeros(dim_in, NpLoad * learnWLength);

% 训练阶段
for p =   1:2
            figure ()
            XCue = zeros(N,learnWLength);   
            XOldCue = zeros(N,learnWLength);
%             pTemplate = zeros(learnWLength,dim_in);
            x = zeros(N, 1);   % 状态 初始化

%         u = cell2mat(u_allpattern(p));  % 读取一种模式
            u = cell2mat(squeeze( input_seq(p) ));  
            y = cell2mat(squeeze( output_seq(p) ));       
            
            all_train = floor(0.5 * size(y,1)) ;
            a = randi ([1, all_train]);
            switch p 
                case 1 
                    a = 0;
%                     learnWLength = 3400;
                case 2
                    a = 0;
%                     learnWLength = 19000;
                case 3
                    a = 60000;
%                     learnWLength = 3000;
            end
%             a = 0;
            fprintf('Train Wout stage, a= %i \n', a);   

%% ESN的 washout
            for n = 1:trainWashoutLength
                u_n = u( a+ n ,:);
                x =  tanh(W * x + Win * u_n' + bias);
            end
            
            for n = 1: learnWLength
                 if  p == 2    
                        p_mp(n, : ) =  [1, 0];
                 else
                        p_mp(n, : ) = [0, 1];
                end    
                u_n = u(n+ trainWashoutLength + a, :);
                out = y(n+ trainWashoutLength + a ,:);
                XOldCue(:,n) = x;   % 历史的 训练数据  做保存（X（n））
                x = tanh(W * x + Win * u_n' + bias);   % 继续传值 
                XCue(:,n) = x;   % cue 阶段的数据集   当下的    X(n+1)
                pTemplate( n , : ) = u_n;  % 动力学模型的缓冲？  输入的保存
                Predict(n, :) = out;
                
                
            end
            plot(pTemplate( : ,4)', pTemplate( : , 8)', '-+b'); hold on;   % 原始信号
            plot(Predict( : , 1)', Predict( : , 2)', 'o-m' );               hold on;   % 原始信号
            
%%              所有模式的输入进行缓存 
%             pTemplates(:,p) = pTemplate(end-measureTemplateLength+1:end);
            Input(:,(p-1)*learnWLength+1:p*learnWLength) = pTemplate';
            allTrainArgs(:, (p-1)*learnWLength+1:p*learnWLength) = ...                  % 200*5k  （神经元数目*模式*训练长度）
            XCue;
            allTrainOldArgs(:, (p-1)*learnWLength+1:p*learnWLength) = ...
            XOldCue;
            allTrainDTargs(:, (p-1)*learnWLength+1:p*learnWLength) = ...            % 所有的数据是 200* 5k    状态的缓存 叫做 DT
            Win * pTemplate';                       %    将来的下一响应
            allTrainYTargs(:, (p-1)*learnWLength+1:p*learnWLength) = ...            % 训练使用的标签 1*5k
            Predict';
            all_mp_prediction(:, (p-1)*learnWLength+1:p*learnWLength) = ...
                p_mp';
end

TychonovAlphaD = .001;
%%% pattern readout learning
TychonovAlphaWout = 0.01;
TychonovAlphaW_mpout = 0.01;
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
W_mpout = (inv(allTrainArgs * allTrainArgs' + TychonovAlphaW_mpout * I) ...       % 岭回归
    * allTrainArgs *all_mp_prediction' )';  
NRMSEW_mpout =  sum( nrmse(all_mp_prediction, W_mpout * allTrainArgs) )  /1  ;
fprintf('NRMSE   Wout = %.4g W_mpout = %.4g D = %.4g  \n ', NRMSEWout, NRMSEW_mpout, NRMSED);   
% 
 load('C_pp.mat');
% % load('')

P_pp = W_mpout  *  allTrainArgs;
P_pp = reshape(P_pp, [ ], learnWLength);
positive_train = P_pp( 1:2, :);
negative_train  = P_pp( 3:4, :);
 mv_rate =  sum( ( (positive_train(1,:) - positive_train(2, :) )< 0) ) / learnWLength
 pp_rate = sum( ( (negative_train(1,:) - negative_train(2,:) ) > 0) ) / learnWLength
save('weight_mix','D','Wout', 'W_mpout','Win','W','bias',  'allTrainArgs', 'learnWLength');
