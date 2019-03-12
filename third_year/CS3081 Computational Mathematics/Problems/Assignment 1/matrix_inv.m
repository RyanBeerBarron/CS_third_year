
B = [-1, -2, 1, 2;
     1, 1, -4, -2;
     1, -2, -4, -2;
     2, -4, 1, -2];
 
A = [-1, 2, 1;
     2, 2, -4;
     0.2, 1, 0.5];
 
disp(inverse(A));
disp(inverse(B));
disp(inverse([1,2,3;4,5,6]));


%Inverse function, takes a square matrix and return its inverse using the
%Gauss Jordan method.
 function inv = inverse(matrix)
    s = size(matrix);
    if s(1) ~= s(2)         %Check if the matrix is square or not
        inv = "The matrix must be a square!";
        return
    end
    n = s(1);
    identity = eye(n);
    cat = [matrix identity]; % append the identity matrix of the same size to the argument
    
    for i = 1:n-1       %Loop through the rows to reduce the original matrix in upper triangular form
       pivot = cat(i,i);    %Take elememt i,i as pivot for all i, s.t 1<=i<=n
       for j = i+1:n
           temp = cat(j,i);
           coef = (-temp)/pivot;    %Compute coefficient to reduce the terms in the other rows down to 0
           cat(j,:) = cat(j,:) + coef*(cat(i,:));    %Row addition 
       end    
    end
    
    
   for i = n:-1:1       %Second step to the reduce the original 
                        %matrix to the identity matrix, start from the bottom row
                        
        %If the unique element on that row is not equal to one,
        %divide that whole row by the unique element                
        if cat(i, i) ~= 1
            cat(i,:) = cat(i,:) / cat(i, i);
        end
        
        %Subtract the upper rows with the current one, such that all the non diagonal are zeroes
        for j = i-1:-1:1
            cat(j,:) = cat(j,:) + (-cat(j,i)*cat(i,:));
        end
   end    
    %return the appended matrix
    inv = cat(:,n+1:end);
 end
 