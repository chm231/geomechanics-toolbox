%rock temperature distribution for Gringarten model

try
    
%% calculation
X(101, 101) = 0;
Z(101, 101) = 0;
T(101, 101) = 0;

if  N == 1
    for i = 1:101 % index for x
        for j = 1:101 % index for z
            x = z/400*(i-1);
            zz = z/100*(j-1);
            Z(i, j) = zz;
            X(i, j) = x;
            T(i, j) = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, zz, N, t_year, inf, x, T_wo, T_ro);
        end
    end
else
    for i = 1:101 % index for x
        for j = 1:101 % index for z
            x = x_E/100*(i-1);
            zz = z/100*(j-1);
            Z(i, j) = zz;
            X(i, j) = x;
            T(i, j) = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, zz, N, t_year, x_E, x, T_wo, T_ro);
        end
    end
end


%% visualization
figure()
if mod(N,2)==1
    for i=-(N-1)/2:(N-1)/2
        contourf(Z, X+2*x_E*i, T, 256, 'linestyle', 'none')
        hold on
        contourf(Z, -X+2*x_E*i, T, 256, 'linestyle', 'none')
        hold on
        plot([0 zz], [2*x_E*i 2*x_E*i],'k', 'linewidth', 0.5, 'linestyle', '--')
    end
elseif mod(N,2)==0
    for i=1:N/2
        contourf(Z, X+x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        contourf(Z, -X+x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        contourf(Z, X-x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        contourf(Z, -X-x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        plot([0 zz], [x_E*(2*i-1) x_E*(2*i-1)],'k', 'linewidth', 0.5, 'linestyle', '--')
        hold on
        plot([0 zz], [-x_E*(2*i-1) -x_E*(2*i-1)],'k', 'linewidth', 0.5, 'linestyle', '--')
    end
end
colormap(jet(256))
caxis([T_wo T_ro])
h2 = colorbar;
ticks = T_wo:(T_ro-T_wo)/7:T_ro;
ticks = round(ticks, 2);
set(h2, 'ytick', ticks)
h2.Label.String = 'Outlet fluid temperature (กษ)';
h2.Label.FontSize = 12;
axis equal
xlabel('Distance along fracture (m)', 'fontsize', 12)
ylabel('Normal distance from fracture (m)', 'fontsize', 12)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'rockTemp_grg.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end