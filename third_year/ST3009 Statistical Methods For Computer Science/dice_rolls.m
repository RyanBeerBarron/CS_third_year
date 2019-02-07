%Simulate 1000000 throws of 3 die and count the number of times there is a
%2 in the resulting array of the random number generator. Divide the count
%by n for the probability.
n = 1000000;
dice_throws = 3;
count = 0;
for i = 1:n
    a = randi(6,1,dice_throws);
    c = ismember(2, a);
    if c
        count = count + 1;
    end    
end
disp(count);
disp(count/n);
