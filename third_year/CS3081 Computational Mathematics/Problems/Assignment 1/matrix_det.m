A = [3, 8; 4, 6];
B = [6, 1, 1; 4, -2, 5; 2, 8, 7];
C = [1,2,3;4,5,6];
disp(Determinant(A));
disp(Determinant(B));
disp(Determinant(C));

a = [1, 5, 4;
     2, 3, 6;
     1, 1, 1];
b = [1, 2, 3, 4;
     5, 6, 7, 8;
     9, 10, 11, 12;
     13, 14, 15, 16];
 
 disp(Determinant(a));
 disp(Determinant(b));



%Function to calculate determinant for any nxn matrix
%Takes any matrix and returns its determinant if it is a square matrix
%or return error message if not square.
function det = Determinant(matrix)
    s = size(matrix);
    %Check if matrix is squared by comparing its dimensions
    if s(1) ~= s(2)   
        det = "The matrix must be square";
    %If matrix is just a scalar, return the scalar value //
    %The determinant of a 1x1 matrix is just its unique value
    elseif s(1) == 1    
        det = matrix(1);
    %Else, recursively calculate the determinant of the matrix by finding
    %the determinants of its sub-matrices
    else 
        det = 0;
        for i = 1:s(1)
            temp = matrix;
            temp(1,:) = [];
            temp(:,i) = [];
            det = det + matrix(1, i) * Determinant(temp) * (-1)^(i-1);
        end
    end    
end 