function [Wmax, L, Pnet] = KGD_C(E, nu, Q, mu, C, Sp, h, t)

try
    
fun = @ (L) Q/(32*C^2*pi*h) * (2.708*pi*nthroot((1-nu^2)*mu*Q*L^2/(h*E), 4) + 8*Sp) * (exp((8*C*sqrt(pi*t)/(2.708*pi*nthroot((1-nu^2)*mu*Q*L^2/(h*E), 4) + 8*Sp))^2) * erfc(8*C*sqrt(pi*t)/(2.708*pi*nthroot((1-nu^2)*mu*Q*L^2/(h*E), 4) + 8*Sp)) + 2/sqrt(pi) * 8*C*sqrt(pi*t)/(2.708*pi*nthroot((1-nu^2)*mu*Q*L^2/(h*E), 4) + 8*Sp) -1) - L;
L = fzero(fun, [0 1.0e5]);
Wmax = 2.708 * nthroot((1-nu^2)*mu*Q*L^2/(h*E), 4);
Pnet = Wmax * E / (4*(1-nu^2)*L);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'KGD_C.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
