function PKN3D(H, L, R, W0, OU_L, SF)
try
    
vert(72,3) = 0;
faces(36,4) = 0;
for i = 1:36
    theta = pi/18*(i-1);
    vert(i,:) = [R*cos(theta) R*sin(theta) -2*H];
    vert(36+i,:) = [R*cos(theta) R*sin(theta) 2*H];
    faces(i,:) = [i 36+i 37+i i+1];
end
faces(36,:)=[36 72 37 1];
figure()
patch('vertices', vert, 'faces', faces, 'facevertexCdata', [0.7 0.7 0.7])
hold on
X(51,51) = 0;
Y(51,51) = 0;
Z(51,51) = 0;
i = 0;
for r = linspace(0, L, 51)
    i = i+1;
    Wr = SF*W0*(1 - r/L)^0.25; % maximum aperture at distance r
    if r == L
        Wr = 0;
    end
    h = linspace(-H/2, H/2, 51);
    Wh = Wr*sqrt(1-(2*h/H).^2); %aperture at distance r, height h
    for j = 1:51
        X(j,i) = R+r;
    end
    Y(:,i) = Wh/2;
    Z(:,i) = h;
end

surf(X,Y,Z, 2*abs(Y), 'facelighting', 'gouraud'), shading flat
X = -X;
surf(X,Y,Z, 2*abs(Y), 'facelighting', 'gouraud'), shading flat
Y = -Y;
surf(X,Y,Z, 2*abs(Y), 'facelighting', 'gouraud'), shading flat
X = -X;
surf(X,Y,Z, 2*abs(Y), 'facelighting', 'gouraud'), shading flat
xlabel(strcat('Distance', ' (', OU_L, ')'), 'fontsize', 14)
zlabel(strcat('Height', ' (', OU_L, ')'), 'fontsize', 14)
%colormap(jet(256))
wBar = colorbar;
[cmin cmax] = caxis;
caxis([cmin, SF*W0])
wBar.Label.String = strcat('Fracture Aperture', ' (', num2str(1/SF), '*', OU_L, ')');
wBar.Label.FontSize = 14;
title('PKN fracture geometry', 'fontsize', 14, 'fontweight', 'bold')
daspect([1 1 1])
alpha(0.7)
view(135,25)
camlight

catch ex
    errmsg = ex.stack.line;
    msgbox([{'PKN3D.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end