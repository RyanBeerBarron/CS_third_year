

x = [1900, 1950, 1970, 1980, 1990, 2000, 2010];

y = [400, 557, 825, 981, 1135, 1266, 1370];

Y = log(y);

n = size(x);

Sx = sum(x);
Sy = sum(Y);
Sxy = sum(x.*Y);
Sxx = sum(x.*x);

num = n(2)*Sxy - Sx*Sy;
denum = n(2)*Sxx - (Sx)^2;
m = num / denum;

num = Sxx*Sy - Sxy*Sx;
denum = n(2)*Sxx - Sx^2;
b = num / denum;

disp("b is equal to " +b);

disp("m is equal to " + m);
temp = exp(b) * exp(1985*m);

result = (4.6931*10^-8) * exp(1985*0.012);

disp("The population in 1985 was around " + result );