function [ tre, plu ] = convert_VecTP( x, y, z )
%VEC_TO_TREPLU 이 함수의 요약 설명 위치
%   자세한 설명 위치

try
    
num = size(x,1);

for i = 1:num
    if x(i) == 0 % pole on the NS line
        if y(i) > 0
            tre(i) = 0;
        else
            tre(i) = pi;
        end
    elseif y(i) == 0 % pole on the WE line
        if x(i) > 0
            tre(i) = pi/2;
        else
            tre(i) = 3*pi/2;
        end
    else
        if x(i) < 0
            tre(i) = atan(y(i)/x(i)) + pi;
        else
            tre(i) = atan(y(i)/x(i));
        end
    end
    plu(i) = asin(z(i));

    if plu(i) < 0
        if tre(i) >= pi
            tre(i) = tre(i) - pi;
        else
            tre(i) = tre(i) + pi;
        end
        plu(i) = -plu(i);
    end
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'convert_VecTP.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
