function radial_gringarten = radtal(Rho_r, c_w, c_r, K_r, Q_m, z, r, N, t_year, x_E, T_ro, T_wo)

try
    
Rho_w=1000; %Fluid density; no influence on results (kg/m3)
b=10; %Aperture; no influence on results
tdstar_=K_r*t_year*(365*86400)/(Rho_r*c_r*x_E^2); %Dimensionless time
theta = (Rho_w*c_w)/(Rho_r*c_r)*(2*b)/x_E; %Dimensionless energy potential
ep=K_r*pi*r^2*(2+theta)/(c_w*(Q_m/N)*x_E); %Dimensionless distance
H=z/x_E; %Dimensionless vertical distance


f = @(s) radTWD(s, theta, ep, H);
T_WD = talbot_inversion(f, tdstar_);
Txzt = T_ro + (T_wo-T_ro) * T_WD;
radial_gringarten=Txzt;

catch ex
    errmsg = ex.stack.line;
    msgbox([{'radtal.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end