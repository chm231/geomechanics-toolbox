function T_WD = TWD(s, zd, c_w, Q, x_E, K_r, H, x)
try
T_WD = 1/s*exp(-zd*s^0.5*tanh(s^0.5*c_w*Q*x_E/(2*K_r*H)))*(cosh(s^0.5*c_w*Q*x/(2*K_r*H))-tanh(s^0.5*c_w*Q*x_E/(2*K_r*H))*sinh(s^0.5*c_w*Q*x/(2*K_r*H)));
catch ex
    errmsg = ex.stack.line;
    msgbox([{'TWD.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end