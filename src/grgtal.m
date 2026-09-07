function gringarten = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year, x_E, x, T_wo, T_ro)
try
Q=Q_m./((N*L)); % Volumetric flow rate per fracture per unit thickness (m©÷/s)
H=6;
zd=z./H;
tdstar_=t_year./(((K_r.*Rho_r.*c_r).*H.^2*4)./(c_w.^2*Q.^2)./(365*86400));
f = @(s) TWD(s, zd, c_w, Q, x_E, K_r, H, x);

T_WD = talbot_inversion(f, tdstar_);
Txzt = T_ro + (T_wo-T_ro) * T_WD;
gringarten=Txzt;
catch ex
    errmsg = ex.stack.line;
    msgbox([{'grgtal.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
