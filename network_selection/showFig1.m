% % show image Fig1    selected  probablity
    load('RSS.mat');
    x = [1 : 7]';
    y = [];
    for i = 1:3
        load(['ctmat_s',num2str(i)]);
        count_matrix = count_matrix / sum(count_matrix(: ,1));   % ÇóµÃ   ¸ÅÂÊ
        y = [y; count_matrix'];
    end
%         load ('RSS.mat');
        RSS_count_test = RSS_count_test / sum(RSS_count_test);
        y= [y; RSS_count_test'] ;
        stuff = zeros(1,4);
%         color_set = [ [0.25, 0.88 ,0.82] ,[1 0.5 0.31],[1 0.89 0.52 ] ,[0.63 0.4 0.83] ];
        handle = bar([ y(1:2,:) ; stuff;  y(3:4,:); stuff;  y(5:6,:); stuff;  RSS_count_test' ], 'grouped');
        
        ylim([0 0.9]);         grid on;
        set(gca,'XTickLabel',{'Ours ','MCGDM','','Ours ','MCGDM','','Ours ','MCGDM','','RSS'});
%         set(gca,'XTickLabel',{'scene1','scene2','scene3','RSS'});

        legend('UMTS','LTE','WLAN','WiMAX');   
        set(handle(1), 'facecolor', [0.12, 0.56 ,1]); 
        title('Network Selection probability with different service priority','FontSize',15)
        ylabel('Network Selection probability','FontSize',15)
        
        
        
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

    figure();
    t = 1:size(RSS,1);
    load('hd_num_v0');
    plot(t, hd_numv0,'Color',[1 0.5 0.31],  'Linewidth',2);  hold on ;
    plot(t, MCGDM_showhandover,'g','Linewidth',2);
    plot(t, RSS_showhandover, 'Color',[0.12, 0.56 ,1] ,'Linewidth',2); 
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

load('')

    grid on;
    ylim([0 700]);
    legend('Proposed ','MCGDM','RSS based ','v = 2m/s','v = 5m/s','v = 10m/s','v = 15m/s');
    title('Handover number of different algorithm','FontSize',15);
    ylabel('Handover times','FontSize',15);
    xlabel('Simulation times','FontSize',15);
    
    
    plot(t,hd_numv15 ,':','Linewidth',2);
%% show unnecessary handoff     
    t = 1:1000
    plot(t,showhandover,'r','Linewidth',2); hold on ;
    plot(t,show_unncessary_handover_NUM,'b' );    
%     plot(t,show_unncessary_handover_NUM);
%     ylim([0 400]);
    legend('allnumhandover','unnecessary');    
    