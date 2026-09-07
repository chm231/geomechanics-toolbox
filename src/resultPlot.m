function resultPlot(x, xLabel, xOU, y, yLabel, yOU)

try

figure()
plot(x, y)
xlabel(strcat(xLabel, ' (', xOU, ')'), 'fontsize', 14)
ylabel(strcat(yLabel, ' (', yOU, ')'), 'fontsize', 14)
grid on

catch ex
    errmsg = ex.stack.line;
    msgbox([{'resultPlot.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end