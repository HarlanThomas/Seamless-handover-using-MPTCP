% % show image Fig1    selected  probablity
    load('major_re_RSS.mat');
    x = [1 : 10]';
    y = [];
    for i = 1:3
%         load(['ctmat_s',num2str(i)]);
        load(['maj_r_ctmat_s',num2str(i),'_addsf']);   
        count_matrix = count_matrix / sum(count_matrix(: ,1));   % 求得   概率
        y = [y; count_matrix'];
    end
        load ('maj_r_RSSmat_addsf');
        RSS_count_test = RSS_count_test / sum(RSS_count_test);
        y= [y; RSS_count_test'] ;
              
        load('wc_maj_r_ctmat_s1_addsf');
        count_matrix = count_matrix / sum(count_matrix(: ,1));
        y= [y; count_matrix'] ;

        load('wc_maj_r_ctmat_s2_addsf');    count_matrix = count_matrix / sum(count_matrix(: ,1));
        y= [y; count_matrix'] ;
        load('wc_maj_r_ctmat_s3_addsf');    count_matrix = count_matrix / sum(count_matrix(: ,1));
        y= [y; count_matrix'] ;
        
        yy = [
                y(1:3,:); y(11,:); 
                y(4:6,:); y(14,:);
                y(7:9,:); y(17,:);
                RSS_count_test'  
              ];
%%  原版        
%         stuff = zeros(1,4);
% %         color_set = [ [0.25, 0.88 ,0.82] ,[1 0.5 0.31],[1 0.89 0.52 ] ,[0.63 0.4 0.83] ];
%         handle = bar([ yy(1:3,:); stuff;     yy(5:7,:); stuff;    yy(9:11,:); stuff;    RSS_count_test'], 'grouped');
%         
%         ylim([0 0.9]);         grid on;
%         set(gca,'XTickLabel',{'FAHP','MCGDM','FTOPSIS', '',  'FAHP','MCGDM','FTOPSIS','','FAHP','MCGDM','FTOPSIS', '', 'RSS'});
%         % 'WorstCase'
%         %         set(gca,'XTickLabel',{'scene1','scene2','scene3','RSS'});
% 
%         legend('UMTS','LTE','WLAN','WiMAX');   
%         set(handle(1), 'facecolor', [0.12, 0.56 ,1]); 
%         title('Network Selection probability with different service priority','FontSize',15)
%         ylabel('Network Selection probability','FontSize',15)
        
%% 新版
        figure
        stuff = zeros(1,4);
%         color_set = [ [0.25, 0.88 ,0.82] ,[1 0.5 0.31],[1 0.89 0.52 ] ,[0.63 0.4 0.83] ];
        handle = bar([ yy(1:4,:); stuff;     yy(5:8,:); stuff;    yy(9:12,:); stuff; RSS_count_test'], 'grouped');
        
        ylim([0 0.9]);     
        grid on;
        xtickangle(30)
        xticks(1:16)
        set(gca,'XTickLabel',{'FAHP','MCGDM','FTOPSIS','FAHP with errors', '',  'FAHP','MCGDM','FTOPSIS','FAHP with errors', '','FAHP','MCGDM','FTOPSIS','FAHP with errors', '','RSS'});
        xlabel('  Web  prefered                             Video prefered                            Voice prefered                                ','FontSize',8)    
        ylabel('Network Selection Probability');
        % 'WorstCase'
        %         set(gca,'XTickLabel',{'scene1','scene2','scene3','RSS'});

        legend('UMTS','LTE','WLAN','WiMAX');   
        set(handle(1), 'facecolor', [0.12, 0.56 ,1]); 
%         title('Network Selection probability with different service priority','FontSize',15)
     
        
        
%         set(handle(2), 'facecolor', [1 0.5 0.31]); 
%         set(handle(3), 'facecolor', [1 0.89 0.52 ]); 
%         set(handle(2), 'facecolor', [0.63 0.4 0.83]);
%     s1 = 1 3 6
%     s2 = 1 6 3
%     s3 = 6 3 1        
%     y1 = count_test'/sum(count_test);   % regarding it as a tranposed matrix and shoe as bar fig
%     y2 = RSS_count_test' / sum(RSS_count_test);  % col 
%     y3 = MCDGM_count_test' / sum(MCDGM_count_test);
%     y = [y1 ; y2 ;y3];
   


    
%% show handoff num
    all_num = 10000;
    figure();
    t = 1:all_num;
%     load('hd_num_v0');
%     load('showhd_pos_mr0');
%     load('topsis_showhandover');
    load('hd_num_sd12_9_addsf');
    load('hd_num_sd25_8_addsf');
    load('hd_num_sd50_addsf');
    load('hd_num_sd100_addsf');
%     load('hd_num_sd1000_addsf');
    load('RSS_showhandover_addsf');
    load('MCGDM_showhandover_addsf');
    load('topsis_showhandover_addsf');
    load('hd_num_sd0_addsf');
    load('hd_num_wc_sd12_9');
    
    
    
    
    
    plot(t, RSS_showhandover(1:all_num), 'Color',[0.12, 0.56 ,1] ,'Linewidth',2); hold on;
    plot(t, MCGDM_showhandover(1:all_num),'g','Linewidth',2);    hold on;
    plot(t, topsis_showhandover(1:all_num), 'Color',[0.8, 0.56 ,0.5],'Linewidth',2);    hold on;
    plot(t, hd_num_sd0(1:all_num),'Color',[1 0.5 0.31],  'Linewidth',2);  hold on ;
    plot(t, hd_num_sd12_9(1:all_num),                        'Linewidth',2);  hold on ;
    plot(t, hd_num_sd25_8(1:all_num),       '-.',                 'Linewidth',2);  hold on ;
    plot(t, hd_num_sd50(1:all_num),           '-.',             'Linewidth',2);  hold on ;
    plot(t, hd_num_sd100(1:all_num),          '-.',             'Linewidth',2);  hold on ;
%     plot(t, hd_num_sd1000(1:all_num),         ':',              'Linewidth',2);  hold on ;
    plot(t, hd_num_wc_sd12_9(1:all_num),          '-.',             'Linewidth',2);  hold on ;

%     plot(t, showhd_pos_mr0(1:all_num), 'Color',[0.3, 0.3 ,0.7] ,'Linewidth',2); 
%     plot(t, showhd_pos(1:all_num), 'Color',[0.3, 0.6 ,0.6] ,'Linewidth',2); 
    
    legend(     ...
    'RSS based ',           ...
    'Fuzzy MCGDM',      ...
    'FTOPSIS',      ...
    'FAHP without location information',      ...
    'FAHP with location information, \sigma = 12.9 ',    ...
    'FAHP with location information, \sigma = 25.8',    ...
    'FAHP with location information, \sigma = 50',    ...
    'FAHP with location information, \sigma = 100 ',  ...
    'FAHP with worst case, \sigma = 12.9'   ...
    );

%     
%     
%     load('hd_num_v2');
%     plot(t,hd_numv2  ,':','Linewidth',2);
%     load('hd_num_v5');
%     plot(t,hd_numv5  ,':','Linewidth',2);
%     load('hd_num_v10');
%     plot(t,hd_numv10  ,':','Linewidth',2);
%     load('hd_num_v15');

%     load('hd_num_v30');
%     plot(t,hd_numv30  ,'Linewidth',2);
%     plot(t, showscore * 400,'g');
%     plot(t, RSS_showutility  * 400,'m');
%     plot(t,show_unncessary_handover_NUM);
    grid on;
%     ylim([0 700]);
%     legend('FAHP based','Fuzzy MCGDM','RSS based ','v = 2m/s','v = 5m/s','v = 10m/s','v = 15m/s');
    title('Handover times of different algorithms','FontSize',15);
    ylabel('Handover times','FontSize',15);
    xlabel('Simulation times','FontSize',15);
    
    
%     plot(t,hd_numv15 ,':','Linewidth',2);
%% show unnecessary handoff     
%     t = 1:1000
%     plot(t,showhandover,'r','Linewidth',2); hold on ;
%     plot(t,show_unncessary_handover_NUM,'b' );    
% %     plot(t,show_unncessary_handover_NUM);
% %     ylim([0 400]);
%     legend('allnumhandover','unnecessary');  



%% show statistical results
    all_num = 10000;
    figure();
    t = 1:all_num;
%     load('hd_num_v0');
%     load('showhd_pos_mr0');
%     load('topsis_showhandover');
    load('showhd_pos_s_sd12_9');
    load('showhd_pos_s_sd25_8');
    load('showhd_pos_s_sd50');
    load('showhd_pos_s_sd100');
%     load('hd_num_sd1000_addsf');


    load('RSS_showhandover_s');
    load('MCGDM_showhandover_s');
    load('topsis_showhandover_s');
    load('showhd_pos_s_sd0');
    
    load('showhd_pos_ws_s_sd12_9');
    
    plot(t, RSS_showhandover_s(1:all_num), 'Color',[0.12, 0.56 ,1] ,'Linewidth',2); hold on;
    plot(t, MCGDM_showhandover_s(1:all_num),'g','Linewidth',2);    hold on;
    plot(t, topsis_showhandover_s(1:all_num), 'Color',[0.8, 0.56 ,0.5],'Linewidth',2);    hold on;
    plot(t, showhd_pos_s_sd0(1:all_num),'Color',[1 0.5 0.31],  'Linewidth',2);  hold on ;
    
    plot(t, showhd_pos_s_sd12_9(1:all_num),                        'Linewidth',2);  hold on ;
    plot(t, showhd_pos_s_sd25_8(1:all_num),       '-.',                 'Linewidth',2);  hold on ;
    plot(t, showhd_pos_s_sd50(1:all_num),           '-.',             'Linewidth',2);  hold on ;
    plot(t, showhd_pos_s_sd100(1:all_num),          '-.',             'Linewidth',2);  hold on ;
%     plot(t, hd_num_sd1000(1:all_num),         ':',              'Linewidth',2);  hold on ;
    plot(t, showhd_pos_ws_s_sd12_9(1:all_num),          ':',             'Linewidth',2);  hold on ;
%     plot(t, topsis_showhandover_s(1:all_num), 'Color',[0.8, 0.56 ,0.5],'Linewidth',2);    hold on;
    plot(t, topsis_showhandover_s(1:all_num), 'Color',[0.8, 0.56 ,0.5],'Linewidth',2);    hold on;

    legend(     ...
    'RSS based ',           ...
    'Fuzzy MCGDM',      ...
    'FTOPSIS',      ...
    'FAHP without location info',      ...
    'FAHP with location info, \sigma = 12.9 ',    ...
    'FAHP with location info, \sigma = 25.8',    ...
    'FAHP with location info, \sigma = 50',    ...
    'FAHP with location info, \sigma = 100 ',  ...
    'FAHP with errors, \sigma = 12.9'   ...
    );

    grid on;

    
%     title('Handover times of different algorithms','FontSize',15);
    ylabel('Handover times','FontSize',15);
    xlabel('Simulation times','FontSize',15);






