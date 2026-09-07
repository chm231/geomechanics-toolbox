function radial3D(Rf, R, W0, OU_L, SF)
try

vert(72,3) = 0;
faces(36,4) = 0;
for i = 1:36
    theta = pi/18*(i-1);
    vert(i,:) = [R*cos(theta) R*sin(theta) -0.5*Rf];
    vert(36+i,:) = [R*cos(theta) R*sin(theta) 0.5*Rf];
    faces(i,:) = [i 36+i 37+i i+1];
end
faces(36,:)=[36 72 37 1];
figure()
patch('vertices', vert, 'faces', faces, 'facevertexCdata', [0.7 0.7 0.7])
hold on
X3(73, 51) = 0;
Y3(73, 51) = 0;
Z3(73, 51) = 0;
for i = 1 : 73
    theta = pi/36*(i-1);
    r = linspace(R, Rf, 51);
    X3(i, :) = r.*cos(theta);
    Y3(i, :) = r.*sin(theta);
    Z3(i, :) = SF * W0/2*sqrt(1 - r./Rf);
end
surf(X3,Y3,Z3, 2*abs(Z3), 'facelighting', 'gouraud'), shading flat
Z3 = -Z3;
surf(X3,Y3,Z3, 2*abs(Z3), 'facelighting', 'gouraud'), shading flat
xlabel(strcat('Distance', ' (', OU_L, ')'), 'FontSize', 14)
ylabel(strcat('Distance', ' (', OU_L, ')'), 'FontSize', 14)
zlabel(strcat('Fracture Aperture', ' (', num2str(1/SF), '*', OU_L, ')'), 'FontSize', 14)
%colormap(jet(256))
wBar = colorbar;
[cmin cmax] = caxis;
caxis([cmin, SF*W0*sqrt(1 - R/Rf)])
wBar.Label.String = strcat('Fracture Aperture', ' (', num2str(1/SF), '*', OU_L, ')');
wBar.Label.FontSize = 14;
title('Radial fracture model', 'FontSize', 14)
alpha(0.7)
daspect([1 1 1])
view(135,25)
camlight

catch ex
    errmsg = ex.stack.line;
    msgbox([{'radial3D.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
