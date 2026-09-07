function varargout = threeddfngui(varargin)
% THREEDDFNGUI MATLAB code for threeddfngui.fig
%      THREEDDFNGUI, by itself, creates a new THREEDDFNGUI or raises the existing
%      singleton*.
%
%      H = THREEDDFNGUI returns the handle to a new THREEDDFNGUI or the handle to
%      the existing singleton*.
%
%      THREEDDFNGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THREEDDFNGUI.M with the given input arguments.
%
%      THREEDDFNGUI('Property','Value',...) creates a new THREEDDFNGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before threeddfngui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to threeddfngui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help threeddfngui

% Last Modified by GUIDE v2.5 27-Mar-2017 14:50:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threeddfngui_OpeningFcn, ...
                   'gui_OutputFcn',  @threeddfngui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before threeddfngui is made visible.
function threeddfngui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to threeddfngui (see VARARGIN)

% Choose default command line output for threeddfngui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes threeddfngui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

try

global h_threeddfngui    

h_threeddfngui.fnum = handles.fnum; 

set(handles.fsize_ne, 'value', 1)
set(handles.len, 'enable', 'on')
set(handles.fnum, 'enable', 'on')
set(handles.fsize_plaw, 'value', 0)
set(handles.fracd, 'enable', 'off')
set(handles.trim, 'enable', 'off')
set(handles.curt, 'enable', 'off')
set(handles.checkfnum, 'enable', 'off')

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Outputs from this function are returned to the command line.
function varargout = threeddfngui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function x0_Callback(hObject, eventdata, handles)
% hObject    handle to x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x0 as text
%        str2double(get(hObject,'String')) returns contents of x0 as a double


% --- Executes during object creation, after setting all properties.
function x0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y0_Callback(hObject, eventdata, handles)
% hObject    handle to y0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y0 as text
%        str2double(get(hObject,'String')) returns contents of y0 as a double


% --- Executes during object creation, after setting all properties.
function y0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z0_Callback(hObject, eventdata, handles)
% hObject    handle to z0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z0 as text
%        str2double(get(hObject,'String')) returns contents of z0 as a double


% --- Executes during object creation, after setting all properties.
function z0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in oripop.
function oripop_Callback(hObject, eventdata, handles)
% hObject    handle to oripop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns oripop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from oripop


