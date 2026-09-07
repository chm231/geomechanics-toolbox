function [Wmax, R, Pnet] = radial_C(E, nu, Q, mu, C, Sp, t)
    
try
    
fun = @ (R) sqrt(Q/(60*C^2*pi^2) * (14.128*nthroot((1-nu^2)*mu*Q*R/E, 4) + 15*Sp) * (exp((15*C*sqrt(pi*t)/(14.128*nthroot((1-nu^2)*mu*Q*R/E, 4) + 15*Sp))^2) * erfc(15*C*sqrt(pi*t)/(14.128*nthroot((1-nu^2)*mu*Q*R/E, 4) + 15*Sp)) + 2/sqrt(pi) * 15*C*sqrt(pi*t)/(14.128*nthroot((1-nu^2)*mu*Q*R/E, 4) + 15*Sp) -1)) - R;
R = fzero(fun, [0 1.0e5]);
Wmax = 3.532 * nthroot((1-nu^2)*mu*Q*R / E, 4);
Pnet = Wmax * pi* E / (8*(1-nu^2)*R);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'radial_C.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
