% great circle for arbitrary dip and dip direction
% added by Sehyeok Park, May 2016
function h = wulffCircle(di, did, upper)

try
    
N = 50;
psi = 0:pi/N:pi; % trend along great circle, measured from strike
adi = atan(tan(di)*sin(psi)); % apparent dip
rproj = tan((pi/2-adi)/2); % radius on the projection plane
x = rproj.*(sin(psi)*sin(did)+cos(psi)*(-cos(did)));
y = rproj.*(sin(psi)*cos(did)+cos(psi)*sin(did));
if upper == 1
    x = -x;
    y = -y;
end
h = plot(x, y, 'r');
axis([-1.0 1.0 -1.1 1.2])
axis equal

catch ex
    errmsg = ex.stack.line;
    msgbox([{'wulffCircle.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end