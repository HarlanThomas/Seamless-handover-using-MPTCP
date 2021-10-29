function nternalWeights = generate_cycle_weights(nInternalUnits, ...
    connectivity)
    
w = randn(1,nInternalUnits);
tmp = diag(w);

w = randn(1,nInternalUnits/2);

w = [w ;  zeros(1,size(w,2)) ];
w = reshape(w, [1, nInternalUnits]);
A = diag(w);
tmp = tmp + [A( : , 3:end), A(: , 1:2 ) ];

nternalWeights = [tmp( : , 2:end), tmp(: , 1 ) ];

