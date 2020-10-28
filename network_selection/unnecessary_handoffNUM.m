%  using calculated weight to get utility 
%  network attribute random created
%  
    clear;
%   RRS                  B           D               J                   L           C
    a1 ={[1 1 3],        [3 5 7],    [0.2 0.33 1],   [1 3 5],            [1 3 5]     [0.25 0.5 1];     
        [0.14 0.2 0.33], [1 1 3],    [0.25 0.5 1],   [0.17 0.25 0.5],    [1,2,4],    [0.125,0.17,0.25];
        [1 3 5 ],        [1 2 4],    [1 1 3],        [0.2 0.33 1],       [1 3 5],    [0.14 0.2 0.33];
        [0.2 0.33 1],    [2 4 6],    [1 3 5],        [1 1 3],            [3 5 7],    [0.2 0.33 1];
        [0.2 0.33 1],    [0.25 0.5 1],[0.2 0.33 1],  [0.14 0.2 0.33],    [1 1 3],    [0.11 0.14 0.2];
        [1 2 4],         [4 6 8],    [3 5 7],        [1 3 5],            [5 7 9],    [1 1 3]     };
    a2 ={[1 1 3],        [0.2 0.33 1],[3 5 7],       [5 7 9],            [1 3 5],    [1 3 5];
        [1 3 5],         [1 1 3],     [1 2 4],       [0.17 0.25 0.5],    [4 6 8],    [4 6 8];
        [0.14 0.2 0.33], [0.25 0.5 1],[1 1 3],       [0.14 0.2 0.33],    [1 3 5],    [1 3 5];
        [0.14 0.2 0.33], [2 4 6],     [3 5 7],       [1 1 3],            [5 7 9],    [5 7 9];
        [0.2 0.33 1],    [0.125 0.17 0.25],   [0.2 0.33 1],  [0.11 0.14 0.2], [1 1 3],    [1 1 3];
        [0.2 0.33 1],    [0.125 0.17 0.25],   [0.2 0.33 1],  [0.11 0.14 0.2], [1 1 3],    [1 1 3]};
    a3 ={[1 1 3],        [0.2 0.33 1],        [3 5 7],       [3 5 7],         [0.2 0.33 1],       [0.14 0.2 0.33];
        [1 3 5],         [1 1 3],             [3 5 7],       [4 6 8],         [0.25 0.5 1],       [1 2 4];
        [0.14 0.2 0.33], [0.14 0.2 0.33],     [1 1 3],       [1 2 4],         [0.125 0.17 0.25],  [0.17 0.25 0.5];
        [0.14 0.2 0.33], [0.125 0.17 0.25],   [0.25 0.5 1],   [1 1 3],        [0.11 0.14 0.2],    [0.14 0.2 0.33];
        [1 3 5],         [1 2 4],             [4 6 8],        [5 7 9],        [1 1 3],            [1 3 5];
        [3 5 7],         [0.25 0.5 1],        [2 4 6],        [3 5 7],        [0.2 0.33 1],       [1 1 3]};
    
    w_1= calwtg(a1);
    w_2= calwtg(a2);
    w_3= calwtg(a3);

    %%  above are the basic settings     
%     % initialize accumulating number
%     if ~size(count_test)
         count_test= zeros(4,1);
%     end
    %% including service_priority combining weight ,this represents the user
    %% serve scenes
       
    service_prioirity = [ 5 1 3 ];
    service_prioirity = service_prioirity / sum(service_prioirity);
    
    
    %    w_comb =  service_prioirity * [w_1; w_2; w_3];
    handoverNUM =0;
    showhandover=[];
    show_unncessary_handover_NUM = [];
    last_net = 0;    last_2_net = 0;
    last_2_time = 0; last_time = 0;
    unncessary_handover_NUM = 0;
    
    %% speed setting
    velocity = 5;
    
    for i = 1: 1000
        
        %  calculate net attributes value  randomly 
        net_contrib = attrib();
        %  using utility function to normalize
        m = size(net_contrib, 1);
        score=[];
        final_score = zeros(m,1);
        for j = 1 : m
            each_net_attribute = net_contrib(j , :);
            % voice 
            voice_value(1) = f(each_net_attribute(1),0.1,-15); 
            voice_value(2) = f(each_net_attribute(2),0.25,48); 
            voice_value(3) = g(each_net_attribute(3),0.1,75); 
            voice_value(4) = g(each_net_attribute(4),0.185,65); 
            voice_value(5) = h(each_net_attribute(5),1/30); 
            voice_value(6) = h(each_net_attribute(6),1/50); 
            % video 
            video_value(1) = f(each_net_attribute(1),0.1,-15); 
            video_value(2) = f(each_net_attribute(2),0.003,2000); 
            video_value(3) = g(each_net_attribute(3),0.1,112.5); 
            video_value(4) = g(each_net_attribute(4),0.175,55); 
            video_value(5) = h(each_net_attribute(5),1/30); 
            video_value(6) = h(each_net_attribute(6),1/50); 
            % web
            web_value(1) = f(each_net_attribute(1),0.1,-15); 
            web_value(2) = f(each_net_attribute(2),0.01,564); 
            web_value(3) = g(each_net_attribute(3),0.03,375); 
            web_value(4) = g(each_net_attribute(4),0.05,80); 
            web_value(5) = h(each_net_attribute(5),1/30); 
            web_value(6) = h(each_net_attribute(6),1/50);         

            score_voice = w_1 * voice_value';
            score_video = w_2 * video_value';
            score_web = w_3 * web_value';

            final_score(j) = service_prioirity * [score_voice score_video score_web]' ;

        end
        
        [ ~ , best_net ]= max(final_score);
        count_test(best_net) =  count_test(best_net) + 1;

        if(i == 1)
            last_net = best_net; last_2_net = best_net;
        else
            if last_net == best_net || (last_net ~= best_net && final_score(best_net) / final_score(last_net) <= 1);    %speed_control(velocity,1.5) )
                best_net = last_net;
            else
                if (last_2_net ~= 0 && last_net ~= best_net &&  last_time- last_2_time == 2)
                    unncessary_handover_NUM = unncessary_handover_NUM + 1;
                end
                handoverNUM = handoverNUM +1;
                last_2_net = last_net;
                last_net = best_net;
                last_2_time = last_time ; last_time = i;
            end
        end    
%         
%         if(cur_ID == 0 ||best_net == cur_ID)
%             cur_ID = best_net;
%             %%
%         elseif(final_score(best_net) / final_score(cur_ID) <= 1.1)  % Here set handover threshold
%             cur_ID = cur_ID;
%         else
%             cur_ID = best_net;
%             handoverNUM = handoverNUM +1;
           
        show_unncessary_handover_NUM(i) = unncessary_handover_NUM;
        showhandover(i) = handoverNUM;
        
        
    end
    
        
    
    %  using  utility func as filter 
    
    
    % cal weight
    
    
    % combining service priority
    
    
    figure();
    t = 0 : 0.2 : 25;
    t = t';
%     z = speed_control(t,1.3);
    y = (t + 1)./ ( ((t + 15 ) ./ 0.4) + 1) +1; hold on;
    z = t ./ ( ((t + 5) ./ 1.5 ) + 1);
    plot(t,y,t,z);
    plot(t,y);
    tt = -7: 0.1 : 7;
    plot(tt,1- f(tt,1,0));
    grid on;
    plot(t,y);
    legend('y','z');
    sigmoid = 0.16 * f(t, 0.2, 0)+ 0.5;
    plot(t, sigmoid,'g');

