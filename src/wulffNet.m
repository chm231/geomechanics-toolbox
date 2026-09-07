% Wulff net rotated to arbitrary dip direction
% added by Sehyeok Park, May 2016
function h = wulffNet(did)

try
    
N = 50;
cx = cos(0:pi/N:2*pi);                           % points on circle
cy = sin(0:pi/N:2*pi);
xh = [-1 1]*sin(did);                                     % horizontal axis
yh = [-1 1]*cos(did);
xv = [-1 1]*cos(-did);                                      % vertical axis
yv = [-1 1]*sin(-did);
axis([-1 1 -1 1])
h{1} = plot(xh,yh,':k',xv,yv,':k');                     %plot axes
axis off
hold on
h{2} = plot(cx,cy,':k');                                %plot outter circle
psi = 0:pi/N:pi; % trend along great circle, measured from strike
for i = 1:8                                      %plot great circles
   di = i*(pi/18);                             % dip at 10 deg intervals
   adi = atan(tan(di)*sin(psi)); % apparent dip
   rproj = tan((pi/2 - adi)/2); % radius on the projection plane
   x1 = rproj.*(sin(psi)*sin(did)+cos(psi)*(-cos(did)));
   y1 = rproj.*(sin(psi)*cos(did)+cos(psi)*sin(did));
   x2 = -x1;
   y2 = -y1;
   h{2+i} = plot(x1,y1,':k',x2,y2,':k');
end
for i = 1:8                                     %plot small circles
   alpha = i*(pi/18);
   xlim = sin(alpha);
   x = [-xlim:xlim/25:xlim];
   d = 1/cos(alpha);
   rd = d*sin(alpha);
   y0 = sqrt(rd*rd - (x .* x));
   y1 = d - y0;
   x1 = x.*sin(did) + y1.*(-cos(did));
   y1 = x.*cos(did) + y1.*sin(did);
   x2 = -x1;
   y2 = -y1;
   h{10+i} = plot(x1,y1,':k',x2,y2,':k');
end
axis([-1.0 1.0 -1.1 1.2])
axis equal

catch ex
    errmsg = ex.stack.line;
    msgbox([{'wulffNet.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end