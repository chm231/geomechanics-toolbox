function varargout = TherCal(varargin)
% THERCAL MATLAB code for TherCal.fig
%      THERCAL, by itself, creates a new THERCAL or raises the existing
%      singleton*.
%
%      H = THERCAL returns the handle to a new THERCAL or the handle to
%      the existing singleton*.
%
%      THERCAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THERCAL.M with the given input arguments.
%
%      THERCAL('Property','Value',...) creates a new THERCAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TherCal_5OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TherCal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TherCal

% Last Modified by GUIDE v2.5 23-Feb-2016 15:04:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TherCal_OpeningFcn, ...
                   'gui_OutputFcn',  @TherCal_OutputFcn, ...
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


% --- Executes just before TherCal is made visible.
function TherCal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TherCal (see VARARGIN)

% Choose default command line output for TherCal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global i h_HFsim h_Units PKNBvalue KGDBvalue radialBvalue H X Z T
X=zeros(0);
Z=zeros(0);
R=zeros(0);
T=zeros(0);
H=0;
if isempty(PKNBvalue)==0
    if PKNBvalue == 1 || KGDBvalue ==1
        L = h_HFsim.h_out/ h_Units.heightOUFactor;
        z = h_HFsim.L_out(201)/ h_Units.lengthOUFactor;
        set(handles.L_F,'String',num2str(L));
        set(handles.z_D,'String',num2str(z));
    elseif radialBvalue == 1
        z = h_HFsim.L_out(201)/ h_Units.lengthOUFactor;
        set(handles.z_D,'String',num2str(z));
        set(handles.radbutton,'Value',1);
    end
end
PKNBvalue=0;
KGDBvalue=0;
radialBvalue=0;
i=0;

set(handles.T_WZT, 'Enable', 'off');
set(handles.D_button, 'Enable', 'off');
set(handles.T_button, 'Enable', 'off');
set(handles.From, 'Enable', 'off');
set(handles.To, 'Enable', 'off');
set(handles.L_box, 'Enable', 'off');
set(handles.Q_box, 'Enable', 'off');
set(handles.N_box, 'Enable', 'off');
if get(handles.bdbutton, 'Value')==1
    set(handles.x_e, 'Enable', 'off');
elseif get(handles.grinbutton, 'Value')==1
    set(handles.x_e, 'Enable', 'on');
elseif get(handles.radbutton, 'Value')==1
    set(handles.x_e, 'Enable', 'on');
    set(handles.L_F, 'Enable', 'off');
end
set(handles.x_box, 'Enable', 'off');
set(handles.cL_F, 'Enable', 'off');
set(handles.cQ_M, 'Enable', 'off');
set(handles.cN_F, 'Enable', 'off');
set(handles.cx_e, 'Enable', 'off');
set(handles.Plot_button, 'Enable', 'off');
set(handles.Clear_button, 'Enable', 'off');
set(handles.Enlarge_button, 'Enable', 'off');


% UIWAIT makes TherCal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TherCal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Cal_button.
function Cal_button_Callback(hObject, eventdata, handles)
% hObject    handle to Cal_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic
global H X Z T R
c_r = get(handles.c_R, 'String');
c_w = get(handles.c_W, 'String');
Rho_r = get(handles.Rho_R, 'String');
K_r = get(handles.K_R, 'String');
T_ro = get(handles.T_RO, 'String');
T_wo= get(handles.T_WO, 'String');
L = get(handles.L_F, 'String');
Q_m = get(handles.Q_M, 'String');
N = get(handles.N_F, 'String');
x_E = get(handles.x_e, 'String');
z= get(handles.z_D, 'String');
t_year = get(handles.t_YEAR, 'String');

c_r=str2double(c_r);
c_w=str2double(c_w);
Rho_r=str2double(Rho_r);
K_r=str2double(K_r);
T_ro=str2double(T_ro);
T_wo=str2double(T_wo);
L=str2double(L);
Q_m=str2double(Q_m);
N=str2double(N);
x_E=str2double(x_E)/2;
z=str2double(z);
t_year=str2double(t_year);
H=0.6;

if get(handles.bdbutton, 'Value') == 1
    T_wzt=bdv(0, T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year);
    sT_wzt=sprintf('%0.2f',T_wzt); 
    rockTemp_bdv
