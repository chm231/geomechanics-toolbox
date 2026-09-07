function [Wmax, L, Pnet] = PKN_C(E, nu, Q, mu, C, Sp, h, t)

try

fun = @ (L) Q/(40*C^2*pi*h) * (2.75*pi*nthroot((1-nu^2)*mu*Q*L/E, 4) + 10*Sp) * (exp((10*C*sqrt(pi*t)/(2.75*pi*nthroot((1-nu^2)*mu*Q*L/E, 4) + 10*Sp))^2) * erfc(10*C*sqrt(pi*t)/(2.75*pi*nthroot((1-nu^2)*mu*Q*L/E, 4) + 10*Sp)) + 2/sqrt(pi) * 10*C*sqrt(pi*t)/(2.75*pi*nthroot((1-nu^2)*mu*Q*L/E, 4) + 10*Sp) -1) - L;
L = fzero(fun, [0 1.0e5]);
Wmax = 2.75 * nthroot((1-nu^2)*mu*Q*L / E, 4);
Pnet = Wmax * E / (2*(1-nu^2)*h);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'PKN_C.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
