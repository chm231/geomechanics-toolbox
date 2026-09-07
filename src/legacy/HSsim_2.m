% HSsim_2: 3D shear slip direction estimator is linked to the program


function varargout = HSsim(varargin)
% HSSIM MATLAB code for HSsim.fig
%      HSSIM, by itself, creates a new HSSIM or raises the existing
%      singleton*.
%
%      H = HSSIM returns the handle to a new HSSIM or the handle to
%      the existing singleton*.
%
%      HSSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HSSIM.M with the given input arguments.
%
%      HSSIM('Property','Value',...) creates a new HSSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HSsim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HSsim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HSsim

% Last Modified by GUIDE v2.5 10-Feb-2020 13:03:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HSsim_OpeningFcn, ...
                   'gui_OutputFcn',  @HSsim_OutputFcn, ...
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


% --- Executes just before HSsim is made visible.
function HSsim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HSsim (see VARARGIN)

% Choose default command line output for HSsim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HSsim wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HSsim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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



function jDip_Callback(hObject, eventdata, handles)
% hObject    handle to jDip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jDip as text
%        str2double(get(hObject,'String')) returns contents of jDip as a double


% --- Executes during object creation, after setting all properties.
function jDip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jDip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jDipDirec_Callback(hObject, eventdata, handles)
% hObject    handle to jDipDirec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jDipDirec as text
%        str2double(get(hObject,'String')) returns contents of jDipDirec as a double


% --- Executes during object creation, after setting all properties.
function jDipDirec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jDipDirec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phi_Callback(hObject, eventdata, handles)
% hObject    handle to phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi as text
%        str2double(get(hObject,'String')) returns contents of phi as a double


% --- Executes during object creation, after setting all properties.
function phi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rho_r_Callback(hObject, eventdata, handles)
% hObject    handle to rho_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho_r as text
%        str2double(get(hObject,'String')) returns contents of rho_r as a double


% --- Executes during object creation, after setting all properties.
function rho_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rho_f_Callback(hObject, eventdata, handles)
% hObject    handle to rho_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho_f as text
%        str2double(get(hObject,'String')) returns contents of rho_f as a double


% --- Executes during object creation, after setting all properties.
function rho_f_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in quickRun.
function quickRun_Callback(hObject, eventdata, handles)
% hObject    handle to quickRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

Svmag = str2double(get(handles.SV_mag, 'String')) * 1.0e6;
SHmaxmag = str2double(get(handles.SHmax_mag, 'String')) * 1.0e6;
SHmaxazi = str2double(get(handles.SHmax_azi, 'String')) * pi/180;
Shminmag = str2double(get(handles.Shmin_mag, 'String')) * 1.0e6;
phi = str2double(get(handles.phi, 'String')) * pi/180;
rho_r = str2double(get(handles.rho_r, 'String'));
rho_f = str2double(get(handles.rho_f, 'String'));
alpha = str2double(get(handles.alpha, 'String'));
S123 = strSort(Svmag, SHmaxmag, SHmaxazi, Shminmag);
jData = get(handles.mainTable, 'Data');

Pcm = Pcm_cal(S123(1, 1), S123(3, 1), phi);
set(handles.Pcm, 'String', Pcm*1.0e-6)
% minimum critical pressure for shearing optimally oriented joint under
% given stress condition

[optJ1txt, optJ2txt] = optJD(S123, phi);
set(handles.optJori1, 'String', optJ1txt)
set(handles.optJori2, 'String', optJ2txt)
% optimal joint orientations for shearing, under given stress condition

Pco = Pco_cal(Pcm, alpha, S123(3, 1));
set(handles.Pco, 'String', Pco*1.0e-6)
% cut-off pressure for shearing based on Pcm and given coefficient alpha

for i = 1:size(jData, 1)
    if strcmp(jData{i, 1}, '')
        break
    end
    jDip = jData{i, 1};
    jDipDirec = jData{i, 2};
    jData{i, 3} = (Pc_cal2(jDip*pi/180, jDipDirec*pi/180, S123, phi))*10^-6;
    dPcdz = dPcdz_cal(rho_r, jDip*pi/180, jDipDirec*pi/180, S123, Svmag, phi);
    if dPcdz > rho_f * 9.80665
        initGrth = 0;
    else
        initGrth = 1;
    end
    jData{i, 4} = initGrth;
end
set(handles.mainTable, 'Data', jData)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end



function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Pcm_polygon.
function Pcm_polygon_Callback(hObject, eventdata, handles)
% hObject    handle to Pcm_polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pcm_polygon


% --- Executes on button press in Pc_stereo.
function Pc_stereo_Callback(hObject, eventdata, handles)
% hObject    handle to Pc_stereo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pc_stereo


% --- Executes on button press in Pco_polygon.
function Pco_polygon_Callback(hObject, eventdata, handles)
% hObject    handle to Pco_polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pco_polygon


% --- Executes on button press in dPcdz_stereo.
function dPcdz_stereo_Callback(hObject, eventdata, handles)
% hObject    handle to dPcdz_stereo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dPcdz_stereo


% --- Executes on button press in prbDown_polygon.
function prbDown_polygon_Callback(hObject, eventdata, handles)
% hObject    handle to prbDown_polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of prbDown_polygon