% --- Executes during object creation, after setting all properties.
function oripop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oripop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip_Callback(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip as text
%        str2double(get(hObject,'String')) returns contents of dip as a double


% --- Executes during object creation, after setting all properties.
function dip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dipd_Callback(hObject, eventdata, handles)
% hObject    handle to dipd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dipd as text
%        str2double(get(hObject,'String')) returns contents of dipd as a double


% --- Executes during object creation, after setting all properties.
function dipd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gener.
function gener_Callback(hObject, eventdata, handles)
% hObject    handle to gener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global x0 y0 z0 x1 y1 z1 n fracd trim curt rotz3 rotx3 rotx2 rotz2 swd P2 P1 swdip swdipd l1 dip2 dipd2 rfk K ...
    temp1pop temp3pop temp4pop l ap apmean apstdv SW SW2 SWV eqa eqb eqc swa swb swc CC domx domy domz
x0 = str2double(get(handles.x0,'String')); % 도메인의 크기 정의
y0 = str2double(get(handles.y0,'String'));
z0 = str2double(get(handles.z0,'String'));
domx = str2double(get(handles.domx,'String'));
domy = str2double(get(handles.domy,'String'));
domz = str2double(get(handles.domz,'String'));
n = str2double(get(handles.fnum,'String'));
dip = str2double(get(handles.dip,'String'))*pi/180;
dipd = str2double(get(handles.dipd,'String'))*pi/180;
swdip = str2double(get(handles.swdip,'String'))*pi/180;
swdipd = str2double(get(handles.swdipd,'String'))*pi/180;
swd = str2double(get(handles.swd,'String'));
apmean = str2double(get(handles.apmean,'String'));
apstdv = str2double(get(handles.apstdv,'String'));
shapepop = cellstr(get(handles.shapepop,'String'));
temp3pop = shapepop(get(handles.shapepop,'Value'));
oripop = cellstr(get(handles.oripop,'String')); % 방향 분포 선택 및 dip, dip direction 입력
temp1pop = oripop(get(handles.oripop,'Value'));
appop = cellstr(get(handles.appop,'String'));
temp4pop = appop(get(handles.appop,'Value'));
K = str2double(get(handles.fisherk,'String'));
l = str2double(get(handles.len,'String'));

rfk = 0;
l1 = 0;
ap = 0;
dip2 = 0;
dipd2 = 0;
eqa = 0;
eqb = 0;
eqc = 0;
tic
for z=1:n
figure(1)
x1(z)=domx+x0*rand-x0/2; % 균열 중심의 x,y,z 좌표 결정. 중심의 분포는 domain 내에서 균일 분포
y1(z)=domy+y0*rand-y0/2;
z1(z)=-domz+z0*rand-z0/2;

if get(handles.fsize_ne, 'value')  % 균열 길이 분포
    l1(z) = -log(1-rand)*l;
else
    l1(z) = ((trim)^(-fracd)-((trim)^(-fracd)-(curt)^(-fracd))*rand)^(-1/fracd); 
end

if strcmp(temp4pop,'Negative exponential') % 균열 간극 분포 입력
    ap(z) = -log(1-rand)*apmean;
elseif strcmp(temp4pop,'Normal')
    ap(z) = normrnd(apmean,apstdv);
elseif strcmp(temp4pop,'Log normal')
    ap(z) = lognrnd(log(l^2/(sqrt(apstdv+apmean^2))),sqrt(log(apstdv/apmean^2+1)));
elseif strcmp(temp4pop,'Uniform')
    ap(z) = apmean*2*rand;
end

if strcmp(temp3pop,'Square')

if strcmp(temp1pop,'Fisher') % 균열 방향분포
    rotx = [1 0 0; 0 cos(-dip) -sin(-dip); 0 sin(-dip) cos(-dip)]; % Dip (x축 회전) 시계방향이라서 (-dip)
    rotx90 = [1 0 0; 0 cos(-pi/2) -sin(-pi/2); 0 sin(-pi/2) cos(-pi/2)]; 
    rotz = [cos(-dipd) -sin(-dipd) 0; sin(-dipd) cos(-dipd) 0; 0 0 1]; % Dip direction (z축 회전) 시계방향이라서 (-dipd)
    rfk = 0;
    rfk(z) = acos((log(1-rand))/K + 1); % Fisher 분포를 따르는 임의의 각도 생성
    N = rotz*(rotx*[0 0 1]'); % Dip/Dip direction이 0도 일 때 기준으로 dip/dip direction 만큼 노말벡터를 회전.
    r1 = -1+2*rand;
    q = rand;
        if q > 0.5
        q = 1;
        else
        q = -1;
        end
    Pi(z,:) = [r1*sin(rfk(z)) q*sqrt(sin(rfk(z))^2-(r1*sin(rfk(z)))^2) cos(rfk(z))]; % 기준상태일 때 호위의 임의의 점
    Pi2(z,:) = rotx90*Pi(z,:);
    Pf(z,:) = rotz*(rotx*Pi(z,:)'); % dip/dip direction만큼 회전시켰을 때 호위의 임의의 점

    a(z)=asin(sqrt(Pf(z,1)^2+Pf(z,2)^2)); 
    if Pf(z,1) > 0 & Pf(z,2) > 0
    b(z)=atan(Pf(z,1)/Pf(z,2));
    elseif Pf(z,1) > 0 & Pf(z,2) < 0
    b(z)=pi/2-atan(Pf(z,1)/Pf(z,2));
    elseif Pf(z,1) < 0 & Pf(z,2) < 0
    b(z)=atan(Pf(z,1)/Pf(z,2))+pi;
    elseif Pf(z,1) < 0 & Pf(z,2) > 0
    b(z)=3*pi/2-atan(Pf(z,1)/Pf(z,2));
    end
end
v1=[x1(z)+l1(z)*sqrt(2)/2*cos(a(z))*cos(-(b(z)+pi/4)) y1(z)+l1(z)*sqrt(2)/2*cos(a(z))*sin(-(b(z)+pi/4)) z1(z)-sqrt(2)/2*sin(a(z))];
v2=[x1(z)+l1(z)*sqrt(2)/2*cos(a(z))*cos(-(b(z)+pi*3/4)) y1(z)+l1(z)*sqrt(2)/2*cos(a(z))*sin(-(b(z)+pi*3/4)) z1(z)+sqrt(2)/2*sin(a(z))];
v3=[x1(z)+l1(z)*sqrt(2)/2*cos(a(z))*cos(-(b(z)+pi*5/4)) y1(z)+l1(z)*sqrt(2)/2*cos(a(z))*sin(-(b(z)+pi*5/4)) z1(z)+sqrt(2)/2*sin(a(z))];
v4=[x1(z)+l1(z)*sqrt(2)/2*cos(a(z))*cos(-(b(z)+pi*7/4)) y1(z)+l1(z)*sqrt(2)/2*cos(a(z))*sin(-(b(z)+pi*7/4)) z1(z)-sqrt(2)/2*sin(a(z))];

figure(1)
vertex=[v1;v2;v3;v4];
face=[1 2 3 4];
patch('Faces',face,'Vertices',vertex,'Facecolor',[0.8 0.8 1]);
view(3);
grid on
hold on

elseif strcmp(temp3pop,'Circle')
if strcmp(temp1pop,'Fisher')
    K = str2double(get(handles.fisherk,'String'));
    rotx = [1 0 0; 0 cos(-dip) -sin(-dip); 0 sin(-dip) cos(-dip)]; % Dip (x축 회전) 시계방향이라서 (-dip) 
    rotz = [cos(-dipd) -sin(-dipd) 0; sin(-dipd) cos(-dipd) 0; 0 0 1]; % Dip direction (z축 회전) 시계방향이라서 (-dipd)
    rfk(z) = acos((log(1-rand))/K + 1); % Fisher 분포를 따르는 임의의 각도 생성
    N = rotz*(rotx*[0 0 1]'); % Dip/Dip direction이 0도 일 때 기준으로 dip/dip direction 만큼 노말벡터를 회전.
    rtheta(z) = rand*2*pi;
    q = rand;
        if q > 0.5
        q = 1;
        else
        q = -1;
        end
    Pi(z,:) = [sin(rfk(z))*cos(rtheta(z)) sin(rfk(z))*sin(rtheta(z)) cos(rfk(z))]; % 기준상태일 때 호위의 임의의 점
    Pf(z,:) = rotz*(rotx*Pi(z,:)'); % dip/dip direction만큼 회전시켰을 때 호위의 임의의 점  
    dip2(z) = 0;
    dip2(z) = acos(Pf(z,3));
    if Pf(z,3) < 0
        Pf(z,1) = -Pf(z,1);
        Pf(z,2) = -Pf(z,2);
        dip2(z) = -dip2(z);
    end
    if Pf(z,1) >= 0 && Pf(z,2) >= 0
        dipd2(z) = atan(Pf(z,1)/Pf(z,2));
    elseif Pf(z,1) >= 0 && Pf(z,2) < 0
        dipd2(z) = atan(-Pf(z,2)/Pf(z,1)) + pi/2;
    elseif Pf(z,1) < 0 && Pf(z,2) >= 0
        dipd2(z) = atan(-Pf(z,2)/Pf(z,1)) + pi*3/2;
    elseif Pf(z,1) < 0 && Pf(z,2) < 0
        dipd2(z) = atan(Pf(z,1)/Pf(z,2)) + pi;
    end
    if dip2(z) <= -pi/2
        dip2(z) = pi+dip2(z);
        dipd2(z) = abs(2*pi-dipd2(z));
    end
rotx2{z} = [1 0 0; 0 cos(-dip2(z)) -sin(-dip2(z)); 0 sin(-dip2(z)) cos(-dip2(z))];
rotz2{z} = [cos(-dipd2(z)) -sin(-dipd2(z)) 0; sin(-dipd2(z)) cos(-dipd2(z)) 0; 0 0 1];
rotx3{z} = [1 0 0; 0 cos(dip2(z)) -sin(dip2(z)); 0 sin(dip2(z)) cos(dip2(z))];
rotz3{z} = [cos(dipd2(z)) -sin(dipd2(z)) 0; sin(dipd2(z)) cos(dipd2(z)) 0; 0 0 1];
P1{z} = [x1(z) y1(z) z1(z)]';
P2{z} = (rotx3{z}*(rotz3{z}*P1{z}))';
end

i=1:200;
NP{z}(i,1) = P2{z}(1)+l1(z)/2*cos(2*pi/200*i);
NP{z}(i,2) = P2{z}(2)+l1(z)/2*sin(2*pi/200*i);
NP{z}(i,3) = P2{z}(3);
CC{z} = rotz2{z}*(rotx2{z}*NP{z}'); 
hold on
% 속이 찬 원 그리기
figure(1)
fill3(CC{z}(1,:),CC{z}(2,:),CC{z}(3,:),'r')
alpha 0.7
view(3);
grid on
end
end

title('3D Discrete Fracture Network','Fontsize',11,'FontWeight','bold');
xlabel('X','Fontsize',13);
ylabel('Y','Fontsize',13);
zlabel('Z','Fontsize',13);
rotate3d on
daspect([1 1 1])
rnx = sum(Pf(:,1));
rny = sum(Pf(:,2));
rnz = sum(Pf(:,3));
rn = sqrt(rnx^2+rny^2+rnz^2);
K2 = (n-1)/(n-rn);
toc

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in verification.
function verification_Callback(hObject, eventdata, handles)
% hObject    handle to verification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
try
    
global rfk K temp1pop temp3pop temp4pop n l1 l fracd trim curt ap apmean apstdv
nbins = 25;
binranges1 = max(rfk)/(2*nbins):max(rfk)/nbins:max(rfk)-max(rfk)/(2*nbins);
bincount1 = histc(rfk,binranges1)/n*(nbins)/max(rfk);
histx1 = max(rfk)/(2*nbins):max(rfk)/nbins:max(rfk)-max(rfk)/(2*nbins);
figure(2)
subplot(2,2,1)
bar(histx1,bincount1)
hold on
if strcmp(temp1pop,'Fisher')
    vx1 = 0:max(rfk)/(20*nbins):max(rfk);
    vy1 = K*sin(vx1).*exp(K*cos(vx1))/(exp(K)-exp(-K));
    plot(vx1,vy1,'r')
end
title('Fracture orientation','Fontsize',13);
xlabel('Angle (rad)','Fontsize',13);
ylabel('PDF','Fontsize',13);

binranges2 = max(l1)/(2*nbins):max(l1)/nbins:max(l1)-max(l1)/(2*nbins);
bincount2 = histc(l1,binranges2)/n*(nbins)/max(l1);
histx2 = max(l1)/(2*nbins):max(l1)/nbins:max(l1)-max(l1)/(2*nbins);
subplot(2,2,2)
bar(histx2,bincount2)
hold on
if get(handles.fsize_ne, 'value')
    vx2 = 0:max(l1)/(20*nbins):max(l1);
    vy2 = 1/l*exp(-1/l*vx2);
else
    vx2 = 0:max(l1)/(20*nbins):max(l1);
    vy2 = fracd*vx2.^(-(fracd+1))/(trim^(-fracd)-curt^(-fracd));
end
plot(vx2,vy2,'r')
if get(handles.fsize_plaw, 'value')
    xlim([trim curt])
end
title('Fracture size','Fontsize',13);
xlabel('Length (m)','Fontsize',13);
ylabel('PDF','Fontsize',13);

binranges3 = max(ap)/(2*nbins):max(ap)/nbins:max(ap)-max(ap)/(2*nbins);
bincount3 = histc(ap,binranges3)/n*(nbins)/max(ap);
histx3 = max(ap)/(2*nbins):max(ap)/nbins:max(ap)-max(ap)/(2*nbins);
subplot(2,2,3)
bar(histx3, bincount3)
hold on
if strcmp(temp4pop,'Negative exponential')
vx3 = 0:max(ap)/(20*nbins):max(ap);
vy3 = 1/apmean*exp(-1/apmean*vx3);
elseif strcmp(temp4pop,'Normal')
vx3 = 0:max(ap)/(20*nbins):max(ap);
vy3 = normpdf(vx3,apmean,apstdv);
elseif strcmp(temp4pop,'Log normal')
vx3 = 0:max(ap)/(20*nbins):max(ap);
vy3 = lognpdf(vx3,log(apmean^2/(sqrt(apstdv+apmean^2))),sqrt(log(apstdv/apmean^2+1)));    
elseif strcmp(temp4pop,'Uniform')
vx3 = 0:max(ap)/(20*nbins):max(ap);
vy3 = 0*vx3+1/max(ap);
end
plot(vx3,vy3,'r')
title('Aperture size','Fontsize',13);
xlabel('aperture (um)','Fontsize',13);
ylabel('PDF','Fontsize',13);

for ii=1:nbins
    verif1(ii)=abs(bincount1(ii)-vy1(20*ii+1));
    verif2(ii)=abs(bincount2(ii)-vy2(20*ii+1));
    verif3(ii)=abs(bincount3(ii)-vy3(20*ii+1));
end

orire=round(1000-sum(verif1)/sum(vy1)*1000)/10;
lenre=round(1000-sum(verif2)/sum(vy2)*1000)/10;
apre=round(1000-sum(verif3)/sum(vy3)*1000)/10;
set(handles.orire,'String',orire)
set(handles.lenre,'String',lenre)
set(handles.apre,'String',apre)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in swplot.
function swplot_Callback(hObject, eventdata, handles) % 임의의 평면에 대해 균열이 잘린 모양 그리기

try
    
global rotx3 rotz3 P2 rotx2 rotz2 l1 n ap x0 y0 z0 domx domy domz CC SWV swa swb swc eqa
swd = str2double(get(handles.swd,'String'));
swdip = str2double(get(handles.swdip,'String'))*pi/180;
swdipd = str2double(get(handles.swdipd,'String'))*pi/180;

for z = 1:n
SWV = [sin(swdip)*sin(swdipd) sin(swdip)*cos(swdipd) cos(swdip)]';
TSWV = (rotx3{z}*(rotz3{z}*SWV))';

temp3{z} = (rotx3{z}*(rotz3{z}*[0 0 swd/SWV(3)]'))';

swa(z) = TSWV(1);
swb(z) = TSWV(2);
swc(z) = TSWV(3);
swd2(z) = swa(z)*temp3{z}(1)+swb(z)*temp3{z}(2)+swc(z)*temp3{z}(3);

eqa(z) = 1+(swa(z)/swb(z))^2;
eqb(z) = -2*P2{z}(1)+2*swa(z)*swc(z)*P2{z}(3)/(swb(z)^2)-2*swa(z)*swd2(z)/(swb(z)^2)+2*swa(z)*P2{z}(2)/swb(z);
eqc(z) = P2{z}(1)^2+(swc(z)*P2{z}(3)/swb(z))^2+(swd2(z)/swb(z))^2+P2{z}(2)^2-2*swc(z)*swd2(z)*P2{z}(3)/(swb(z)^2)+2*swc(z)*P2{z}(2)*P2{z}(3)/swb(z)-2*swd2(z)*P2{z}(2)/swb(z)-(l1(z)^2)/4;

swx1(z) = (-eqb(z)-sqrt(eqb(z)^2-4*eqa(z)*eqc(z)))/(2*eqa(z));
swy1(z) = (-swa(z)*swx1(z)+swd2(z)-swc(z)*P2{z}(3))/swb(z);
swx2(z) = (-eqb(z)+sqrt(eqb(z)^2-4*eqa(z)*eqc(z)))/(2*eqa(z));
swy2(z) = (-swa(z)*swx2(z)+swd2(z)-swc(z)*P2{z}(3))/swb(z);

temp1 = [swx1(z) swy1(z) P2{z}(3)]';
temp2 = [swx2(z) swy2(z) P2{z}(3)]';

SW{z} = [(rotz2{z}*(rotx2{z}*temp1))';(rotz2{z}*(rotx2{z}*temp2))'];
rotx4{z} = [1 0 0; 0 cos(swdip-pi/2) -sin(swdip-pi/2); 0 sin(swdip-pi/2) cos(swdip-pi/2)];
rotz4{z} = [cos(swdipd) -sin(swdipd) 0; sin(swdipd) cos(swdipd) 0; 0 0 1];
SW2{z} = rotx4{z}*(rotz4{z}*SW{z}');
end

figure(2)
subplot(1,2,1)
for z=1:n
fill3(CC{z}(1,:),CC{z}(2,:),CC{z}(3,:),'r')
alpha 0.7
view(3);
grid on
hold on
end
hold on
for z = 1:n
if eqb(z)^2-4*eqa(z)*eqc(z) >= 0
subplot(1,2,1)
plot3([SW{z}(1,1) SW{z}(2,1)],[SW{z}(1,2) SW{z}(2,2)],[SW{z}(1,3) SW{z}(2,3)],'LineWidth',2*(1+ap(z)/max(ap)))
subplot(1,2,2)
plot([SW2{z}(1,1) SW2{z}(1,2)], [SW2{z}(3,1) SW2{z}(3,2)],'LineWidth',1+ap(z)/max(ap))
end
hold on
end

save('3D_DFN_2Dtrace.mat', 'SW2') % modified 2019.10.22 for Suyeon's work

subplot(1,2,1)
x=[domx-x0:0.1:domx+x0];
y=[domy-y0:0.1:domy+y0];
[X Y]=meshgrid(x,y);
Z=(-SWV(1)*X-SWV(2)*Y+swd)/SWV(3);
mesh(X,Y,Z)
xlabel('X','Fontsize',13);
ylabel('Y','Fontsize',13);
zlabel('Z','Fontsize',13);
title('3D Discrete Fracture Network','Fontsize',11,'FontWeight','bold');
rotate3d on
axis equal
axis([domx-x0 domx+x0 domy-y0 domy+y0 -domz-z0 -domz+z0])
hold off

figure(2)
subplot(1,2,2)
title('Sampling Window');
xlabel('Width','Fontsize',13);
ylabel('Height','Fontsize',13);
rotate3d on
axis equal
axis([domx-x0 domx+x0 domy-y0 domy+y0])
hold off

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function swslider_OpeningFcn(hObject, eventdata, handles, varagin)
% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, handles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global CC n
figure(2)
for z=1:n
fill3(CC{z}(1,:),CC{z}(2,:),CC{z}(3,:),'r')
alpha 0.7
view(3);
grid on
hold on
end
rotate3d on
xlabel('X','Fontsize',13);
ylabel('Y','Fontsize',13);
zlabel('Z','Fontsize',13);
title('3D Discrete Fracture Network','Fontsize',11,'FontWeight','bold');
axis equal

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on slider movement.
function swslider_Callback(hObject, eventdata, handles)
% hObject    handle to swslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of sli

try
    
global x0 y0 z0 swd SWV rotx3 rotz3 swa swb swc n P2 l1 eqa rotz2 rotx2 swdip swdipd ap CC domx domy domz
swd = str2double(get(handles.swd,'String'));
swdip = str2double(get(handles.swdip,'String'))*pi/180;
swdipd = str2double(get(handles.swdipd,'String'))*pi/180;
temp1 = get(handles.swslider,'Value');
swd = -temp1*(SWV(1)*x0+SWV(2)*y0-SWV(3)*z0)+SWV(1)*domx+SWV(2)*domy-SWV(3)*domz;
figure(2)
subplot(1,2,1)
for z=1:n
fill3(CC{z}(1,:),CC{z}(2,:),CC{z}(3,:),'r')
alpha 0.7
view(3);
grid on
hold on
end
rotate3d on
xlabel('X','Fontsize',13);
ylabel('Y','Fontsize',13);
zlabel('Z','Fontsize',13);
title('3D Discrete Fracture Network','Fontsize',11,'FontWeight','bold');


for z=1:n
temp3{z} = (rotx3{z}*(rotz3{z}*[0 0 swd/SWV(3)]'))';
swd2(z) = swa(z)*temp3{z}(1)+swb(z)*temp3{z}(2)+swc(z)*temp3{z}(3);
eqb(z) = -2*P2{z}(1)+2*swa(z)*swc(z)*P2{z}(3)/(swb(z)^2)-2*swa(z)*swd2(z)/(swb(z)^2)+2*swa(z)*P2{z}(2)/swb(z);
eqc(z) = P2{z}(1)^2+(swc(z)*P2{z}(3)/swb(z))^2+(swd2(z)/swb(z))^2+P2{z}(2)^2-2*swc(z)*swd2(z)*P2{z}(3)/(swb(z)^2)+2*swc(z)*P2{z}(2)*P2{z}(3)/swb(z)-2*swd2(z)*P2{z}(2)/swb(z)-(l1(z)^2)/4;

swx1(z) = (-eqb(z)-sqrt(eqb(z)^2-4*eqa(z)*eqc(z)))/(2*eqa(z));
swy1(z) = (-swa(z)*swx1(z)+swd2(z)-swc(z)*P2{z}(3))/swb(z);
swx2(z) = (-eqb(z)+sqrt(eqb(z)^2-4*eqa(z)*eqc(z)))/(2*eqa(z));
swy2(z) = (-swa(z)*swx2(z)+swd2(z)-swc(z)*P2{z}(3))/swb(z);

temp1 = [swx1(z) swy1(z) P2{z}(3)]';
temp2 = [swx2(z) swy2(z) P2{z}(3)]';

SW{z} = [(rotz2{z}*(rotx2{z}*temp1))';(rotz2{z}*(rotx2{z}*temp2))'];
rotx4{z} = [1 0 0; 0 cos(swdip-pi/2) -sin(swdip-pi/2); 0 sin(swdip-pi/2) cos(swdip-pi/2)];
rotz4{z} = [cos(swdipd) -sin(swdipd) 0; sin(swdipd) cos(swdipd) 0; 0 0 1];
SW2{z} = rotx4{z}*(rotz4{z}*SW{z}');

figure(2)
if eqb(z)^2-4*eqa(z)*eqc(z) >= 0
subplot(1,2,1)
plot3([SW{z}(1,1) SW{z}(2,1)],[SW{z}(1,2) SW{z}(2,2)],[SW{z}(1,3) SW{z}(2,3)],'LineWidth',1+ap(z)/max(ap))
subplot(1,2,2)
plot([SW2{z}(1,1) SW2{z}(1,2)], [SW2{z}(3,1) SW2{z}(3,2)],'LineWidth',1+ap(z)/max(ap))

save('3D_DFN_2Dtrace.mat', 'SW2') % modified 2019.10.22 for Suyeon's work

hold on
else
subplot(1,2,2)
plot(domx,domy)
end
end
subplot(1,2,2)
title('Sampling Window');
xlabel('Width','Fontsize',13);
ylabel('Height','Fontsize',13);
axis equal
axis([domx-x0 domx+x0 domy-y0 domy+y0])
hold off
subplot(1,2,1)
x=[domx-x0:0.1:domx+x0];
y=[domy-y0:0.1:domy+y0];
[X Y]=meshgrid(x,y);
Z=(-SWV(1)*X-SWV(2)*Y+swd)/SWV(3);
mesh(X,Y,Z)
axis equal
axis([domx-x0 domx+x0 domy-y0 domy+y0 -domz-z0 -domz+z0])
hold off

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

function drillclassify_Callback(hObject, eventdata, handles)
% hObject    handle to drillclassify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global CC n mm P1 P3 P4 P6 dip2 l1 dipd2 x1 y1 z1 drillx drilly drillr DX DY DZ drillz 
drillx = str2double(get(handles.drillx,'String'));
drilly = str2double(get(handles.drilly,'String'));
drillz = str2double(get(handles.drillz,'String'));
ddepth = str2double(get(handles.ddepth,'String'));
drillr = str2double(get(handles.drillr,'String'));
figure(3)
xlabel('X','Fontsize',13);
ylabel('Y','Fontsize',13);
zlabel('Z','Fontsize',13);
title('Intersected Fractures with Drillhole','Fontsize',11,'FontWeight','bold');
rotate3d on
grid on
axis equal
view(3)
[X,Y,Z] = cylinder(drillr,100);
DX=X+drillx;
DY=Y+drilly;
DZ(1,:)=Z(2,:)*drillz-ddepth;
DZ(2,:)=Z(2,:)*drillz;

P3 = [];
P5 = [];

surf(DX,DY,DZ)
hold on
for z=1:n
    sqrt((drillx-P1{z}(1))^2+(drilly-P1{z}(2))^2)/cos(dip2(z));
for i=1:200
if (CC{z}(1,i)-drillx)^2+(CC{z}(2,i)-drilly)^2 < drillr^2 
    nn(i)=1;
else
    nn(i)=0;
end
end
nx(z) = sin(dip2(z))*sin(dipd2(z));
ny(z) = sin(dip2(z))*cos(dipd2(z));
nz(z) = cos(dip2(z));
dz(z) = (nx(z)*P1{z}(1)+ny(z)*P1{z}(2)+nz(z)*P1{z}(3)-nx(z)*drillx-ny(z)*drilly)/nz(z);
theta(z) = atan(abs(dz(z)-P1{z}(3))/sqrt((drillx-P1{z}(1))^2+(drilly-P1{z}(2))^2));
if sqrt((drillx-P1{z}(1))^2+(drilly-P1{z}(2))^2)/cos(theta(z)) < l1(z)/2-drillr/cos(theta(z))
    mm(z)=1;
else
    mm(z)=0;
end

if (get(handles.checkinter,'Value'))
if sum(nn) > 0 || mm(z) == 1
fill3(CC{z}(1,:),CC{z}(2,:),CC{z}(3,:),'b')
alpha 0.5
hold on
P3{z} = [x1(z) y1(z) z1(z) dip2(z)*180/pi dipd2(z)*180/pi];
else
end
else
end
if (get(handles.checknoninter,'Value'))
if sum(nn) > 0 || mm(z) == 1
else
fill3(CC{z}(1,:),CC{z}(2,:),CC{z}(3,:),'r')
alpha 0.5
hold on
P5{z} = [x1(z) y1(z) z1(z) dip2(z)*180/pi dipd2(z)*180/pi];
end
else
end
end
hold off

if (get(handles.checkinter,'Value'))
P3(cellfun(@isempty,P3))=[];
p3 = length(P3);
P4 = P3{1};
if p3 >= 2
for z=1:p3-1
    P4 = [P4 P3{z+1}];
end
end
P3(cellfun(@isempty,P3))=[];
p3 = length(P3);
P4 = P3{1};
if p3 >= 2
for z=1:p3-1
    P4 = [P4 P3{z+1}];
end
end
else
end

if (get(handles.checknoninter,'Value'))
P5(cellfun(@isempty,P5))=[];
p5 = length(P5);
P6 = P5{1};
if p5 >= 2
for z=1:p5-1
    P6 = [P6 P5{z+1}];
end
end
P5(cellfun(@isempty,P5))=[];
p5 = length(P5);
P6 = P5{1};
if p5 >= 2
for z=1:p5-1
    P6 = [P6 P5{z+1}];
end
end
else
end
xlabel('X','Fontsize',13);
ylabel('Y','Fontsize',13);
zlabel('Z','Fontsize',13);
title('Intersected Fractures with Drillhole','Fontsize',11,'FontWeight','bold');
rotate3d on
grid on
axis equal
view(3)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in drillsave.
function drillsave_Callback(hObject, eventdata, handles)
% hObject    handle to drillsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global n nn P4 P6
[file,path] = uiputfile('*.txt','Save data As');
if (file ~=0)
    fname=sprintf('%s%s',path,file);
    a = fopen(fname,'w');
    fprintf(a,'Intersecting Fractures\r\n');
    fprintf(a,'%s\t%s\t%s\t%s\t%s\r\n','X','Y','Z','Dip','Dip direction');
    fprintf(a,'%f\t%f\t%f\t%f\t%f\r\n',P4);
    fprintf(a,'\r\nNon-intersecting Fractures\r\n');
    fprintf(a,'%s\t%s\t%s\t%s\t%s\r\n','X','Y','Z','Dip','Dip direction');
    fprintf(a,'%f\t%f\t%f\t%f\t%f\r\n',P6);
    fclose(a);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

function fnum_Callback(hObject, eventdata, handles)
% hObject    handle to fnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fnum as text
%        str2double(get(hObject,'String')) returns contents of fnum as a double


% --- Executes during object creation, after setting all properties.
function fnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fisherk_Callback(hObject, eventdata, handles)
% hObject    handle to fisherk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fisherk as text
%        str2double(get(hObject,'String')) returns contents of fisherk as a double


% --- Executes during object creation, after setting all properties.
function fisherk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fisherk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lenpop.
function lenpop_Callback(hObject, eventdata, handles)
% hObject    handle to lenpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lenpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lenpop


% --- Executes during object creation, after setting all properties.
function lenpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lenpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function len_Callback(hObject, eventdata, handles)
% hObject    handle to len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of len as text
%        str2double(get(hObject,'String')) returns contents of len as a double


% --- Executes during object creation, after setting all properties.
function len_CreateFcn(hObject, eventdata, handles)
% hObject    handle to len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plaw.
function plaw_Callback(hObject, eventdata, handles)
% hObject    handle to plaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in shapepop.
function shapepop_Callback(hObject, eventdata, handles)
% hObject    handle to shapepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns shapepop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from shapepop


% --- Executes during object creation, after setting all properties.
function shapepop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shapepop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function swdip_Callback(hObject, eventdata, handles)
% hObject    handle to swdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swdip as text
%        str2double(get(hObject,'String')) returns contents of swdip as a double


% --- Executes during object creation, after setting all properties.
function swdip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function swdipd_Callback(hObject, eventdata, handles)
% hObject    handle to swdipd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swdipd as text
%        str2double(get(hObject,'String')) returns contents of swdipd as a double


% --- Executes during object creation, after setting all properties.
function swdipd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swdipd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function swd_Callback(hObject, eventdata, handles)
% hObject    handle to swd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swd as text
%        str2double(get(hObject,'String')) returns contents of swd as a double


% --- Executes during object creation, after setting all properties.
function swd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in appop.
function appop_Callback(hObject, eventdata, handles)
% hObject    handle to appop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns appop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from appop


% --- Executes during object creation, after setting all properties.
function appop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to appop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function apmean_Callback(hObject, eventdata, handles)
% hObject    handle to apmean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of apmean as text
%        str2double(get(hObject,'String')) returns contents of apmean as a double


% --- Executes during object creation, after setting all properties.
function apmean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to apmean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function apstdv_Callback(hObject, eventdata, handles)
% hObject    handle to apstdv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of apstdv as text
%        str2double(get(hObject,'String')) returns contents of apstdv as a double


% --- Executes during object creation, after setting all properties.
function apstdv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to apstdv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orire_Callback(hObject, eventdata, handles)
% hObject    handle to orire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orire as text
%        str2double(get(hObject,'String')) returns contents of orire as a double


% --- Executes during object creation, after setting all properties.
function orire_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lenre_Callback(hObject, eventdata, handles)
% hObject    handle to lenre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lenre as text
%        str2double(get(hObject,'String')) returns contents of lenre as a double


% --- Executes during object creation, after setting all properties.
function lenre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lenre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function apre_Callback(hObject, eventdata, handles)
% hObject    handle to apre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of apre as text
%        str2double(get(hObject,'String')) returns contents of apre as a double


% --- Executes during object creation, after setting all properties.
function apre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to apre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function swslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function drillx_Callback(hObject, eventdata, handles)
% hObject    handle to drillx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drillx as text
%        str2double(get(hObject,'String')) returns contents of drillx as a double


% --- Executes during object creation, after setting all properties.
function drillx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drillx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function drilly_Callback(hObject, eventdata, handles)
% hObject    handle to drilly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drilly as text
%        str2double(get(hObject,'String')) returns contents of drilly as a double


% --- Executes during object creation, after setting all properties.
function drilly_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drilly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function drillz_Callback(hObject, eventdata, handles)
% hObject    handle to drillz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drillz as text
%        str2double(get(hObject,'String')) returns contents of drillz as a double


% --- Executes during object creation, after setting all properties.
function drillz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drillz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ddepth_Callback(hObject, eventdata, handles)
% hObject    handle to ddepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ddepth as text
%        str2double(get(hObject,'String')) returns contents of ddepth as a double


% --- Executes during object creation, after setting all properties.
function ddepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ddepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function drillr_Callback(hObject, eventdata, handles)
% hObject    handle to drillr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drillr as text
%        str2double(get(hObject,'String')) returns contents of drillr as a double


% --- Executes during object creation, after setting all properties.
function drillr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drillr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function domx_Callback(hObject, eventdata, handles)
% hObject    handle to domx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of domx as text
%        str2double(get(hObject,'String')) returns contents of domx as a double


% --- Executes during object creation, after setting all properties.
function domx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function domy_Callback(hObject, eventdata, handles)
% hObject    handle to domy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of domy as text
%        str2double(get(hObject,'String')) returns contents of domy as a double


% --- Executes during object creation, after setting all properties.
function domy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function domz_Callback(hObject, eventdata, handles)
% hObject    handle to domz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of domz as text
%        str2double(get(hObject,'String')) returns contents of domz as a double


% --- Executes during object creation, after setting all properties.
function domz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkinter.
function checkinter_Callback(hObject, eventdata, handles)
% hObject    handle to checkinter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkinter


% --- Executes on button press in checknoninter.
function checknoninter_Callback(hObject, eventdata, handles)
% hObject    handle to checknoninter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checknoninter


% --- Executes on button press in drillclassify.



% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fsize_ne.
function fsize_ne_Callback(hObject, eventdata, handles)
% hObject    handle to fsize_ne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fsize_ne
try
set(handles.fsize_ne, 'value', 1)
set(handles.len, 'enable', 'on')
set(handles.fnum, 'enable', 'on')
set(handles.fsize_plaw, 'value', 0)
set(handles.fracd, 'enable', 'off')
set(handles.trim, 'enable', 'off')
set(handles.curt, 'enable', 'off')
set(handles.checkfnum, 'enable', 'off')
catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end    
    


% --- Executes on button press in fsize_plaw.
function fsize_plaw_Callback(hObject, eventdata, handles)
% hObject    handle to fsize_plaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fsize_plaw
try
set(handles.fsize_ne, 'value', 0)
set(handles.len, 'enable', 'off')
set(handles.fnum, 'enable', 'off')
set(handles.fsize_plaw, 'value', 1)
set(handles.fracd, 'enable', 'on')
set(handles.trim, 'enable', 'on')
set(handles.curt, 'enable', 'on')
set(handles.checkfnum, 'enable', 'on')
catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end    


function trim_Callback(hObject, eventdata, handles)
% hObject    handle to trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trim as text
%        str2double(get(hObject,'String')) returns contents of trim as a double


% --- Executes during object creation, after setting all properties.
function trim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function curt_Callback(hObject, eventdata, handles)
% hObject    handle to curt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of curt as text
%        str2double(get(hObject,'String')) returns contents of curt as a double


% --- Executes during object creation, after setting all properties.
function curt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fracd_Callback(hObject, eventdata, handles)
% hObject    handle to fracd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fracd as text
%        str2double(get(hObject,'String')) returns contents of fracd as a double

% --- Executes during object creation, after setting all properties.
function fracd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fracd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on fracd and none of its controls.
function fracd_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fracd (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkfnum.
function checkfnum_Callback(hObject, eventdata, handles)
% hObject    handle to checkfnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
global fracd trim curt x0 y0 z0 n
x0 = str2double(get(handles.x0,'String')); % 도메인의 크기 정의
y0 = str2double(get(handles.y0,'String'));
z0 = str2double(get(handles.z0,'String'));
fracd = str2num(get(handles.fracd,'String'));
trim = str2num(get(handles.trim,'String'));
curt = str2num(get(handles.curt,'String'));
fracdensity = trim^(-fracd) - curt^(-fracd);
n = round(x0*y0*z0*fracdensity);
set(handles.fnum, 'string', n)
catch ex
    errmsg = ex.stack.line;
    msgbox([{'thrreddfngui.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
