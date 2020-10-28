function f_x = f_marginal_benifit_desc_16(x, base_point, target_point, p)
    k = -log(1 - p) ./ (target_point - base_point);
    f_x = 1 - exp(-k * (x - base_point));
%     f_x = (1 ./ (1 + exp( -a * (x - b))));
end