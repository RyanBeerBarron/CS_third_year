%Set up variables for number of iterations, the first interval
%and the anonymous function f and gfoo, the latter being the derivative of 
%the former. Using matlabFunction to convert the symbolic function g, to a
%actual matlab function, that can be called and computes an answer.
iterations = 3;
a = 0;
b = 1;
f = @(x) x-2*exp(-x);
g = diff(f(x));
gfoo = matlabFunction(g);

disp(bisection(a, b, iterations, f));
disp(secant(a, b, iterations, f));
disp(newton(b, iterations, f, gfoo));

%Bisection method, takes both bounds of the interval in which the root
%is located.
%The number of iterations to be done before returning an approximation
%And the root's function, which is an anonymous function
function approx = bisection(a, b, iter, foo)
    mid = (a+b)/2;
    %Check for the number of iterations left to be done, end if 0 and
    %returns the new middle point computed
    if iter == 0
        approx = mid;
        return
    end
    %Otherwise, recursively call the function and decrememt the number of
    %iterations to be done.
    iter = iter - 1;
    temp = foo(a) * foo(mid);
    if temp < 0
        approx = bisection(a, mid, iter, foo);
    elseif temp > 0
        approx = bisection(mid, b, iter, foo);
    end    
end
%Secant method, takes both bounds of the interval in which the root is
%located.
%The number of iterations to be done before returning an approximation
%And the root's function, which is an anonymous function
function approx = secant(a, b, iter, foo)
    num = foo(b) * (a-b);
    denum = foo(a)-foo(b);
    newapprox = b - num/denum;
    %Check for the number of iterations left to be done, end if 0 and
    %returns the new point passing the x-axis.
    if iter == 0
        approx = newapprox;
        return
    %Otherwise, recursively call the function and decrememt the number of
    %iterations to be done.    
    else  
        approx = secant(b, newapprox, iter-1, foo);
        return
    end
end
%Newton method, take a first estimate of the solution, the number of
%iterations to be done, the root's function and its derivative.
function approx = newton(a, iter, foo, deriv)
    newapprox = a - (foo(a)/deriv(a));
    %Check for the number of iterations left to be done, end if 0 and
    %returns the new point passing the x-axis that is on the tangent
    %of foo passing by a.
    if iter == 0
        approx = newapprox;
        return
    %Otherwise, decrement the number of iterations to be done 
    %and call function recursively
    else
        approx = newton(newapprox, iter-1, foo, deriv);
        return
    end    
end


function Xs = newtonExam(p)
	foo = @(x) x^2 - p;
	derivfoo = matlabFunction(diff(foo(x)));
	