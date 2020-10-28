
%%  位置数据预处理
load('data3.mat');
pos = output_seq{3};
pos(:,1)  = pos(:,1) * 4000 + sqrt(10) * (2 * rand - 1);        % 增加预测随机数
pos(:,2)  = pos(:,2) * 4000 + sqrt(10) * (2 * rand - 1);        % 增加预测的随机数误差
pos = floor(pos); 
%%

ap_interval = 200 ;  % meter
%%                 UMTS  LTE  WLAN  WiMAX 
interval_seq = [35e3,   1e3,   100,   500];
occupy_x = [];
occupy_y = [];

for i  = 1 :4
    ap_interval = interval_seq(i);
    inv_pos = ap_interval - mod(pos, ap_interval);
    % [close_ap, ap_id]= min( mod(pos,ap_interval) ,ap_interval - mod(pos,ap_interval) ) ;
    % dist = sqrt()0;
    distance = min( dist ( mod ( pos, ap_interval),zeros(size(inv_pos))), dist (inv_pos, zeros(size(inv_pos)))) ;
    %% 切换的次数 通过商来建模
    occupy_id_x =  floor(pos(:,1) / ap_interval) ;
    occupy_id_y =  floor(pos(:,2) / ap_interval);

   
    %% 计算 RSS 
    switch i 
        case 1      % 40W   =  53dBm
                RSS_UMTS  = 53 - 127.5    -35.2 * log10((distance + 500 )/1000) - 2.296 * randn;
        case 2      % 
                RSS_LTE  = 43 - 127.5  - 35.2 * log10((distance + 300  )  /1000) - 2.296 * randn;
        case 3
                RSS_WLAN  = 23 - 32.5 -  20 * log10(2.4e3)  -20 * log10((distance + 200 )/1000)  - normrnd(20,10, [size(distance,1)  size(distance,2)]) - 2.303 * randn; 
        case 4
                RSS_WiMAX  = 30 - 127.5   - 35.2 * log10((distance + 300 + 100 *  rand(size(distance)) )/1000) - 2.296 * randn;
    end
    
occupy_x = [occupy_x ,  occupy_id_x]; 
occupy_y = [occupy_y,   occupy_id_y];
end

fprintf('LTE %.4f    %.4f   %.4f   %.4f \n' ,max(RSS_LTE), min(RSS_LTE),mean(RSS_LTE), var(RSS_LTE));
fprintf('UMTS %.4f    %.4f    %.4f    %.4f \n',max(RSS_UMTS), min(RSS_UMTS), mean(RSS_UMTS), var(RSS_UMTS));
fprintf('WLAN %.4f     %.4f   %.4f    %.4f \n',max(RSS_WLAN), min(RSS_WLAN), mean(RSS_WLAN), var(RSS_WLAN));
fprintf('WiMAX %.4f     %.4f   %.4f    %.4f \n',max(RSS_WiMAX), min(RSS_WiMAX), mean(RSS_WiMAX), var(RSS_WiMAX));

RSS = [RSS_UMTS , RSS_LTE,  RSS_WLAN, RSS_WiMAX];
%% 计算  选择概率与 切换 次数

% save('major_re_RSS_wcase','RSS','occupy_x', 'occupy_y')
% save('RSS', 'RSS','occupy_x', 'occupy_y' )

