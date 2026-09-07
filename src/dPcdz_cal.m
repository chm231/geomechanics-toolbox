%compute dpc the critical pressure gradient for shearing for the given
function dPcdz = dPcdz_cal(rho_r, jDip, jDipDirec, S123, Svmag, phi)
try
Pc = Pc_cal2(jDip, jDipDirec, S123, phi);
dPcdz = Pc/Svmag*rho_r*9.80665;
catch ex
    errmsg = ex.stack.line;
    msgbox([{'dPcdz_cal.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


