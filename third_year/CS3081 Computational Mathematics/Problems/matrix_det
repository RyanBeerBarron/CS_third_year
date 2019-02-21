

A = [3, 8; 4, 6];
disp(Determinant(A));



function det = Determinant(matrix)
    s = size(matrix)
    if s(1) != s(2)
        det = "The matrix must be square"
    elseif s(1) == 1
        det = s(1)
    else 
        det = 0
        for i = 1:s(1)
            temp = matrix
            temp(1,:) = []
            temp(:,i) = []
            det += matrix(1, i) * Determinant(temp) * (-1)^(i-1);
        end
    end    
end 