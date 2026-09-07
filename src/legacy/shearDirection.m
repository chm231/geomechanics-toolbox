function varargout = shearDirection(varargin)
% SHEARDIRECTION MATLAB code for shearDirection.fig
%      SHEARDIRECTION, by itself, creates a new SHEARDIRECTION or raises the existing
%      singleton*.
%
%      H = SHEARDIRECTION returns the handle to a new SHEARDIRECTION or the handle to
%      the existing singleton*.
%
%      SHEARDIRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHEARDIRECTION.M with the given input arguments.
%
%      SHEARDIRECTION('Property','Value',...) creates a new SHEARDIRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before shearDirection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to shearDirection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help shearDirection

% Last Modified by GUIDE v2.5 17-Jul-2018 01:40:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @shearDirection_OpeningFcn, ...
                   'gui_OutputFcn',  @shearDirection_OutputFcn, ...
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


% --- Executes just before shearDirection is made visible.
function shearDirection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to shearDirection (see VARARGIN)

% Choose default command line output for shearDirection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes shearDirection wait for user response (see UIRESUME)
% uiwait(handles.figure1);

try
    
global h_inSitu

if ~isempty(h_inSitu)
    set(handles.SV_mag, 'String', h_inSitu.Sv)
    set(handles.SHmax_mag, 'String', h_inSitu.SHmax)
    set(handles.Shmin_mag, 'String', h_inSitu.Shmin)
    set(handles.SHmax_azi, 'String', h_inSitu.azi)
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'shearDirection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end



% --- Outputs from this function are returned to the command line.
function varargout = shearDirection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in plotButton.
function plotButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
dip = str2double(get(handles.dip, 'String'));           % dip
dipDirec = str2double(get(handles.dipDirec, 'String')); % dip direction
depth = str2double(get(handles.Z, 'String'));           % depth of intersecting point between 1st well and fracture zone
radi = str2double(get(handles.radius, 'String'));       % preferred distance between the injection and production points on the fracture
X = str2double(get(handles.X, 'String'));               
Y = str2double(get(handles.Y, 'String')); 
Z = str2double(get(handles.Z, 'String'));               % X, Y, Z coordinates of the first intersection point from the wellhead
% +x: East, +y: West, -z: depth
                                                      
if (dip<=90) && (dip>=0) && (dipDirec<360) && (dipDirec>=0)
    nx=sin(dip*pi/180)*sin(dipDirec*pi/180);
    ny=sin(dip*pi/180)*cos(dipDirec*pi/180);
    nz=cos(dip*pi/180);  
    t=0:1;
    if nx==0
        x=0.*t;
    else
        x = [X X-radi*nx];
    end
    if ny==0
        y=0.*t;
    else
        y = [Y Y-radi*ny];
    end
    if nz==0
        z=0.*t;
    else
        z = [Z Z-radi*nz];
    end
    figure()
    plot3(x,y,z, '--', 'linewidth', 2, 'color', [0 0.5 0.8])  % fracture normal vector for hangingwall fracture; always downward
    hold on
    [A,B]=meshgrid(Z:-Z/500:-Z);
    C = Z+(-nx*(A-X)-ny*(B-Y))/nz;
    mesh(A, B, C, 'FaceLighting', 'gouraud');
    hold on
    %plot3([0 X], [0 Y], [0 Z], 'linewidth', 2, 'color', [0 0 0])
end

Sv = str2double(get(handles.SV_mag, 'String')) * 1.0e6;
SHmax = str2double(get(handles.SHmax_mag, 'String')) * 1.0e6;
azi = str2double(get(handles.SHmax_azi, 'String')) * pi/180;
Shmin = str2double(get(handles.Shmin_mag, 'String')) * 1.0e6;

