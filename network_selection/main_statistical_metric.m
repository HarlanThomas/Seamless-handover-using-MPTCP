% statistical results are used for handover numbers presentation. 
tic
times = 20;    % total round times
%% run the first round
major_re_adsf_Journal_handover_num
% major_re_wc_Journal_handover_num
main_wc_journal_handovernum_inherted

%% define the output varible
showhd_pos_s = showhd_pos;
RSS_showhandover_s = RSS_showhandover;
MCGDM_showhandover_s = MCGDM_showhandover;
topsis_showhandover_s = topsis_showhandover;


%%  begin statistic
for t = 2 : times
    t
    % First should check the program's config !!!!!!
    % 1. whether the worst case is added
    % 2. whether the handovernum_inherted.m   's load('RSS') is closed
    % 3. which case is the sd set 12.9 25.8 50 100 ?
    % 4. service type is set as web
    
    
    % run RSS data with random loss
    major_re_adsf_Journal_handover_num
%     major_re_wc_Journal_handover_num
    % network selection and handover time counts
    main_wc_journal_handovernum_inherted

    % process metric with online update method
    
    showhd_pos_s = showhd_pos_s * (t - 1) / t + showhd_pos / t; % proposed method
    
    
    RSS_showhandover_s = RSS_showhandover_s * (t - 1) / t + RSS_showhandover / t;
    MCGDM_showhandover_s = MCGDM_showhandover_s * (t - 1) / t + MCGDM_showhandover / t;
    topsis_showhandover_s = topsis_showhandover_s * (t - 1) / t + topsis_showhandover / t;
    
    
    
end

%% save results

showhd_pos_s_sd0 = showhd_pos_s;    save('showhd_pos_s_sd0','showhd_pos_s_sd0');
% 
% showhd_pos_s_sd12_9 = showhd_pos_s;   save('showhd_pos_s_sd12_9','showhd_pos_s_sd12_9');
% showhd_pos_s_sd25_8 = showhd_pos_s;   save('showhd_pos_s_sd25_8','showhd_pos_s_sd25_8');
% showhd_pos_s_sd50 = showhd_pos_s;     save('showhd_pos_s_sd50','showhd_pos_s_sd50');
% showhd_pos_s_sd100 = showhd_pos_s;    save('showhd_pos_s_sd100','showhd_pos_s_sd100');

% showhd_pos_ws_s_sd12_9 = showhd_pos_s;   save('showhd_pos_ws_s_sd12_9','showhd_pos_ws_s_sd12_9');

% 
% save('RSS_showhandover_s', 'RSS_showhandover_s');
% save('MCGDM_showhandover_s','MCGDM_showhandover_s');
save('topsis_showhandover_s', 'topsis_showhandover_s');

toc 



