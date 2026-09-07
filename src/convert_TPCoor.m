function [ x, y ] = convert_TPCoor( tre, plu, upper, equalAngle )
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치

try
    
num = size(tre, 2);
x = zeros(num, 1);
y = zeros(num, 1);

if upper == 1
    if equalAngle == 1 % upper hemisphere, equal angle
        x = -cos(0.5*pi-tre).*tan(0.25*pi-0.5*plu);
        y = -sin(0.5*pi-tre).*tan(0.25*pi-0.5*plu);
    else % upper hemisphere, equal area
        x = -1.41421356*cos(0.5*pi-tre).*cos(0.25*pi+0.5*plu);
        y = -1.41421356*sin(0.5*pi-tre).*cos(0.25*pi+0.5*plu);
    end
else
    if equalAngle == 1 % lower hemisphere, equal angle
        x = cos(0.5*pi-tre).*tan(0.25*pi-0.5*plu);
        y = sin(0.5*pi-tre).*tan(0.25*pi-0.5*plu);
    else  % lower hemisphere, equal 
        x = 1.41421356*cos(0.5*pi-tre).*cos(0.25*pi+0.5*plu);
        y = 1.41421356*sin(0.5*pi-tre).*cos(0.25*pi+0.5*plu);
    end 
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'convert_TPCoor.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end