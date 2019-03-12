

A = [4, -1, 3, 2;
     -8, 0, -3, -3.5;
     2, -3.5, 10, 3.75;
     -8, -4, 1, -0.5];
[L, U] = LUDecompGauss(A);

disp(L)
disp(U)

if L*U == A
    disp("Succes!")
end    

%LU decomposition function using Gauss method, takes a square matrix
%A and returns its lower and upper triangular matrices, L and U, such
%such that L x U = A
function [L, U] = LUDecompGauss(A)
    s = size(A);
    if s(1) ~= s(2)
        disp("The matrix must be square!")
        return
    end
    n = s(1);
    L = eye(n);
    U = eye(n);
    for i = 1:n-1
       pivot = A(i,i);
       for j = i+1:n
           temp = A(j, i);
           coef = temp/pivot;
           L(j, i) = coef;
           A(j, :) = A(j, :) - coef*A(i, :);
       end    
    end
    U = A;
    return
end