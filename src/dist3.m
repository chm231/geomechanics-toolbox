function d = dist3(data, std)
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치
try
s = size(data);
k = zeros(s(1),1);
for i=1:size(data)
    k(i) = sqrt((data(i,1)-std(1))^2 + (data(i,2)-std(2))^2 + (data(i,3)-std(3))^2);
end
d = k;
catch ex
    errmsg = ex.stack.line;
    msgbox([{'dist3.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end