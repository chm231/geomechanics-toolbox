function KGD3D(H, L, R, W0, OU_L, SF)
try
    
vert(72,3) = 0;
faces(36,4) = 0;
for i = 1:36
    theta = pi/18*(i-1);
    vert(i,:) = [R*cos(theta) R*sin(theta) -0.6*H];
    vert(36+i,:) = [R*cos(theta) R*sin(theta) 0.6*H];
    faces(i,:) = [i 36+i 37+i i+1];
end
faces(36,:)=[36 72 37 1];
figure()
patch('vertices', vert, 'faces', faces, 'facevertexCdata', [0.7 0.7 0.7])
hold on
i = 0;
X1(2,51) = 0;
Y1(2,51) = 0;
Z1(2,51) = 0;
ri = L*sqrt((4*R^2 - W0^2)/(4*L^2 - W0^2));
for r = linspace(ri, L, 51) 
    i = i+1;
    Wr = real(SF * W0/L * sqrt(L^2-r^2)); % maximum aperture at distance r
    for j = 1:2
        X1(j,i) = r;
        Y1(j,i) = Wr/2;
        Z1(j,i) = -H/2+H*(j-1);
    end
end
surf(X1,Y1,Z1, 2*abs(Y1), 'facelighting', 'gouraud'), shading flat
X1 = -X1;
surf(X1,Y1,Z1, 2*abs(Y1), 'facelighting', 'gouraud'), shading flat
Y1 = -Y1;
surf(X1,Y1,Z1, 2*abs(Y1), 'facelighting', 'gouraud'), shading flat
X1 = -X1;
surf(X1,Y1,Z1, 2*abs(Y1), 'facelighting', 'gouraud'), shading flat
xlabel(strcat('Distance', ' (', OU_L, ')'), 'FontSize', 14)
zlabel(strcat('Height', ' (', OU_L, ')'), 'FontSize', 14)
%colormap(jet(256))
wBar = colorbar;
[cmin cmax] = caxis;
caxis([cmin, SF*W0/L*sqrt(L^2-ri^2)])
wBar.Label.String = strcat('Fracture Aperture', ' (', num2str(1/SF), '*', OU_L, ')');
wBar.Label.FontSize = 14;
title('KGD fracture geometry', 'FontSize', 14)
alpha(0.7)
daspect([1 1 1])
view(135,25)
camlight

catch ex
    errmsg = ex.stack.line;
    msgbox([{'KGD3D.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end