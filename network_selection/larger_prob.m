
function output = larger_prob(S_j,S_i)
    if S_j(2) >= S_i(2)
        output = 1;
        return  
        
    elseif ( S_j(2) <= S_i(2) ) && ( S_i(1) <= S_j(3) )
        % disputed formulation 
%         output = (S_j(1) - S_i(3))/((S_j(2) - S_j(3)) -(S_i(2) - S_i(1)));
        output = ((S_j(2) - S_j(3)) - (S_i(2) - S_i(1))) / (S_j(1) - S_i(3)) ;
        return 
    else
        output = 0;
        return 
    end
end

        
            
        