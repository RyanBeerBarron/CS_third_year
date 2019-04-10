





def lagrange(x) :

    num1 = (x-22)*(x-30)*(x-38)*(x-46)
    denum1 = (14-22)*(14-30)*(14-38)*(14-46)
    coef1 = 320
    term1 = (float(num1)/float(denum1)) * coef1
    
    
    num2 = (x-14)*(x-30)*(x-38)*(x-46)
    denum2 = (22-14)*(22-30)*(22-38)*(22-46)
    coef2 = 490
    term2 = (float(num2)/float(denum2)) * coef2

    num3 = (x-14)*(x-22)*(x-38)*(x-46)
    denum3 = (30-14)*(30-22)*(30-38)*(30-46)
    coef3 = 540
    term3 = float((num3)/float(denum3)) * coef3

    num4 = (x-14)*(x-22)*(x-30)*(x-46)
    denum4 = (38-14)*(38-22)*(38-30)*(38-46)
    coef4 = 500
    term4 = float((num4)/float(denum4)) * coef4

    num5 = (x-14)*(x-22)*(x-30)*(x-38)
    denum5 = (46-14)*(46-22)*(46-30)*(46-38)
    coef5 = 480
    term5 = float((num5)/float(denum5)) * coef5

    return term1+term2+term3+term4+term5



print(lagrange(28))