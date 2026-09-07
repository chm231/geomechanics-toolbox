%rock temperature distribution for Bodvarsson model

try

global Z X T
%% calculation
X(100, 100) = 0;
Z(100, 100) = 0;
T(100, 100) = 0;

for i = 1:101 % index for x
    for j = 1:101 % index for z
        x = z/400*(i-1);
        zz = z/100*(j-1);
        Z(i, j) = zz;
        X(i, j) = x;
        T(i, j) = bdv(x, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, zz, N, t_year);
    end
end

%% visualization
figure()
contourf(Z, X, T, 256, 'linestyle', 'none')
hold on
contourf(Z, -X, T, 256, 'linestyle', 'none')
colormap(jet(256))
caxis([T_wo T_ro])
h2 = colorbar;
ticks = T_wo:(T_ro-T_wo)/7:T_ro;
ticks = round(ticks, 2);
set(h2, 'ytick', ticks)
h2.Label.String = 'Outlet fluid temperature (กษ)';
h2.Label.FontSize = 12;
z = [0 z];
x = [0 0];
plot(z, x, 'k', 'linewidth', 0.5, 'linestyle', '--')
axis equal
xlabel('Distance along fracture (m)', 'fontsize', 12)
ylabel('Normal distance from fracture (m)', 'fontsize', 12)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'rockTemp_bdv.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end