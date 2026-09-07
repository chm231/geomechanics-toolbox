%compute Pcm of most optimally oriented joint, for the given stress conditon
function Pcm = Pcm_cal(S1, S3, phi)
% to compute pcm most optimally oriented joint

try

c1 = S1/S3;
c2 = (1+sin(phi))/(1-sin(phi));
Pcm = (c2-c1)/(c2-1)*S3;

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Pcm_cal.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end