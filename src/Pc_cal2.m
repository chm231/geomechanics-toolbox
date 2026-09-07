function Pc = Pc_cal2(jDip, jDipDirec, S123, phi)
% calculates critical pressure for shearing specifically oriented joint
% under given stress condition

try
    
jNormal = [sin(jDip)*sin(jDipDirec) sin(jDip)*cos(jDipDirec) cos(jDip)];
S1 = S123(1, 1); % S1 magnitude
S2 = S123(2, 1); % S2 magnitude
S3 = S123(3, 1); % S3 magnitude
S1_d = S123(1, 2:4); % direction of S1
S2_d = S123(2, 2:4); % direction of S2
S3_d = S123(3, 2:4); % direction of S3
l = dot(jNormal, S1_d)/norm(jNormal); % direction cosine to S1
m = dot(jNormal, S2_d)/norm(jNormal); % direction cosine to S2
n = dot(jNormal, S3_d)/norm(jNormal); % direction cosine to S3
sigma = l^2*S1 + m^2*S2 + n^2*S3; % resolved normal stress
tau = sqrt(((S1-S2)*l*m)^2 + ((S2-S3)*m*n)^2 + ((S3-S1)*n*l)^2); % resolved shear stress
Pc = sigma - tau/tan(phi); % critical pressure for shearing
slipTendency = tau/(sigma-41.18*10^6)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Pc_cal2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end