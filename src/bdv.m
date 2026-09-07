function bodvarsson = bdv(x, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year)

try
    
%example 
%T_wo=60; % Injection water temperature (¡É)
%T_ro=180; % Initial rock temperature (¡É)
%Rho_r=2500; % Density of rock (kg/m©ø)
%c_w=4178; % Specific heat of water (J/kg¡¤K)
%c_r=800; % Specific heat of rock (J/kg¡¤K)
%K_r=3.5; % Thermal conductivity of rock (W/m¡¤¡É)
%Q_m=60; % Mass flow rate
%L=1000; % Fracture length (m)
%z=600; % Distance from injection (m)
%N=1; % The nubmber of fractures
%t_year=50;

% x: depth into rock matrix from fracture surface
% x = 0: fracture surface temp. = water temp.
% x > 0: rock matrix temp.

q=Q_m/(N*L); % mass flow rate per fracture per unit thickness
alpha = 2*K_r/(c_w*q);
a = K_r/(Rho_r*c_r); % thermal diffusivity of rock
t = t_year*365*86400; % time (sec)
Txzt = T_ro + (T_wo-T_ro).*erfc((alpha*z+x)./(2*sqrt(a*t)));  

bodvarsson = Txzt;

catch ex
    errmsg = ex.stack.line;
    msgbox([{'bdv.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end