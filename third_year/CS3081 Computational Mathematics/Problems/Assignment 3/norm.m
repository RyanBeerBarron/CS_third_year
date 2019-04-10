A = [-2, 1, 0;
    1, -2, 1;
    0, 1, -1.5];

B = [4, -1, 0, 1, 0;
    -1, 4, -1, 0, 1;
    0, -1, 4, -1, 0;
    1, 0, -1, 4, -1;
    0, 1, 0, -1, 4];
 
disp(infinityNormMatrix(A));

disp(infinityNormMatrix(B));
 
function infinityNorm = infinityNormMatrix(A)
    s = size(A);
    list = 1:s(1);
    for i = 1:s(1)
        list(i) = sum(abs(A(i,:)));
    end    
    infinityNorm = max(list);
    return
end