tau_pri = [SHmax 0 0; 0 Shmin 0; 0 0 Sv];      % principal stress tensor in principal direction
L = [cos(azi-pi/2) sin(azi-pi/2) 0; -sin(azi-pi/2) cos(azi-pi/2) 0; 0 0 1];
tau_o = L*tau_pri*L.';                          % in-situ stress tensor transformed to xyz coordinate
n = [-nx; -ny; -nz];                               % fracture normal vector on the hangingwall
p = tau_o*n;                                    % traction vector on the hangingwall
sigma_res = dot(p, n)*n;                        % resolved normal stress vector on the hangingwall
mag_sigma_res = sqrt(sigma_res(1)^2+sigma_res(2)^2+sigma_res(3)^2);
tau_res = p-sigma_res;                          % resolved shear stress vector on the hangingwall
mag_tau_res = sqrt(tau_res(1)^2+tau_res(2)^2+tau_res(3)^2);
tau_res = tau_res/norm(tau_res);                % changed into unit vector
maxPerm = cross(tau_res, n);                    % direction vector for max. permeability enhancement direction
point1 = [X Y Z].'+radi*maxPerm;                  % coordinates of the optimal intersection point 1
point2 = [X Y Z].'-radi*maxPerm;                  % coordinates of the optimal intersection point 2

svec = [-cos(dipDirec*pi/180) sin(dipDirec*pi/180) 0]; % strike vector, (dip direction -90 deg) direction
rake = acos(dot(svec, tau_res))*180/pi; % slip vector rake; angle of the slip direction vector from the strike vector
if tau_res(3) < 0
    rake = -rake;
end

slipDirec = sprintf('(%.2f, %.2f, %.2f)', tau_res(1), tau_res(2), tau_res(3));
maxPermDirec = sprintf('(%.2f, %.2f, %.2f)', maxPerm(1), maxPerm(2), maxPerm(3));
candPoint1 = sprintf('(%d, %d, %d)', round(point1(1)), round(point1(2)), round(point1(3)));
candPoint2 = sprintf('(%d, %d, %d)', round(point2(1)), round(point2(2)), round(point2(3)));
set(handles.slipVector, 'String', slipDirec)
set(handles.slipVectorRake, 'String', rake)
set(handles.permVector, 'String', maxPermDirec)
set(handles.candidate1, 'String', candPoint1)
set(handles.candidate2, 'String', candPoint2)
set(handles.sigma_n, 'String', mag_sigma_res*1e-6)
set(handles.tau_n, 'String', mag_tau_res*1e-6)

plot3([X X+radi*tau_res(1)], [Y Y+radi*tau_res(2)], [Z Z+radi*tau_res(3)], 'linewidth', 2, 'color', [0 0 1]) 
%plot3([X X-radi*tau_res(1)], [Y Y-radi*tau_res(2)], [Z Z-radi*tau_res(3)], 'linewidth', 2,  'color', [0 0 1]) % blue line: shear slip directions
plot3([X point1(1)], [Y point1(2)], [Z point1(3)], 'linewidth', 2,  'color', [1 0 0])
plot3([X point2(1)], [Y point2(2)], [Z point2(3)], 'linewidth', 2,  'color', [1 0 0]) % red line: optimal intersection directions
plot3([X X+radi*svec(1)], [Y Y+radi*svec(2)], [Z Z+radi*svec(3)], '--k', 'linewidth', 2) % strike vector
plot3([X X-radi*svec(1)], [Y Y-radi*svec(2)], [Z Z-radi*svec(3)], '--k', 'linewidth', 2) % strike vector

p_unit = p/norm(p);

arrow3d([X X+radi*p_unit(1)], [Y Y+radi*p_unit(2)], [Z Z+radi*p_unit(3)], 0.88, 5, 20, [0 0 0]) % black arrow: traction vector on the hangingwall fracture
%arrow3d([X+radi*p_unit(1) X], [Y+radi*p_unit(2) Y], [Z+radi*p_unit(3) Z], 0.85, 7, 14, [0 0 0]) 
arrow3d([X X+radi*tau_res(1)], [Y Y+radi*tau_res(2)], [Z Z+radi*tau_res(3)], 0.88, 5, 20, [0 0 1])

hidden off
daspect([1, 1, 1])
grid on
xlabel('x axis', 'fontsize', 12, 'fontweight', 'bold')
ylabel('y axis', 'fontsize', 12, 'fontweight', 'bold')
zlabel('z axis', 'fontsize', 12, 'fontweight', 'bold')
az=30;
el=30;
if get(handles.planeView, 'value')
    az = 180-dipDirec;
    el = 90 - dip;
end
view(az, el)
axis([X-1000 X+1000 Y-1000 Y+1000 Z-1000 Z+1000])
rotate3d on

