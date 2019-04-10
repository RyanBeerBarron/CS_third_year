Xs = [14, 22, 30, 38, 46];
Ys = [320, 490, 540, 500, 480];


function foo = LagrangePolynomial(Xs, Ys)
    s1 = size(Xs);
    s2 = size(Ys);
    
    if s1(1) ~= 1 || s2(1) ~= 1
        disp("Error, set of inputs must be a vector");
        return
    end
    if s1(2) ~=  s2(2)
        disp("Error, the set of inputs must be of the same length");
        return
    end
    coef = 1:s1(2);
    for i = 1:s1(2)
       for j = 1:s1(2)
           
           
       end 
    end    
end