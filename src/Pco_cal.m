% compute pco (cut-off pressure for shearing with high tendency)
function Pco = Pco_cal(Pcm, alpha, sig3)
% compute pco, cut-off pressure for shearing with high tendencey
% alpha, the input coefficient

try
Pco = Pcm + alpha*(sig3-Pcm);
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Pco_cal.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end