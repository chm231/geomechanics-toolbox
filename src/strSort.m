function S123 = strSort(Svmag, SHmaxmag, SHmaxazi, Shminmag)

try

Svhmaxmin = [Svmag 0 0 1; SHmaxmag sin(SHmaxazi) cos(SHmaxazi) 0; Shminmag sin(SHmaxazi+pi/2) cos(SHmaxazi+pi/2) 0];
% [temp, I] = sort(Svhmaxmin(:, 1), 'descend');
% S123 = Svhmaxmin(I, :); 
% each row: [stressMagnitude  directionVector]
% S123(1, :) --> sigma1, S123(2, :) -->sigma2, S123(3, :) --> sigma3

S123 = sortrows(Svhmaxmin, 'descend');

catch ex
    errmsg = ex.stack.line;
    msgbox([{'strSort.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end