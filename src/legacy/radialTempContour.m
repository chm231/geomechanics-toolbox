Rho_r = 2628;
c_w = 4178;
c_r = 800;
K_r = 3.018;
Q_m = 10;
z = 0;
N = 1;
x_E = 1.0e10;
T_ro = 150;
T_wo = 10;

t_year = 7/360;

for i = 1:111
    r = i-1;
    T_(i) = radtal(Rho_r, c_w, c_r, K_r, Q_m, z, r, N, t_year, x_E, T_ro, T_wo);
end

for j = 1:101
    theta = 2*pi/100*(j-1);
    r = 0:110;
    X(j,:) = r.*cos(theta);
    Y(j,:) = r.*sin(theta);
    Z(j,:) = r.*0;
    T(j,:) = T_;
end

surf(X, Y, Z, T, 'LineStyle', 'None')
colormap(jet(256))
c = colorbar('southoutside');
c.Label.String = sprintf('Temperature on the fracture surface (%cC)', char(176));
c.Label.FontSize = 14;
c.FontSize = 12;
set(gca, 'FontSize', 12)
daspect([1 1 1])