function [optJ1txt, optJ2txt] = optJD(S123, phi)
% returns optimal joint orientations for shearing under given stress

try
    
% conditions
S1_d = S123(1, 2:4);
S3_d = S123(3, 2:4);
jNormal1 = S1_d*cos(pi/4+phi/2) + S3_d*sin(pi/4+phi/2);
jNormal2 = S1_d*cos(pi/4+phi/2) - S3_d*sin(pi/4+phi/2);
[az1, elev1, r1] = cart2sph(jNormal1(1), jNormal1(2), jNormal1(3));
[az2, elev2, r2] = cart2sph(jNormal2(1), jNormal2(2), jNormal2(3));
optJ1 = [pi/2 - elev1 pi/2 - az1] * 180/pi;
optJ2 = [pi/2 - elev2 pi/2 - az2] * 180/pi;
if optJ1(1) < 0
    if optJ1(2) > -180 && optJ1(2) <= 180
        optJ1(2) = optJ1(2) + 180;
    elseif optJ1(2) > 180 && optJ1(2) <= 360
        optJ1(2) = optJ1(2) - 180;
    end
    optJ1(1) = - optJ1(1);
elseif optJ1(2) < 0
    optJ1(2) = optJ1(2) + 360;
end
if optJ2(1) < 0
    if optJ2(2) > -180 && optJ2(2) <= 180
        optJ2(2) = optJ2(2) + 180;
    elseif optJ2(2) > 180 && optJ2(2) <= 360
        optJ2(2) = optJ2(2) - 180;
    end
    optJ2(1) = - optJ2(1);
elseif optJ2(2) < 0
    optJ2(2) = optJ2(2) + 360;
end
optJ1txt = sprintf('(%.2f, %.2f),', round(optJ1(1), 2), round(optJ1(2), 2));
optJ2txt = sprintf('(%.2f, %.2f)', round(optJ2(1), 2), round(optJ2(2), 2));

catch ex
    errmsg = ex.stack.line;
    msgbox([{'optJD.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end