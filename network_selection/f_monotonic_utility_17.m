function f_x = f_monotonic_utility_17(x, target_point)
% ���Եĺ���������˥��������ؾ��� target_point
    over_border = x  <= target_point;
    f_x  = (1 - x / target_point) .* over_border;
%     f_x = (1 ./ (1 + exp( -a * (x - b))));
end