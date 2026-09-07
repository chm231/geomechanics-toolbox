% schmidt -- Script for plotting a Schmidt net
% to plot points, first calculate theta = pi*(90-azimuth)/180
% then rho = sqrt(2)*sin(pi*(90-dip)/360), and finally the components
% xp = rho*cos(theta) and yp = rho*cos(theta)
% or use snetplot to plot from a file
clear; help schmidt;
N = 50;
cx = cos(0:pi/N:2*pi);                           % points on circle
cy = sin(0:pi/N:2*pi);
xh = [-1 1];                                     % horizontal axis
yh = [0 0];
xv = [0 0];                                      % vertical axis
yv = [-1 1];
axis([-1 1 -1 1]);
axis('square');
plot(xh,yh,'-g',xv,yv,'-g');                     %plot green axes
axis off;
hold on;
plot(cx,cy,'-w');                                %plot white circle
psi = [0:pi/N:pi];
for i = 1:8                                      %plot great circles
   rdip = i*(pi/18);                             %at 10 deg intervals
   radip = atan(tan(rdip)*sin(psi));
   rproj = sqrt(2)*sin((pi/2 - radip)/2);
   x1 = rproj .* sin(psi);
   x2 = rproj .* (-sin(psi));
   y = rproj .* cos(psi);
   plot(x1,y,':r',x2,y,':r');
end
for i = 1:8                                     %plot small circles
   alpha = i*(pi/18);
   xlim = sin(alpha);
   ylim = cos(alpha);
   x = [-xlim:xlim/50:xlim];
   psi = atan(x./ylim); % trend along small circle
   rproj = sqrt(1-abs(sqrt(1-ylim^2-x.*x))); % radius
   x1 = rproj.*sin(psi);
   y1 = rproj.*cos(psi);
   x2 = -x1;
   y2 = -y1;
   plot(x1, y1, ':r', x2, y2, ':r')

end

axis('square');

%% great circle for arbitrary dip and dip direction
% added by Sehyeok Park, May 2016
N = 50;
cx = cos(0:pi/N:2*pi);                           % points on circle
cy = sin(0:pi/N:2*pi);
xh = [-1 1];                                     % horizontal axis
yh = [0 0];
xv = [0 0];                                      % vertical axis
yv = [-1 1];
axis([-1 1 -1 1]);
axis('square');
plot(xh,yh,'-g',xv,yv,'-g');                     %plot green axes
axis off;
hold on;
plot(cx,cy,'-w');                                %plot white circle

di = 30 *pi/180; % dip
did = 0 *pi/180; % dip direction

psi = 0:pi/N:pi; % trend along great circle, measured from strike
adi = atan(tan(di)*sin(psi)); % apparent dip
rproj = sqrt(2)*sin((pi/2 - adi)/2); % radius on the projection plane
x = rproj.*(sin(psi)*sin(did)+cos(psi)*(-cos(did)));
y = rproj.*(sin(psi)*cos(did)+cos(psi)*sin(did));
plot(x, y, 'b')
axis equal

%% Schmidt net for arbitrary dip direction
% added by Sehyeok Park, May 2016
did = 40*pi/180; % dip direction

N = 50;
cx = cos(0:pi/N:2*pi);                           % points on circle
cy = sin(0:pi/N:2*pi);
xh = [-1 1]*sin(did);                                     % horizontal axis
yh = [-1 1]*cos(did);
xv = [-1 1]*cos(-did);                                      % vertical axis
yv = [-1 1]*sin(-did);
axis([-1 1 -1 1])
plot(xh,yh,':k',xv,yv,':k')                     %plot axes
axis off
hold on
plot(cx,cy,':k')                                %plot outter circle
psi = 0:pi/N:pi; % trend along great circle, measured from strike
for i = 1:8                                      %plot great circles
   di = i*(pi/18);                             % dip at 10 deg intervals
   adi = atan(tan(di)*sin(psi)); % apparent dip
   rproj = sqrt(2)*sin((pi/2 - adi)/2); % radius on the projection plane
   x1 = rproj.*(sin(psi)*sin(did)+cos(psi)*(-cos(did)));
   y1 = rproj.*(sin(psi)*cos(did)+cos(psi)*sin(did));
   x2 = -x1;
   y2 = -y1;
   plot(x1,y1,':k',x2,y2,':k');
end
for i = 1:8                                     %plot small circles
   alpha = i*(pi/18);
   xlim = sin(alpha);
   ylim = cos(alpha);
   x = [-xlim:xlim/50:xlim];
   psi = atan(x./ylim); % trend along small circle
   rproj = sqrt(1-abs(sqrt(1-ylim^2-x.*x))); % radius
   x1 = rproj.*sin(psi)*sin(did)+rproj.*cos(psi)*(-cos(did));
   y1 = rproj.*sin(psi)*cos(did)+rproj.*cos(psi)*sin(did);
   x2 = -x1;
   y2 = -y1;
   plot(x1, y1, ':k', x2, y2, ':k')
end
axis equal
hold off
