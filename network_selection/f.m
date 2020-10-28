function f_x = f(x, a, b)
    f_x = (1 ./ (1 + exp( -a * (x - b))));
end