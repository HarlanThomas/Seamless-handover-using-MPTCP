function out = speed_control(v,a)
    out = (v + 1) ./ (((v + 15) ./ a)+1) + 1;
end

