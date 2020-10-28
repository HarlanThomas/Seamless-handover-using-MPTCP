% caculate method in MMT paper Network Selection Algorithm for 
% Multiservice Multimode Terminals in Heterogeneous Wireless Networks
% 
% edited by thn in 2019.5.8
function  w_tg = calwtg(a)
    
    n = size(a,1);
    row_sum = cell(1,n);
    all_sum = zeros(1,3);
    S = cell(1,n);
    for i = 1:n
        row_sum{1,i} = zeros(1,3);
    %     col_sum{1,j}  ����д �е����
    %    �������
        for j = 1:n
            row_sum{1,i} = row_sum{1,i} + a{i,j};
        end
    %    ����ܵĺ�
        all_sum = all_sum + row_sum{1,i};
    end

    all_invs = [1/all_sum(3),1/all_sum(2),1/all_sum(1)];        % ȡ���� ������С 

    for i = 1:n
        S{1,i} = row_sum{1,i} .* all_invs;
    end

    V = [];
    % min ���� ��ȡ�ã�ȡ��ÿ�е���Сֵ
    for i = 1:n
        for j = 1:n

            V(i,j) = larger_prob(S{1,i},S{1,j});

        end 
    end

    w_tg = min(V'); 
    w_tg = w_tg / sum(w_tg);

end








