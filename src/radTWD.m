function radial_T_WD = radTWD(s, theta, ep, H)
try
%radial_T_WD = 1/s*exp(-(theta*s+2*sqrt(s)*tanh(sqrt(s)))*ep/(2+theta))*(cosh(sqrt(s)*H)-sinh(sqrt(s)*H)*tanh(sqrt(s)));
radial_T_WD = 1/s*exp(-(2*sqrt(s)*tanh(sqrt(s)))*ep/(2+theta))*(cosh(sqrt(s)*H)-sinh(sqrt(s)*H)*tanh(sqrt(s)));

%The first eq considers the aperture
%The second eq does NOT consider the aperture, which is used in TherCal.

catch ex
    errmsg = ex.stack.line;
    msgbox([{'radTWD.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end