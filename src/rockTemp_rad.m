%rock temperature distribution for radial frature model

try
    
%% calculation
X(100, 100) = 0;
R(100, 100) = 0;
T(100, 100) = 0;

if N == 1
    for i = 1:101 % index for z
        for j = 1:101 % index for r
            x = z/400*(i-1);
            r_ = z/100*(j-1);
            X(i, j) = x;
            R(i, j) = r_;
            T(i, j) = radtal(Rho_r, c_w, c_r, K_r, Q_m, x, r_, N, t_year, 1.0e10, T_ro, T_wo);
        end
    end
else
    for i = 1:101 % index for z
        for j = 1:101 % index for r
            x = x_E/100*(i-1);
            r_ = z/100*(j-1);
            X(i, j) = x;
            R(i, j) = r_;
            T(i, j) = radtal(Rho_r, c_w, c_r, K_r, Q_m, x, r_, N, t_year, x_E, T_ro, T_wo);
        end
    end
end


%% visualization
figure()
if mod(N,2)==1
    for i=-(N-1)/2:(N-1)/2
        contourf(R, X+2*x_E*i, T, 256, 'linestyle', 'none')
        hold on
        contourf(R, -X+2*x_E*i, T, 256, 'linestyle', 'none')
        hold on
        plot([0 z], [2*x_E*i 2*x_E*i],'k', 'linewidth', 0.5, 'linestyle', '--')
    end
elseif mod(N,2)==0
    for i=1:N/2
        contourf(R, X+x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        contourf(R, -X+x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        contourf(R, X-x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        contourf(R, -X-x_E*(2*i-1), T, 256, 'linestyle', 'none')
        hold on
        plot([0 z], [x_E*(2*i-1) x_E*(2*i-1)],'k', 'linewidth', 0.5, 'linestyle', '--')
        hold on
        plot([0 z], [-x_E*(2*i-1) -x_E*(2*i-1)],'k', 'linewidth', 0.5, 'linestyle', '--')
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
    msgbox([{'rockTemp_rad.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end