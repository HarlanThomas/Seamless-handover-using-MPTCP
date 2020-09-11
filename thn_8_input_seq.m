%% Auto conceptor ESN �Ĵ���ʵ��
%  edited by haonan tong in 2019/12/18
%  added the input data as seq by thn in  2019/12/21
%  
% 
clear;
%% ������еĲ���
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
%%  ���������ݽ��� ����    �ĸ����ݶ�Ӧһ���������                
n_old = 4;
uu =zeros(2,995,8);  yy = zeros(2,995,2);
% uu = { }; yy = { };
for i = 1 : size (u_allpattern, 1)
    %  �ֱ�ȡ�� ����ģʽ �ų�һ��
    in_data = [ ];
    label_data = [ ];
    u = cell2mat(u_allpattern(i));  % ��ȡһ��ģʽ
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

%% ESN �ĳ�ʼ����
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
% �й� ʱ�ڵ��޶� 
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
            
            x = zeros(N, 1);   % ״̬ ��ʼ��

%         u = cell2mat(u_allpattern(p));  % ��ȡһ��ģʽ
            u = squeeze( uu(p,:,:) );  
            y = squeeze(  yy(p,:,:) );            
%% ESN�� washout
            for n = 1:trainWashoutLength
                u_n = u(n,:);
                x =  tanh(W * x + Win * u_n' + bias);
            end
            for n = 1: learnWLength
                u_n = u(n + trainWashoutLength, :);
                out = y(n,:);
                XOldCue(:,n) = x;   % ��ʷ�� ѵ������  �����棨X��n����
                x = tanh(W * x + Win * u_n' + bias);   % ������ֵ 
                XCue(:,n) = x;   % cue �׶ε����ݼ�   ���µ�    X(n+1)
                pTemplate(n,:) = u_n;  % ����ѧģ�͵Ļ��壿  ����ı���
                Predict(n, :) = out;
            end
            
            
%%              ����ģʽ��������л��� 
%             pTemplates(:,p) = pTemplate(end-measureTemplateLength+1:end);
            allTrainArgs(:, (p-1)*learnWLength+1:p*learnWLength) = ...                  % 200*5k  ����Ԫ��Ŀ*ģʽ*ѵ�����ȣ�
            XCue;
            allTrainOldArgs(:, (p-1)*learnWLength+1:p*learnWLength) = ...
            XOldCue;
            allTrainDTargs(:, (p-1)*learnWLength+1:p*learnWLength) = ...            % ���е������� 200* 5k    ״̬�Ļ��� ���� DT
            Win * pTemplate';                       %    ��������һ��Ӧ
            allTrainYTargs(:, (p-1)*learnWLength+1:p*learnWLength) = ...            % ѵ��ʹ�õı�ǩ 1*5k
            Predict';
end

TychonovAlphaD = .001;
%%% pattern readout learning
TychonovAlphaWout = 0.01;
I = eye(N);  % �����ؽڵ���

D = (inv(allTrainOldArgs * allTrainOldArgs' + TychonovAlphaD * I) ...    % D����� ����
        * allTrainOldArgs * allTrainDTargs')';
    NRMSED = mean(nrmse(allTrainDTargs, D * allTrainOldArgs));      % ����D��NRMSE 
%% compute mean variance of x
varx = mean(var(allTrainArgs'));
%% cmpute Wout
Wout = (inv(allTrainArgs * allTrainArgs' + TychonovAlphaWout * I) ...       % ��ع�
    * allTrainArgs * allTrainYTargs')';             
NRMSEWout =  sum( nrmse(allTrainYTargs, Wout * allTrainArgs) ) / dim_out ;
fprintf('NRMSE   Wout = %0.2g  D = %0.2g \n ', NRMSEWout, NRMSED);   

%% �õ� D Wout ����֮��
%% ESN�� Cue ���� 
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
    
yTest_PL_cue = zeros(measureRL, NpTest, dim_out);  %  �����ĳ��ȣ�����ģʽ�������е�����+1��
yTest_PL_recall = zeros(measureRL, NpTest, dim_out);
SV_PL = zeros(N,NpTest, size(SNRTests,2)+1);
    
for p = 1
    % C learning and testing
        x = zeros(N,1);
%         u = cell2mat(u_allpattern(p));  % ��ȡһ��ģʽ
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
        %% b��cue ���� 
        figure()
        tmp = [ ];
        for n = 1:cueLength
            u_n  = u(n + initialWashout , :) ;
            x =  tanh(W * x + Win * u_n' + bias ) + b * randn(N,1);
            C = C + CadaptRateCue * ((x - C*x)*x' - aperture^(-2)*C);
            tmp  = [tmp; u_n];
        end
            t = 100:200;
        plot(label_data(t,1)', label_data(t,2)', '-*'); hold on;   % ԭʼ�ź�
        
        [U S V] = svd(C);             % C����ֵ�ֽ�
        SV_PL(:,p,1) = diag(S);    % C������ֵ    
         
        
%%  b)   cue �׶�
        xBeforeMeasure = x;   % �� C cue ѵ�걣������

        for n = 1 : measureWashout
               x = C * tanh(W *  x + D * x + bias);
        end
%         t = 1:200;
%         plot (t, x); hold on;r
        tmp = [  ];        
        for n = 1:measureRL   % runlen
                r = tanh(W *  x + D * x + bias);
                x = C * r;
                yTest_PL_cue(n,p,:) = Wout * r;  % ���������е������������r��
        end
        time_bias = initialWashout + cueLength;
        t = cueLength + 1 +initialWashout : cueLength + measureRL + initialWashout;
%         plot( t , yTest_PL(:,p,1),'-+');
        plot(yTest_PL_cue(1:10,p,1)', yTest_PL_cue(1:10,p,2)', '-+m'); hold on;   % ԭʼ�ź�
        plot(yTest_PL_cue(10:end,p,1)', yTest_PL_cue(10:end,p,2)', '-+r' ); hold on;   % ԭʼ�ź�


        x = xBeforeMeasure;  % x �ֻ�ȥ��

      %% Autoconcetptor
        RLs = [1];  % recall �Ĵ���Ӧ�ú� ���ڽ���  ���

      for i = 1:size(RLs,2)
            % state and noise scaling factors a and b
            b = sqrt(varx /  SNRTests(i));      % ����ϵ��
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
                yTest_PL_recall(n,p,:) = Wout * r;   % �����˵�2 ���
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
