% Generates tests/reference/mohr_aniso_matlab.json.
% The computational parts of Mohr_Circle.mlapp (AddplotButtonPushed),
% Mohr_Sub.mlapp (startupFcn) and anisotropy.mlapp (aniso) are copied verbatim
% below as plain functions so they can run without the App Designer UI.
% Run from repo root:  matlab -batch "run('tools/gen_reference_mohr_aniso.m')"
root = fileparts(fileparts(mfilename('fullpath')));
out = struct();

% ---- Mohr circle cases: [sigma_x sigma_y sigma_z n_x n_y n_z]
M = [90 51.5 88.2 1 1 1;
     100 60 30 1 0 0.5;
     30 100 60 0.3 0.7 0.2;
     50 50 20 1 1 1;
     80 40 10 0 1 1;
     100 60 30 2 3 4];
for k = 1:size(M, 1)
    [sn, tn, xt, yt, xp, yp, tv, nv, sv] = mohr_case(M(k, 1), M(k, 2), M(k, 3), M(k, 4), M(k, 5), M(k, 6));
    out.mohr(k).inputs = M(k, :);
    out.mohr(k).sigma_n = sn; out.mohr(k).tau_n = tn;
    out.mohr(k).p_theta = [xt yt]; out.mohr(k).p_phi = [xp yp];
    out.mohr(k).traction = tv(:)'; out.mohr(k).normal_vec = nv(:)'; out.mohr(k).shear_vec = sv(:)';
    fprintf('mohr %d: sigma_n=%.6f tau_n=%.6f\n', k, sn, tn);
end

% ---- anisotropy cases: [frac_cohesion frac_fric_ang rock_cohesion rock_fric_ang sigma_3]
A = [1 30 10 35 5;
     0 20 20 40 0;
     2 35 15 30 10;
     0.5 25 30 45 20];
for k = 1:size(A, 1)
    y = aniso(A(k, 1), A(k, 2), A(k, 3), A(k, 4), A(k, 5));
    out.aniso(k).inputs = A(k, :);
    out.aniso(k).beta = (1:899) / 10;
    out.aniso(k).sigma_1 = y;
    fprintf('aniso %d: min=%.4f max=%.4f\n', k, min(y), max(y));
end

f = fullfile(root, 'tests', 'reference', 'mohr_aniso_matlab.json');
fid = fopen(f, 'w'); fwrite(fid, jsonencode(out), 'char'); fclose(fid);
fprintf('wrote %s\n', f);

% =====================================================================
function [x_intersect1, y_intersect1, x_theta, y_theta, x_phi, y_phi, traction_vector, normal_stress_vector, shear_vector] = ...
        mohr_case(sigma_x, sigma_y, sigma_z, n_x, n_y, n_z)
    % --- Mohr_Circle.mlapp / AddplotButtonPushed (computation only) ---
    sigmas = sort([sigma_x, sigma_y, sigma_z], 'descend');
    sigma_1 = sigmas(1); sigma_2 = sigmas(2); sigma_3 = sigmas(3);
    size_n = sqrt(n_x^2 + n_y^2 + n_z^2);
    if sigma_x >= sigma_y && sigma_x >= sigma_z, n_max = n_x;
    elseif sigma_y >= sigma_x && sigma_y >= sigma_z, n_max = n_y;
    else, n_max = n_z; end
    if sigma_x <= sigma_y && sigma_x <= sigma_z, n_min = n_x;
    elseif sigma_y <= sigma_x && sigma_y <= sigma_z, n_min = n_y;
    else, n_min = n_z; end
    phi = acos(n_max / size_n);
    theta = acos(n_min / size_n);
    center_xy = (sigma_1 + sigma_2) / 2;  radius_xy = abs(sigma_2 - sigma_1) / 2;
    center_yz = (sigma_2 + sigma_3) / 2;  radius_yz = abs(sigma_3 - sigma_2) / 2;
    x_phi = center_xy + radius_xy * cos(2 * phi);
    y_phi = radius_xy * sin(2 * phi);
    x_theta = center_yz - radius_yz * cos(2 * theta);
    y_theta = radius_yz * sin(2 * theta);
    radius_theta_circle = sqrt((x_theta - center_xy)^2 + (y_theta - 0)^2);
    radius_phi_circle = sqrt((x_phi - center_yz)^2 + (y_phi - 0)^2);
    d = abs(center_xy - center_yz);
    a = (radius_theta_circle^2 - radius_phi_circle^2 + d^2) / (2 * d);
    h = sqrt(radius_theta_circle^2 - a^2);
    x2 = center_xy + a * (center_yz - center_xy) / d;
    x_intersect1 = x2 + h * (0 - 0) / d;
    y_intersect1 = 0 + h;
    % --- Mohr_Sub.mlapp / startupFcn (vectors) ---
    normal_stress = x_intersect1;
    unit_normal_vector = [n_x, n_y, n_z] / norm([n_x, n_y, n_z]);
    normal_stress_vector = -(normal_stress * unit_normal_vector);
    stress_matrix = diag([-sigma_x, -sigma_y, -sigma_z]);
    traction_vector = stress_matrix * unit_normal_vector';
    shear_vector = traction_vector - normal_stress_vector';
end

function y = aniso(frac_cohesion, frac_fric_ang, rock_cohesion, rock_fric_ang, sigma_3)
    % --- anisotropy.mlapp / aniso (verbatim) ---
    UCS = 2*rock_cohesion*cos(deg2rad(rock_fric_ang))/(1-sin(deg2rad(rock_fric_ang)))+sigma_3*(tand(45+rock_fric_ang/2))^2;
    y = zeros(1, length(1:1:89));
    for i = 1:899
        arad = i/10;
        y(i) = (frac_cohesion*cosd(frac_fric_ang)+sigma_3*sind(arad+frac_fric_ang)*cosd(arad))/(cosd(arad+frac_fric_ang)*sind(arad));
        if y(i) > UCS
            y(i) = UCS;
        elseif arad > 90-frac_fric_ang
            y(i) = UCS;
        end
    end
end