catch ex
    errmsg = ex.stack.line;
    msgbox([{'shearDirection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function slipVector_Callback(hObject, eventdata, handles)
% hObject    handle to slipVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slipVector as text
%        str2double(get(hObject,'String')) returns contents of slipVector as a double


% --- Executes during object creation, after setting all properties.
function slipVector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slipVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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



function dipDirec_Callback(hObject, eventdata, handles)
% hObject    handle to dipDirec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dipDirec as text
%        str2double(get(hObject,'String')) returns contents of dipDirec as a double


% --- Executes during object creation, after setting all properties.
function dipDirec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipDirec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV_mag_Callback(hObject, eventdata, handles)
% hObject    handle to SV_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV_mag as text
%        str2double(get(hObject,'String')) returns contents of SV_mag as a double


% --- Executes during object creation, after setting all properties.
function SV_mag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SHmax_mag_Callback(hObject, eventdata, handles)
% hObject    handle to SHmax_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SHmax_mag as text
%        str2double(get(hObject,'String')) returns contents of SHmax_mag as a double


% --- Executes during object creation, after setting all properties.
function SHmax_mag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SHmax_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Shmin_mag_Callback(hObject, eventdata, handles)
% hObject    handle to Shmin_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Shmin_mag as text
%        str2double(get(hObject,'String')) returns contents of Shmin_mag as a double


% --- Executes during object creation, after setting all properties.
function Shmin_mag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Shmin_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SHmax_azi_Callback(hObject, eventdata, handles)
% hObject    handle to SHmax_azi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SHmax_azi as text
%        str2double(get(hObject,'String')) returns contents of SHmax_azi as a double


% --- Executes during object creation, after setting all properties.
function SHmax_azi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SHmax_azi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function permVector_Callback(hObject, eventdata, handles)
% hObject    handle to permVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of permVector as text
%        str2double(get(hObject,'String')) returns contents of permVector as a double


% --- Executes during object creation, after setting all properties.
function permVector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to permVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Z_Callback(hObject, eventdata, handles)
% hObject    handle to Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Z as text
%        str2double(get(hObject,'String')) returns contents of Z as a double


% --- Executes during object creation, after setting all properties.
function Z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radius_Callback(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius as text
%        str2double(get(hObject,'String')) returns contents of radius as a double


% --- Executes during object creation, after setting all properties.
function radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function candidate1_Callback(hObject, eventdata, handles)
% hObject    handle to candidate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of candidate1 as text
%        str2double(get(hObject,'String')) returns contents of candidate1 as a double


% --- Executes during object creation, after setting all properties.
function candidate1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to candidate1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function candidate2_Callback(hObject, eventdata, handles)
% hObject    handle to candidate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of candidate2 as text
%        str2double(get(hObject,'String')) returns contents of candidate2 as a double


% --- Executes during object creation, after setting all properties.
function candidate2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to candidate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_Callback(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y as text
%        str2double(get(hObject,'String')) returns contents of Y as a double


% --- Executes during object creation, after setting all properties.
function Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function X_Callback(hObject, eventdata, handles)
% hObject    handle to X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of X as text
%        str2double(get(hObject,'String')) returns contents of X as a double


% --- Executes during object creation, after setting all properties.
function X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in desriptionButton.
function desriptionButton_Callback(hObject, eventdata, handles)
% hObject    handle to desriptionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
descriptions_shearDirection
catch ex
    errmsg = ex.stack.line;
    msgbox([{'shearDirection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in planeView.
function planeView_Callback(hObject, eventdata, handles)
% hObject    handle to planeView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of planeView



function sigma_n_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_n as text
%        str2double(get(hObject,'String')) returns contents of sigma_n as a double


% --- Executes during object creation, after setting all properties.
function sigma_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tau_n_Callback(hObject, eventdata, handles)
% hObject    handle to tau_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tau_n as text
%        str2double(get(hObject,'String')) returns contents of tau_n as a double


% --- Executes during object creation, after setting all properties.
function tau_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tau_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slipVectorRake_Callback(hObject, eventdata, handles)
% hObject    handle to slipVectorRake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slipVectorRake as text
%        str2double(get(hObject,'String')) returns contents of slipVectorRake as a double


% --- Executes during object creation, after setting all properties.
function slipVectorRake_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slipVectorRake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
