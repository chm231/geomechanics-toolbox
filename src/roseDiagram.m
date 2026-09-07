% plot rose diagram of strike direction
% input: didData --> dip direction data in degree
% returns plot handle
function h = roseDiagram(didData)

try
    
strike(2*size(didData, 2)) = 0; % assigning the size of strike data
% for i = 1:size(didData, 2) % conversion of dip direction to strike
%     if mod(didData(i),10) == 0
%         didData(i) = didData(i)+0.01;
%     end
%     if (didData(i)>270) && (didData(i)<360)
%         strike(2*i-1) = didData(i)-90;
%         strike(2*i) = didData(i)-270;
%     elseif (didData(i)>=0) && (didData(i)<90)
%         strike(2*i-1) = didData(i)+90;
%         strike(2*i) = didData(i)+270;
%     else
%         strike(2*i-1) = didData(i)+90;
%         strike(2*i) = didData(i)-90;
%     end
% end

for i = 1:size(didData, 2)
    if mod(didData(i),10) == 0
        if didData(i) == 360
            didData(i) = didData(i)-359.999;
        else
            didData(i) = didData(i)+0.001;
        end
    end
    if (didData(i)>=270) && (didData(i)<360)
        strike(2*i-1) = didData(i)-90;
        strike(2*i) = didData(i)-270;
    elseif (didData(i)>=0) && (didData(i)<90)
        strike(2*i-1) = didData(i)+90;
        strike(2*i) = didData(i)+270;
    else
        strike(2*i-1) = didData(i)+90;
        strike(2*i) = didData(i)-90;
    end
end

theta = (90*ones(size(strike, 1),1)-strike)*pi/180;
h = rose(theta, 36);
%h = polar(tout, rout);

hHiddenText = findall(gca,'type','text');
Angles = 0 : 30 : 330;
hObjToDelete = zeros( length(Angles)-4, 1 );
k = 0;
for ang = Angles
   hObj = findall(hHiddenText,'string',num2str(ang));
   switch ang
   case 0
      set(hObj,'string','E','HorizontalAlignment','Left', 'fontsize', 12, 'fontweight', 'bold');
   case 90
      set(hObj,'string','N','VerticalAlignment','Bottom', 'fontsize', 12, 'fontweight', 'bold');
   case 180
      set(hObj,'string','W','HorizontalAlignment','Right', 'fontsize', 12, 'fontweight', 'bold');
   case 270
      set(hObj,'string','S','VerticalAlignment','Top', 'fontsize', 12, 'fontweight', 'bold');
   otherwise
      k = k + 1;
      hObjToDelete(k) = hObj;
   end
end
delete(hObjToDelete);
title('Direction of Strikes', 'fontweight', 'bold', 'fontsize', 14)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'roseDiagram.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end