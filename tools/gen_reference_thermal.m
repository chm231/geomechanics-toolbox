% Generates tests/reference/thermal_matlab.json from the original MATLAB
% functions bdv / grgtal / radtal (+ talbot_inversion, TWD, radTWD) and the
% grid definitions of rockTemp_bdv / rockTemp_grg / rockTemp_rad.
% Run from repo root:  matlab -batch "run('tools/gen_reference_thermal.m')"
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'src'));

% base A: example in bdv.m ; base B: reservTemp_projects/saveTest.txt (Gringarten, 161.67 degC)
A = struct('c_r', 800, 'c_w', 4178, 'rho_r', 2500, 'K_r', 3.5, 'T_ro', 180, 'T_wo', 60, ...
           'L', 1000, 'Q_m', 60, 'N', 1, 'spacing', 60, 'z', 600, 't_year', 50);
B = struct('c_r', 800, 'c_w', 4178, 'rho_r', 2628, 'K_r', 3.018, 'T_ro', 180, 'T_wo', 60, ...
           'L', 600, 'Q_m', 40, 'N', 5, 'spacing', 60, 'z', 800, 't_year', 30);
B1 = B; B1.N = 1;

specs = {'bodvarsson', A; 'gringarten', B; 'radial', B; 'gringarten', B1; 'radial', B1};
cases = struct([]);
sub = 1:10:101;   % grid subsample stored in the JSON
for k = 1:size(specs, 1)
    m = specs{k, 1}; p = specs{k, 2};
    c_r = p.c_r; c_w = p.c_w; Rho_r = p.rho_r; K_r = p.K_r; T_ro = p.T_ro; T_wo = p.T_wo;
    L = p.L; Q_m = p.Q_m; N = p.N; x_E = p.spacing / 2; z = p.z; t_year = p.t_year;
    zs = 0 : 1000/500 : 1000;    % distance profile
    ts = 1 : 49/500 : 50;        % time profile
    switch m
        case 'bodvarsson'
            outlet = bdv(0, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year);
            prof_z = bdv(0, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, zs, N, t_year);
            prof_t = bdv(0, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, z, N, ts);
            T = zeros(101); X = zeros(101); Z = zeros(101);
            for i = 1:101, for j = 1:101
                x = z/400*(i-1); zz = z/100*(j-1); X(i,j) = x; Z(i,j) = zz;
                T(i,j) = bdv(x, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, zz, N, t_year);
            end, end
        case 'gringarten'
            outlet = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year, x_E, 0, T_wo, T_ro);
            prof_z = zeros(size(zs)); for j = 1:numel(zs), prof_z(j) = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, zs(j), N, t_year, x_E, 0, T_wo, T_ro); end
            prof_t = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, z, N, ts, x_E, 0, T_wo, T_ro);
            T = zeros(101); X = zeros(101); Z = zeros(101);
            for i = 1:101, for j = 1:101
                if N == 1, x = z/400*(i-1); xe = inf; else, x = x_E/100*(i-1); xe = x_E; end
                zz = z/100*(j-1); X(i,j) = x; Z(i,j) = zz;
                T(i,j) = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, zz, N, t_year, xe, x, T_wo, T_ro);
            end, end
        case 'radial'
            outlet = radtal(Rho_r, c_w, c_r, K_r, Q_m, 0, z, N, t_year, x_E, T_ro, T_wo);
            prof_z = zeros(size(zs)); for j = 1:numel(zs), prof_z(j) = radtal(Rho_r, c_w, c_r, K_r, Q_m, 0, zs(j), N, t_year, x_E, T_ro, T_wo); end
            prof_t = radtal(Rho_r, c_w, c_r, K_r, Q_m, 0, z, N, ts, x_E, T_ro, T_wo);
            T = zeros(101); X = zeros(101); Z = zeros(101);
            for i = 1:101, for j = 1:101
                if N == 1, x = z/400*(i-1); xe = 1.0e10; else, x = x_E/100*(i-1); xe = x_E; end
                r_ = z/100*(j-1); X(i,j) = x; Z(i,j) = r_;
                T(i,j) = radtal(Rho_r, c_w, c_r, K_r, Q_m, x, r_, N, t_year, xe, T_ro, T_wo);
            end, end
    end
    cases(k).model = m; cases(k).params = p;
    cases(k).outlet = outlet;
    cases(k).prof_z_x = zs; cases(k).prof_z = prof_z(:)';
    cases(k).prof_t_x = ts; cases(k).prof_t = prof_t(:)';
    cases(k).grid_idx = sub - 1;
    cases(k).grid_normal = X(sub, sub); cases(k).grid_along = Z(sub, sub); cases(k).grid_T = T(sub, sub);
    fprintf('%s N=%d outlet=%.4f\n', m, N, outlet);
end
out = fullfile(root, 'tests', 'reference', 'thermal_matlab.json');
fid = fopen(out, 'w'); fwrite(fid, jsonencode(cases), 'char'); fclose(fid);
fprintf('wrote %s (%d cases)\n', out, numel(cases));