% --- Executes on button press in advRun.
function advRun_Callback(hObject, eventdata, handles)
% hObject    handle to advRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    
Svmag = str2double(get(handles.SV_mag, 'String')) * 1.0e6;
SHmaxmag = str2double(get(handles.SHmax_mag, 'String')) * 1.0e6;
SHmaxazi = str2double(get(handles.SHmax_azi, 'String')) * pi/180;
Shminmag = str2double(get(handles.Shmin_mag, 'String')) * 1.0e6;
jDip = str2double(get(handles.jDip, 'String')) * pi/180;
jDipDirec = str2double(get(handles.jDipDirec, 'String')) * pi/180;
phi = str2double(get(handles.phi, 'String')) * pi/180;
rho_r = str2double(get(handles.rho_r, 'String'));
rho_f = str2double(get(handles.rho_f, 'String'));
alpha = str2double(get(handles.alpha, 'String'));
norm2Sv = get(handles.normalize, 'Value');

S123 = strSort(Svmag, SHmaxmag, SHmaxazi, Shminmag);

PcmCheck = get(handles.Pcm_polygon, 'Value');
PcCheck = get(handles.Pc_stereo, 'Value');
PcoCheck = get(handles.Pco_polygon, 'Value');
dPcdzCheck = get(handles.dPcdz_stereo, 'Value');
probDownCheck = get(handles.prbDown_polygon, 'Value');

tic
if PcmCheck == 1 || PcoCheck == 1 || probDownCheck == 1
    polygonGroup(phi, Svmag, rho_r, rho_f, alpha, PcmCheck, PcoCheck, probDownCheck, norm2Sv)
end

if PcCheck == 1 || dPcdzCheck == 1
    %stereonetGroup(S123, Svmag, phi, rho_r, rho_f, alpha, PcCheck, dPcdzCheck, norm2Sv)
    PcOnly(S123, Svmag, phi, rho_r, rho_f, alpha, PcCheck, norm2Sv)
end
toc

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in normalize.
function normalize_Callback(hObject, eventdata, handles)
% hObject    handle to normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalize


% --- Executes on button press in DescButton.
function DescButton_Callback(hObject, eventdata, handles)
% hObject    handle to DescButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
descriptions


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
dip = get(handles.jDip, 'string');
dipDirec = get(handles.jDipDirec, 'string');
jData = get(handles.mainTable, 'Data');
check=0;
for i=1:size(jData, 1)
    if strcmp(jData{i, 1}, '')
        jData(i, :) = {str2num(dip) str2num(dipDirec) 0 0};
        check=1;
        break
    end
end
if check==0
    jData(i+1, :) = {str2num(dip) str2num(dipDirec) 0 0};
end
set(handles.mainTable, 'Data', jData)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in loadDFNButton.
function loadDFNButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDFNButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
check = 0;

[file, path] = uigetfile('*.txt', 'File open');
if file ~= 0
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'r');
    
    while 1
        temp = textscan(fgetl(f), '%s\t%s\t%s\t%s\tsf\r\n', 5);
        if strcmp(temp{1}, 'X')
            break
        end
    end
    dc = fgetl(f);
    i = 0;
    while dc ~= -1
        i=i+1;
        temp = textscan(dc, '%f\t%f\t%f\t%f\t%f\r\n', 5);
        jData(i, :) = {temp{4} temp{5} 0 0};
        check = 1;
        dc = fgetl(f);
    end
    dc = fgetl(f);
    if dc ~= -1
        while 1
            temp = textscan(dc, '%s\t%s\t%s\t%s\tsf\r\n', 5);
            if strcmp(temp{1}, 'X')
                break
            end
            dc = fgetl(f);
        end
        dc = fgetl(f);
        while dc ~= -1
            i=i+1;
            temp = textscan(dc, '%f\t%f\t%f\t%f\t%f\r\n', 5);
            jData(i, :) = {temp{4} temp{5} 0 0};
            dc = fgetl(f);
        end
    end
    fclose(f);
end
if check == 1    
    set(handles.mainTable, 'Data', jData)
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in clearButton.
function clearButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
jData = cell(4, 4);
jData = {'' '' '' ''; '' '' '' ''; '' '' '' ''; '' '' '' ''};
set(handles.mainTable, 'Data', jData)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in intersectingDFNbutton.
function intersectingDFNbutton_Callback(hObject, eventdata, handles)
% hObject    handle to intersectingDFNbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
check = 0;

[file, path] = uigetfile('*.txt', 'File open');
if file ~= 0
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'r');
    
    while 1
        temp = textscan(fgetl(f), '%s\t%s\t%s\t%s\tsf\r\n', 5);
        if strcmp(temp{1}, 'X')
            break
        end
    end
    dc = fgetl(f);
    i = 0;
    while dc ~= -1
        i=i+1;
        temp = textscan(dc, '%f\t%f\t%f\t%f\t%f\r\n', 5);
        jData(i, :) = {temp{4} temp{5} 0 0};
        check = 1;
        dc = fgetl(f);
    end
    fclose(f);
end
if check == 1    
    set(handles.mainTable, 'Data', jData)
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --------------------------------------------------------------------
function optDrilling_Callback(hObject, eventdata, handles)
% hObject    handle to optDrilling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global h_inSitu
h_inSitu.Sv = str2double(get(handles.SV_mag, 'String'));
h_inSitu.SHmax = str2double(get(handles.SHmax_mag, 'String'));
h_inSitu.azi = str2double(get(handles.SHmax_azi, 'String'));
h_inSitu.Shmin = str2double(get(handles.Shmin_mag, 'String'));

shearDirection

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HSsim_2.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes when entered data in editable cell(s) in mainTable.
function mainTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to mainTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