elseif get(handles.grinbutton, 'Value') == 1
    T_WD=grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year, x_E, 0, T_wo, T_ro);
    T_wzt=T_WD;
    sT_wzt=sprintf('%0.2f',T_wzt);
    rockTemp_grg
elseif get(handles.radbutton, 'Value') == 1
    T_wzt=radtal(Rho_r, c_w, c_r, K_r, Q_m, 0, z, N, t_year, x_E, T_ro, T_wo);
    sT_wzt=sprintf('%0.2f',T_wzt);
    rockTemp_rad
end        
set(handles.T_WZT, 'Enable', 'on');
set(handles.T_WZT,'String',sT_wzt);

set(handles.D_button, 'Enable', 'on');
set(handles.T_button, 'Enable', 'on');
set(handles.From, 'Enable', 'on');
set(handles.To, 'Enable', 'on');
set(handles.Q_box, 'Enable', 'on');
if get(handles.bdbutton, 'Value')==1
    set(handles.cx_e, 'Enable', 'off');
    set(handles.x_e, 'Enable', 'off');
    set(handles.x_box, 'Enable', 'off');
    set(handles.cL_F, 'Enable', 'on');
    set(handles.L_F, 'Enable', 'on');
    set(handles.L_box, 'Enable', 'on');
elseif get(handles.grinbutton, 'Value')==1
    set(handles.cx_e, 'Enable', 'on');
    set(handles.x_e, 'Enable', 'on');
    set(handles.x_box, 'Enable', 'on');
    set(handles.cL_F, 'Enable', 'on');
    set(handles.L_F, 'Enable', 'on');
    set(handles.L_box, 'Enable', 'on');
elseif get(handles.radbutton, 'Value')==1
    set(handles.cx_e, 'Enable', 'on');
    set(handles.x_e, 'Enable', 'on');
    set(handles.x_box, 'Enable', 'on');
    set(handles.cL_F, 'Enable', 'off');
    set(handles.L_F, 'Enable', 'off');
    set(handles.L_box, 'Enable', 'off');
end
set(handles.N_box, 'Enable', 'on');
set(handles.cN_F, 'Enable', 'on');
set(handles.cQ_M, 'Enable', 'on');
set(handles.Plot_button, 'Enable', 'on');
set(handles.Clear_button, 'Enable', 'on');
set(handles.Enlarge_button, 'Enable', 'on');

if get(handles.D_button, 'Value') == 1
    set(handles.fromunit, 'String', 'm');
    set(handles.tounit, 'String', 'm');
end
toc

function T_WZT_Callback(hObject, eventdata, handles)
% hObject    handle to T_WZT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T_WZT as text
%        str2double(get(hObject,'String')) returns contents of T_WZT as a double


% --- Executes during object creation, after setting all properties.
function T_WZT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T_WZT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L_F_Callback(hObject, eventdata, handles)
% hObject    handle to L_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATL
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L_F as text
%        str2double(get(hObject,'String')) returns contents of L_F as a double


% --- Executes during object creation, after setting all properties.
function L_F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q_M_Callback(hObject, eventdata, handles)
% hObject    handle to Q_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q_M as text
%        str2double(get(hObject,'String')) returns contents of Q_M as a double


% --- Executes during object creation, after setting all properties.
function Q_M_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_D_Callback(hObject, eventdata, handles)
% hObject    handle to z_D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_D as text
%        str2double(get(hObject,'String')) returns contents of z_D as a double


% --- Executes during object creation, after setting all properties.
function z_D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_e_Callback(hObject, eventdata, handles)
% hObject    handle to x_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_e as text
%        str2double(get(hObject,'String')) returns contents of x_e as a double


% --- Executes during object creation, after setting all properties.
function x_e_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function N_F_Callback(hObject, eventdata, handles)
% hObject    handle to N_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N_F as text
%        str2double(get(hObject,'String')) returns contents of N_F as a double


% --- Executes during object creation, after setting all properties.
function N_F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_YEAR_Callback(hObject, eventdata, handles)
% hObject    handle to t_YEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_YEAR as text
%        str2double(get(hObject,'String')) returns contents of t_YEAR as a double


% --- Executes during object creation, after setting all properties.
function t_YEAR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_YEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c_R_Callback(hObject, eventdata, handles)
% hObject    handle to c_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c_R as text
%        str2double(get(hObject,'String')) returns contents of c_R as a double


