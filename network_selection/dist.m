function d = dist(x,y)
%     [m n]= size(x);
    d =sqrt( sum((x - y) .* (x - y),2));
end