n = 100000;
dice_throws = 3;
a = randi(6,1,dice_throws);
count = 0;
for i = 1:n
    b = randi(6,1,dice_throws);
    a = cat(1,a,b);
    c = ismember(2, b);
    if c
        count = count + 1;
    end    
end
disp(count);
disp(count/n);