% --- Executes during object creation, after setting all properties.
function c_R_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c_W_Callback(hObject, eventdata, handles)
% hObject    handle to c_W (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c_W as text
%        str2double(get(hObject,'String')) returns contents of c_W as a double


% --- Executes during object creation, after setting all properties.
function c_W_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_W (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function T_RO_Callback(hObject, eventdata, handles)
% hObject    handle to T_RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T_RO as text
%        str2double(get(hObject,'String')) returns contents of T_RO as a double


% --- Executes during object creation, after setting all properties.
function T_RO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T_RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_R_Callback(hObject, eventdata, handles)
% hObject    handle to K_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_R as text
%        str2double(get(hObject,'String')) returns contents of K_R as a double


% --- Executes during object creation, after setting all properties.
function K_R_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Rho_R_Callback(hObject, eventdata, handles)
% hObject    handle to Rho_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rho_R as text
%        str2double(get(hObject,'String')) returns contents of Rho_R as a double


% --- Executes during object creation, after setting all properties.
function Rho_R_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rho_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function T_WO_Callback(hObject, eventdata, handles)
% hObject    handle to T_WO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T_WO as text
%        str2double(get(hObject,'String')) returns contents of T_WO as a double


% --- Executes during object creation, after setting all properties.
function T_WO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T_WO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in L_box.
function L_box_Callback(hObject, eventdata, handles)
% hObject    handle to L_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of L_box


% --- Executes on button press in Q_box.
function Q_box_Callback(hObject, eventdata, handles)
% hObject    handle to Q_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Q_box


% --- Executes on button press in N_box.
function N_box_Callback(hObject, eventdata, handles)
% hObject    handle to N_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of N_box


% --- Executes on button press in x_box.
function x_box_Callback(hObject, eventdata, handles)
% hObject    handle to x_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of x_box



function cL_F_Callback(hObject, eventdata, handles)
% hObject    handle to cL_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cL_F as text
%        str2double(get(hObject,'String')) returns contents of cL_F as a double


% --- Executes during object creation, after setting all properties.
function cL_F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cL_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cQ_M_Callback(hObject, eventdata, handles)
% hObject    handle to cQ_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cQ_M as text
%        str2double(get(hObject,'String')) returns contents of cQ_M as a double


% --- Executes during object creation, after setting all properties.
function cQ_M_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cQ_M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cN_F_Callback(hObject, eventdata, handles)
% hObject    handle to cN_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cN_F as text
%        str2double(get(hObject,'String')) returns contents of cN_F as a double


% --- Executes during object creation, after setting all properties.
function cN_F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cN_F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cx_e_Callback(hObject, eventdata, handles)
% hObject    handle to cx_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cx_e as text
%        str2double(get(hObject,'String')) returns contents of cx_e as a double


% --- Executes during object creation, after setting all properties.
function cx_e_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cx_e (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in D_button.
function D_button_Callback(hObject, eventdata, handles)
% hObject    handle to D_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.fromunit, 'String', 'm');
set(handles.tounit, 'String', 'm');
% Hint: get(hObject,'Value') returns toggle state of D_button


% --- Executes on button press in T_button.
function T_button_Callback(hObject, eventdata, handles)
% hObject    handle to T_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of T_button
set(handles.fromunit, 'String', 'years');
set(handles.tounit, 'String', 'years');


function From_Callback(hObject, eventdata, handles)
% hObject    handle to From (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of From as text
%        str2double(get(hObject,'String')) returns contents of From as a double


% --- Executes during object creation, after setting all properties.
function From_CreateFcn(hObject, eventdata, handles)
% hObject    handle to From (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function To_Callback(hObject, eventdata, handles)
% hObject    handle to To (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of To as text
%        str2double(get(hObject,'String')) returns contents of To as a double


% --- Executes during object creation, after setting all properties.
function To_CreateFcn(hObject, eventdata, handles)
% hObject    handle to To (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Clear_button.
function Clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i legendmatrix T_plot T_wzt
legendmatrix=cell(i,1);
i=0;
T_plot=[];
T_wzt=[];
axes(handles.sgraph);
xlabel(''), ylabel('')
grid off
cla;


% --- Executes on button press in Enlarge_button.
function Enlarge_button_Callback(hObject, eventdata, handles)
% hObject    handle to Enlarge_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i T_plot legendmatrix
figure()
if get(handles.D_button, 'Value') == 1
    startV=str2num(get(handles.From, 'String'));
    endV=str2num(get(handles.To, 'String'));
    z=startV:(endV-startV)/500:endV;
       
    for k=1:i
        h(k)=plot(z,T_plot(k,:), 'linewidth', 2, 'DisplayName', legendmatrix{k});
        hold on
    end
    xlabel('Distance(m)', 'fontsize', 14), ylabel('Fluid temperature(¡É)', 'fontsize', 14)
    legend(h,'Location','southeast');
   
elseif get(handles.T_button, 'Value') == 1
    startV=str2num(get(handles.From, 'String'));
    endV=str2num(get(handles.To, 'String'));
    t_year=startV:(endV-startV)/500:endV;
    for k=1:i
        h(k)=plot(t_year,T_plot(k,:), 'linewidth', 2,'DisplayName', legendmatrix{k});
        hold on
    end
    xlabel('Time(year)', 'fontsize', 14), ylabel('Fluid temperature(¡É)', 'fontsize', 14)
    legend(h,'Location','southwest');
end

startV=str2num(get(handles.From, 'String'));
endV=str2num(get(handles.To, 'String'));
T_ro=str2double(get(handles.T_RO, 'String'));
axis([startV endV 0 T_ro])
grid on, grid minor, zoom on, hold on


% --- Executes on button press in Plot_button.
function Plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i T_plot legendmatrix T_wzt
i=i+1;

c_r = get(handles.c_R, 'String');
c_w = get(handles.c_W, 'String');
Rho_r = get(handles.Rho_R, 'String');
K_r = get(handles.K_R, 'String');
T_ro = get(handles.T_RO, 'String');
T_wo= get(handles.T_WO, 'String');
L = get(handles.L_F, 'String');
Q_m = get(handles.Q_M, 'String');
N = get(handles.N_F, 'String');
x_E = get(handles.x_e, 'String');
z= get(handles.z_D, 'String');
t_year = get(handles.t_YEAR, 'String');

c_r=str2double(c_r);
c_w=str2double(c_w);
Rho_r=str2double(Rho_r);
K_r=str2double(K_r);
T_ro=str2double(T_ro);
T_wo=str2double(T_wo);
L=str2double(L);
Q_m=str2double(Q_m);
N=str2double(N);
x_E=str2double(x_E)/2;
z=str2double(z);
t_year=str2double(t_year);
H=0.6;

startV=str2num(get(handles.From, 'String'));
endV=str2num(get(handles.To, 'String'));

if get(handles.D_button, 'Value') == 1
    z=startV:(endV-startV)/500:endV;
elseif get(handles.T_button, 'Value') == 1
    t_year=startV:(endV-startV)/500:endV;
end

legendmatrix{i}='';
if get(handles.L_box, 'Value') == 1
    L = str2double(get(handles.cL_F, 'String'));
    legendmatrix{i}= strcat(legendmatrix{i},' Width of fracture=', num2str(L), 'm');
end

if get(handles.Q_box, 'Value') == 1
    Q_m= str2double(get(handles.cQ_M, 'String'));
    legendmatrix{i}= strcat(legendmatrix{i},' Mass flow rate=', num2str(Q_m),'kg/s');
end

if get(handles.N_box, 'Value') == 1
    N = str2double(get(handles.cN_F, 'String'));
    legendmatrix{i}= strcat(legendmatrix{i},' Number of fractures=', num2str(N));
end

if get(handles.x_box, 'Value') == 1
    x_E = str2double(get(handles.cx_e, 'String'))/2;
    legendmatrix{i}= strcat(legendmatrix{i},' Fracture spacing=', num2str(x_E*2), 'm');
end

if (get(handles.L_box, 'Value') == 0) && (get(handles.Q_box, 'Value') == 0) && (get(handles.N_box, 'Value') == 0) && (get(handles.x_box, 'Value') == 0)
    legendmatrix{i}=' Original condition';
end

if get(handles.bdbutton, 'Value') == 1
    T_wzt=bdv(0,T_wo, T_ro, Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year);
elseif get(handles.grinbutton, 'Value') == 1
    sz=size(z);
    if sz(2)>1
        for j=1:sz(2)
            zz=z(j);
            T_WD(j) = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, zz, N, t_year, x_E, 0, T_wo, T_ro);
        end
        T_wztt=T_WD;
        T_wzt=T_wztt;
    else
        T_WD = grgtal(Rho_r, c_w, c_r, K_r, Q_m, L, z, N, t_year, x_E, 0, T_wo, T_ro);
        T_wzt=T_WD; 
    end
elseif get(handles.radbutton, 'Value')==1
        sz=size(z);
    if sz(2)>1
        for j=1:sz(2)
            zz=z(j);
            T_wztt(j) = radtal(Rho_r, c_w, c_r, K_r, Q_m, 0, zz, N, t_year, x_E, T_ro, T_wo);
        end
            T_wzt=T_wztt;
    else
        T_wztt = radtal(Rho_r, c_w, c_r, K_r, Q_m, 0, z, N, t_year, x_E, T_ro, T_wo);
        T_wzt=T_wztt;
    end
end  

axes(handles.sgraph);
if get(handles.D_button, 'Value') == 1
    plot(z,T_wzt, 'linewidth', 2);
    xlabel('Distance(m)'), ylabel('Fluid temperature(¡É)')
elseif get(handles.T_button, 'Value') == 1
    plot(t_year,T_wzt,'linewidth',2);
    xlabel('Time(year)'), ylabel('Fluid temperature(¡É)')
end

T_plot(i,:)=T_wzt;
axis([startV endV 0 T_ro])
grid off
grid on, grid minor, zoom on, hold on

% --- Executes on button press in bdbutton.
function bdbutton_Callback(hObject, ~, handles)
% hObject    handle to bdbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global H
set(handles.cx_e, 'Enable', 'off');
set(handles.x_e, 'Enable', 'off');
set(handles.x_box, 'Enable', 'off');
set(handles.L_F, 'Enable', 'on');
if H==0.6
set(handles.cL_F, 'Enable', 'on');
set(handles.L_box, 'Enable', 'on');
end

% Hint: get(hObject,'Value') returns toggle state of bdbutton


% --- Executes on button press in grinbutton.
function grinbutton_Callback(hObject, eventdata, handles)
% hObject    handle to grinbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global H
set(handles.x_e, 'Enable', 'on');
set(handles.L_F, 'Enable', 'on');
if H == 0.6
set(handles.x_box, 'Enable', 'on');
set(handles.cx_e, 'Enable', 'on');
set(handles.cL_F, 'Enable', 'on');
set(handles.L_box, 'Enable', 'on');
end
% Hint: get(hObject,'Value') returns toggle state of grinbutton


% --- Executes when selected object is changed in uibuttongroup5.
function uibuttongroup5_SelectionChangedFcn(hObject, eventdata, ~)
% hObject    handle to the selected object in uibuttongroup5 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radbutton.
function radbutton_Callback(hObject, eventdata, handles)
% hObject    handle to radbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global H
set(handles.x_e, 'Enable', 'on');
set(handles.L_F, 'Enable', 'off');
set(handles.cL_F, 'Enable', 'off');
if H == 0.6
set(handles.x_box, 'Enable', 'on');
set(handles.L_box, 'Enable', 'off');
set(handles.cx_e, 'Enable', 'on');
end
% Hint: get(hObject,'Value') returns toggle state of radbutton


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('*.txt', 'File open');
if file ~= 0
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'r');
    
    fgetl(f);
    fgetl(f);
    fgetl(f);
    
    temp=textscan(fgetl(f), 'Thermal model: %s')  ;
    if strcmp(temp{1}, 'Bodvarsson')
        Model='bdv';
        set(handles.bdbutton, 'Value',1);
        set(handles.grinbutton, 'Value',0);
        set(handles.radbutton, 'Value',0);
        set(handles.x_e, 'Enable', 'off');
    elseif strcmp(temp{1}, 'Gringarten')
        Model='grg';
        set(handles.bdbutton, 'Value',0);
        set(handles.grinbutton, 'Value',1);
        set(handles.radbutton, 'Value',0);
        set(handles.x_e, 'Enable', 'on');
    elseif strcmp(temp{1}, 'Radial')
        Model='rad';
        set(handles.bdbutton, 'Value',0);
        set(handles.grinbutton, 'Value',0);
        set(handles.radbutton, 'Value',1);
        set(handles.x_e, 'Enable', 'on');
        set(handles.L_F, 'Enable', 'off');
    end
        
    fgetl(f);
    fgetl(f);
        
    temp{1}=textscan(fgetl(f), 'Specific heat of rock\t%s');
    temp{2}=textscan(fgetl(f), 'Specific heat of fluid\t%s');
    temp{3}=textscan(fgetl(f), 'Rock density\t%s');
    temp{4}=textscan(fgetl(f), 'Thermal conductivity of rock, k\t%s');
    temp{5}=textscan(fgetl(f), 'Initial rock temperature\t%s');
    temp{6}=textscan(fgetl(f), 'Injection fluid temperature\t%s');
        
    if strcmp(temp{1}{1}{1}, 'J/kg¡ÆC')~=1
        set(handles.c_R, 'String', temp{1}{1}{1});
    end
    if strcmp(temp{2}{1}{1}, 'J/kg¡ÆC')~=1
        set(handles.c_W, 'String', temp{2}{1}{1});
    end
    if strcmp(temp{3}{1}{1}, 'kg/m^3')~=1
        set(handles.Rho_R, 'String', temp{3}{1}{1});
    end
    if strcmp(temp{4}{1}{1}, 'W/m¡ÆC')~=1
        set(handles.K_R, 'String', temp{4}{1}{1});
    end
    if strcmp(temp{5}{1}{1},'¡ÆC')~=1
        T_ro=str2num(cell2mat(temp{5}{1}(1)));
        set(handles.T_RO, 'String', temp{5}{1}{1});
    end
    if strcmp(temp{6}{1}{1}, '¡ÆC')~=1
        T_wo=str2num(cell2mat(temp{6}{1}(1)));
        set(handles.T_WO, 'String', temp{6}{1}{1});
    end
    
    fgetl(f);
    fgetl(f);
    fgetl(f);
    
    temp{1}=textscan(fgetl(f), 'Width of fracture\t%s');
    temp{2}=textscan(fgetl(f), 'Mass flow rate\t%s');
    temp{3}=textscan(fgetl(f), 'Number of fractures\t%s');
    temp{4}=textscan(fgetl(f), 'Fracture spacing\t%s');
    temp{5}=textscan(fgetl(f), 'Distance from injection\t%s');
    temp{6}=textscan(fgetl(f), 'Time\t%s');
    if strcmp(temp{1}{1}{1},'m')~=1
        set(handles.L_F, 'String', temp{1}{1}{1});
    end
    if strcmp(temp{2}{1}{1}, 'kg/s')~=1
        set(handles.Q_M, 'String', temp{2}{1}{1});
    end
    N=1; %number of fractures in the Bodvarsson equation case
    if strcmp(temp{3}{1}{1}, '\r\n') ~=1
        N=str2num(cell2mat(temp{3}{1}(1))); %number of fractures in Gringarten and radial cases
        set(handles.N_F, 'String', temp{3}{1}{1});
    end
    if strcmp(temp{4}{1}{1},'m')~=1
        x_E=str2num(cell2mat(temp{4}{1}(1)))/2;
        set(handles.x_e, 'String', temp{4}{1}{1});   
    end
    if strcmp(temp{5}{1}{1},'m')~=1
        set(handles.z_D, 'String', temp{5}{1}{1});
    end
    if strcmp(temp{6}{1}{1},'years')~=1
        set(handles.t_YEAR, 'String', temp{6}{1}{1});
    end
    
    fgetl(f);
    fgetl(f);
    temp=textscan(fgetl(f), 'Outlet fluid temperature\t%s');
    if temp{1}{1}~= '¡É'
        set(handles.T_WZT, 'Enable', 'on');
        set(handles.T_WZT, 'String',temp{1}{1});
    end
    
    fgetl(f);
    fgetl(f);
    fgetl(f);
      
    temp=fgetl(f);
    if strcmp(temp, 'no data') ~= 1
        temp = textscan(temp, '%s\t%s\t%s', 3);
        z(1,1)=str2num(cell2mat(temp{1}));
        x(1,1)=str2num(cell2mat(temp{2}));
        t(1,1)=str2num(cell2mat(temp{3}));
        for i=2:101
            temp = textscan(fgetl(f), '%s\t%s\t%s', 3);
            z(i,1)=str2num(cell2mat(temp{1}));
            x(i,1)=str2num(cell2mat(temp{2}));
            t(i,1)=str2num(cell2mat(temp{3}));
        end
        for i=1:101
            for j=2:101
                temp = textscan(fgetl(f), '%s\t%s\t%s', 3);
                z(i,j)=str2num(cell2mat(temp{1}));
                x(i,j)=str2num(cell2mat(temp{2}));
                t(i,j)=str2num(cell2mat(temp{3}));
            end
        end
        zz=z(101,101);
        T_wo=t(1,1);
        figure
        
        if Model~='bdv'
            if mod(N,2)==1
                for i=-(N-1)/2:(N-1)/2
                    contourf(z, x+2*x_E*i, t, 256, 'linestyle', 'none')
                    hold on
                    contourf(z, -x+2*x_E*i, t, 256, 'linestyle', 'none')
                    hold on
                    plot([0 zz], [2*x_E*i 2*x_E*i],'k', 'linewidth', 0.5, 'linestyle', '--')
                end
            elseif mod(N,2)==0
                for i=1:N/2
                    contourf(z, x+x_E*(2*i-1), t, 256, 'linestyle', 'none')
                    hold on
                    contourf(z, -x+x_E*(2*i-1), t, 256, 'linestyle', 'none')
                    hold on
                    contourf(z, x-x_E*(2*i-1), t, 256, 'linestyle', 'none')
                    hold on
                    contourf(z, -x-x_E*(2*i-1), t, 256, 'linestyle', 'none')
                    hold on
                    plot([0 zz], [x_E*(2*i-1) x_E*(2*i-1)],'k', 'linewidth', 0.5, 'linestyle', '--')
                    hold on
                    plot([0 zz], [-x_E*(2*i-1) -x_E*(2*i-1)],'k', 'linewidth', 0.5, 'linestyle', '--')
                end
            end
        elseif Model=='bdv'
            contourf(z, x, t, 256, 'linestyle', 'none')
            hold on
            contourf(z, -x, t, 256, 'linestyle', 'none')
            z1 = [0 zz];
            x1 = [0 0];
            plot(z1, x1, 'k', 'linewidth', 0.5, 'linestyle', '--')
        end
        %contourf(z, x, t, 256, 'linestyle', 'none')
            colormap(jet(256))
            caxis([T_wo T_ro])
            h2 = colorbar;
            ticks = T_wo:(T_ro-T_wo)/7:T_ro;
            ticks = round(ticks, 2);
            set(h2, 'ytick', ticks)
            h2.Label.String = 'Outlet fluid temperature (¡É)';
            axis equal
            xlabel('Distance along fracture (m)')
            ylabel('Normal distance from fracture (m)')
        
            set(handles.D_button, 'Enable', 'on');
            set(handles.T_button, 'Enable', 'on');
            set(handles.From, 'Enable', 'on');
            set(handles.To, 'Enable', 'on');
            set(handles.Q_box, 'Enable', 'on');
            if get(handles.bdbutton, 'Value')==1
                set(handles.cx_e, 'Enable', 'off');
                set(handles.x_e, 'Enable', 'off');
                set(handles.x_box, 'Enable', 'off');
                set(handles.cL_F, 'Enable', 'on');
                set(handles.L_F, 'Enable', 'on');
                set(handles.L_box, 'Enable', 'on');
            elseif get(handles.grinbutton, 'Value')==1
                set(handles.cx_e, 'Enable', 'on');
                set(handles.x_e, 'Enable', 'on');
                set(handles.x_box, 'Enable', 'on');
                set(handles.cL_F, 'Enable', 'on');
                set(handles.L_F, 'Enable', 'on');
                set(handles.L_box, 'Enable', 'on');
            elseif get(handles.radbutton, 'Value')==1
                set(handles.cx_e, 'Enable', 'on');
                set(handles.x_e, 'Enable', 'on');
                set(handles.x_box, 'Enable', 'on');
                set(handles.cL_F, 'Enable', 'off');
                set(handles.L_F, 'Enable', 'off');
                set(handles.L_box, 'Enable', 'off');
            end
            set(handles.N_box, 'Enable', 'on');
            set(handles.cN_F, 'Enable', 'on');
            set(handles.cQ_M, 'Enable', 'on');
            set(handles.Plot_button, 'Enable', 'on');
            set(handles.Clear_button, 'Enable', 'on');
            set(handles.Enlarge_button, 'Enable', 'on');
            
            if get(handles.D_button, 'Value') == 1
                set(handles.fromunit, 'String', 'm');
                set(handles.tounit, 'String', 'm');
            end
            
    end
             
    fclose(f);
   
end

% --------------------------------------------------------------------
function SaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Z X T R

[file, path] = uiputfile('*.txt', 'Save as');
if file ~= 0
   
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'W');
    fprintf(f, '%s\r\n', 'Thermal calculator data file');
    fprintf(f, '%s', 'Last updated date: ');
    fprintf(f, '%s\r\n\r\n', datestr(now, 'yyyy-mm-dd, HH:MM:SS'));
 
    fprintf(f, '%s', 'Thermal model: ');
    if get(handles.bdbutton, 'Value')==1
    fprintf(f, '%s\r\n', 'Bodvarsson equation');
    Model='bdv';
    elseif get(handles.grinbutton, 'Value')==1
    fprintf(f, '%s\r\n', 'Gringarten equation');
    Model='grg';
    elseif get(handles.radbutton, 'Value')==1
    fprintf(f, '%s\r\n', 'Radial fracture');
    Model='rad';
    end
    fprintf(f, '%s\r\n', 'Base data');
   
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Parameter', 'Value', 'Unit');
    fprintf(f, '%s\t%s\t%s%s%s\t\r\n', 'Specific heat of rock', get(handles.c_R, 'String'), 'J/kg',char(176), 'C');
    fprintf(f, '%s\t%s\t%s%s%s\t\r\n', 'Specific heat of fluid', get(handles.c_W, 'String'), 'J/kg', char(176), 'C');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Rock density', get(handles.Rho_R, 'String'), 'kg/m^3');
    fprintf(f, '%s\t%s\t%s%s%s\t\r\n', 'Thermal conductivity of rock, k', get(handles.K_R, 'String'), 'W/m',char(176), 'C');
    fprintf(f, '%s\t%s\t%s%s\t\r\n', 'Initial rock temperature', get(handles.T_RO, 'String'), char(176), 'C');
    fprintf(f, '%s\t%s\t%s%s\t\r\n\r\n', 'Injection fluid temperature', get(handles.T_WO, 'String'), char(176), 'C');
    
    fprintf(f, '%s\r\n', 'Variables');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Variable', 'Value', 'Unit');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Width of fracture', get(handles.L_F, 'String'), 'm');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Mass flow rate', get(handles.Q_M, 'String'), 'kg/s');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Number of fractures',  get(handles.N_F, 'String'), '');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Fracture spacing',  get(handles.x_e, 'String'), 'm');
    fprintf(f, '%s\t%s\t%s\t\r\n', 'Distance from injection', get(handles.z_D, 'String'), 'm');
    fprintf(f, '%s\t%s\t%s\t\r\n\r\n', 'Time',  get(handles.t_YEAR, 'String'), 'years');
    
    fprintf(f, '%s\r\n', 'Calculation results');
    fprintf(f, '%s\t%s\t%s%s\t\r\n', 'Outlet fluid temperature', get(handles.T_WZT, 'String'), char(176), 'C');
    
    fprintf(f, '%s\r\n', 'Rock temperature distribution');
    if Model=='rad'
        fprintf(f, '%s\t%s\t%s\t\r\n', 'R', 'X', 'Temperature');
    else
        fprintf(f, '%s\t%s\t%s\t\r\n', 'Z', 'X', 'Temperature');
    end
    fprintf(f, '%s\t%s\t%s%s\t\r\n', 'm', 'm', char(176), 'C');
    
    if size(X) ~= [0, 0]
        if Model~='rad'
            for i = 1:101
                for j = 1:101 
                    fprintf(f, '%0.2f\t%0.2f\t%0.2f\t\r\n', Z(i,j), X(i,j), T(i,j));
                end
            end
        elseif Model=='rad'
            for i = 1:101
                for j = 1:101
                    fprintf(f, '%0.2f\t%0.2f\t%0.2f\t\r\n', R(i,j), X(i,j), T(i,j));
                end
            end
        end
    else
        fprintf(f, '%s', 'no data');
    end
    
    fclose(f);
   
end
