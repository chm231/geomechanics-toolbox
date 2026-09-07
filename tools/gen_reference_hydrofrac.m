% Generates tests/reference/hydrofrac_matlab.json from the original MATLAB
% functions (PKN_C, KGD_C, radial_C + closed-form expressions in HFsim.m).
% Run from repo root:  matlab -batch "run('tools/gen_reference_hydrofrac.m')"
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'src'));
cases = struct([]);
base = struct('E', 20e9, 'nu', 0.25, 'Q', 0.05, 'mu', 0.1, 'h', 30, 't_f', 3600);
k = 0;
for model = {'PKN', 'KGD', 'radial'}
    for lk = [0 1]
        m = model{1};
        if strcmp(m, 'radial') && lk == 0, continue; end
        p = base; if lk, p.C = 1e-4; p.Sp = 1e-3; else, p.C = 0; p.Sp = 0; end
        E = p.E; nu = p.nu; Q = p.Q; mu = p.mu; C = p.C; Sp = p.Sp; h = p.h; t_f = p.t_f;
        t = 1 : (t_f - 1)/200 : t_f;
        Wmax = zeros(1, 201); L = zeros(1, 201); Pnet = zeros(1, 201);
        switch m
            case 'PKN'
                if ~lk
                    L = 0.39 * (E*Q^3 / ((1 - nu^2)*mu*h^4))^0.2 * t.^0.8;
                    Wmax = 2.18 * ((1 - nu^2)*mu*Q^2 / (E*h))^0.2 * t.^0.2;
                    Pnet = 1.09 * (E^4*mu*Q^2 / ((1-nu^2)^4*h^6))^0.2 * t.^0.2;
                else
                    for i = 1:201, [Wmax(i), L(i), Pnet(i)] = PKN_C(E, nu, Q, mu, C, Sp, h, t(i)); end
                end
                Wbar = Wmax * pi / 5;
            case 'KGD'
                if ~lk
                    L = 0.38 * (E*Q^3/((1-nu^2)*mu*h^3))^(1/6) * t.^(2/3);
                    Wmax = 1.67 * ((1-nu^2)*mu*Q^3/(E*h^3))^(1/6) * t.^(1/3);
                    Pnet = 1.09 * (mu*E^2/(1-nu^2)^2)^(1/3) * t.^(-1/3);
                else
                    for i = 1:201, [Wmax(i), L(i), Pnet(i)] = KGD_C(E, nu, Q, mu, C, Sp, h, t(i)); end
                end
                Wbar = Wmax * pi / 4;
            case 'radial'
                for i = 1:201, [Wmax(i), L(i), Pnet(i)] = radial_C(E, nu, Q, mu, C, Sp, t(i)); end
                Wbar = Wmax * 8 / 15;
        end
        k = k + 1;
        cases(k).model = m; cases(k).params = p; cases(k).leakoff = lk;
        cases(k).t = t; cases(k).L = L; cases(k).Wmax = Wmax; cases(k).Wbar = Wbar;
        cases(k).Pnet = Pnet; cases(k).V = Q * t;
    end
end
out = fullfile(root, 'tests', 'reference', 'hydrofrac_matlab.json');
fid = fopen(out, 'w'); fwrite(fid, jsonencode(cases), 'char'); fclose(fid);
fprintf('wrote %s (%d cases)\n', out, k);
