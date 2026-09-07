function varargout = HFsim(varargin)
% HFSIM MATLAB code for HFsim.fig
%      HFSIM, by itself, creates a new HFSIM or raises the existing
%      singleton*.
%
%      H = HFSIM returns the handle to a new HFSIM or the handle to
%      the existing singleton*.
%
%      HFSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HFSIM.M with the given input arguments.
%
%      HFSIM('Property','Value',...) creates a new HFSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HFsim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HFsim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to plot (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HFsim

% Last Modified by GUIDE v2.5 21-Apr-2017 16:48:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HFsim_OpeningFcn, ...
                   'gui_OutputFcn',  @HFsim_OutputFcn, ...
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


% --- Executes just before HFsim is made visible.
function HFsim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HFsim (see VARARGIN)

% Choose default command line output for HFsim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HFsim wait for user response (see UIRESUME)
% uiwait(handles.figure1);

try
    
global h_HFsim BDdata RTdata uSet

uSet(12, 2) = 0;
uSet(:,:) = 0;

BDdata = cell(7, 2);
for i = 1 : 7
    BDdata(i, :) = {'' '(Units...)'};
end
BDdata{2, 2} = 'fraction';

RTdata = cell(7, 2);
for i = 1 : 7
    RTdata(i, :) = {'' '(Units...)'};
end

h_HFsim.BaseData = handles.baseData;
h_HFsim.ResultTable = handles.resultTable;
h_HFsim.PKNhUnit = handles.PKNhUnit;
h_HFsim.KGDhUnit = handles.KGDhUnit;
h_HFsim.injecVUnit = handles.injecVUnit;
h_HFsim.injecTUnit = handles.injecTUnit;
h_HFsim.timeUnit = handles.TorVunit;
h_HFsim.baseData = handles.baseData;
h_HFsim.resultTable = handles.resultTable;

h_HFsim.t_out = [];
h_HFsim.V_out = [];
h_HFsim.L_out = [];
h_HFsim.Wmax_out = [];
h_HFsim.Wbar_out = [];
h_HFsim.Pnet_out = [];

set(handles.h_PKN, 'Enable', 'off');
set(handles.h_KGD, 'Enable', 'off');
set(handles.totalV, 'Enable', 'off');
set(handles.resultTable, 'Enable', 'off');
set(handles.LPlot, 'Enable', 'off');
set(handles.WmaxPlot, 'Enable', 'off');
set(handles.WavrPlot, 'Enable', 'off');
set(handles.PPlot, 'Enable', 'off');
set(handles.atTorV, 'Enable', 'off');
set(handles.plotButton, 'Enable', 'off');
set(handles.plot2DButton, 'Enable', 'off');
set(handles.plot3DButton, 'Enable', 'off');
set(handles.scaleFactor, 'Enable', 'off');
set(handles.baseData, 'Data', BDdata);
set(handles.resultTable, 'Data', RTdata);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end



% --- Outputs from this function are returned to the command line.
function varargout = HFsim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

try
    
helpdlg('Unit system should be predefined before run.')

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Units_Callback(hObject, eventdata, handles)
% hObject    handle to Units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in radialButton.
function radialButton_Callback(hObject, eventdata, handles)
% hObject    handle to radialButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radialButton

try

set(handles.h_PKN, 'Enable', 'off');
set(handles.h_PKN, 'String', '');
set(handles.h_KGD, 'Enable', 'off');
set(handles.h_KGD, 'String', '');

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in PKNButton.
function PKNButton_Callback(hObject, eventdata, handles)
% hObject    handle to PKNButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PKNButton

try
    
set(handles.h_PKN, 'Enable', 'on');
set(handles.h_PKN, 'String', '');
set(handles.h_KGD, 'Enable', 'off');
set(handles.h_KGD, 'String', '');

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in KGDButton.
function KGDButton_Callback(hObject, eventdata, handles)
% hObject    handle to KGDButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KGDButton

try
    
set(handles.h_PKN, 'Enable', 'off');
set(handles.h_PKN, 'String', '');
set(handles.h_KGD, 'Enable', 'on');
set(handles.h_KGD, 'String', '');

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function h_PKN_Callback(hObject, eventdata, handles)
% hObject    handle to h_PKN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h_PKN as text
%        str2double(get(hObject,'String')) returns contents of h_PKN as a double


% --- Executes during object creation, after setting all properties.
function h_PKN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h_PKN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function h_KGD_Callback(hObject, eventdata, handles)
% hObject    handle to h_KGD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of h_KGD as text
%        str2double(get(hObject,'String')) returns contents of h_KGD as a double


% --- Executes during object creation, after setting all properties.
function h_KGD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h_KGD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in vButton.
function vButton_Callback(hObject, eventdata, handles)
% hObject    handle to vButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vButton

try
    
set(handles.totalV, 'Enable', 'on');
set(handles.totalV, 'String', '');
set(handles.totalT, 'Enable', 'off');
set(handles.totalT, 'String', '');

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

function totalV_Callback(hObject, eventdata, handles)
% hObject    handle to totalV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalV as text
%        str2double(get(hObject,'String')) returns contents of totalV as a double


% --- Executes during object creation, after setting all properties.
function totalV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in tButton.
function tButton_Callback(hObject, eventdata, handles)
% hObject    handle to tButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tButton

try

set(handles.totalV, 'Enable', 'off');
set(handles.totalV, 'String', '');
set(handles.totalT, 'Enable', 'on');
set(handles.totalT, 'String', '');

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function totalT_Callback(hObject, eventdata, handles)
% hObject    handle to totalT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalT as text
%        str2double(get(hObject,'String')) returns contents of totalT as a double


% --- Executes during object creation, after setting all properties.
function totalT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

global h_Units h_HFsim BDdata RTdata

BDdata = get(handles.baseData, 'Data');

h_HFsim.E = h_Units.YoungsIUFactor * str2double(BDdata(1, 1)); %Young's modulus input
h_HFsim.nu = str2double(BDdata(2, 1)); % Poisson's ratio
h_HFsim.Q = h_Units.injecRateIUFactor * str2double(BDdata(3, 1)); % injection rate input
h_HFsim.mu = h_Units.viscoIUFactor * str2double(BDdata(4, 1)); % viscosity input
h_HFsim.C = h_Units.leakoffIUFactor * str2double(BDdata(5, 1)); % leakoff coefficient input
h_HFsim.Sp = h_Units.spurtIUFactor * str2double(BDdata(6, 1)); % spurt loss input
h_HFsim.Rw = h_Units.wellRadiIUFactor * str2double(BDdata(7, 1)); % borehole radius input

if get(handles.tButton, 'Value') == 1
    h_HFsim.t = h_Units.timeIUFactor * str2double(get(handles.totalT, 'String')); % time input
elseif get(handles.vButton, 'Value') == 1
    V = h_Units.volumeIUFactor * str2double(get(handles.totalV, 'String'));
    h_HFsim.t = V/h_HFsim.Q; 
end

E = h_HFsim.E;
nu = h_HFsim.nu;
Q = h_HFsim.Q;
mu = h_HFsim.mu;
C = h_HFsim.C;
Sp = h_HFsim.Sp;
t_f = h_HFsim.t;

h_HFsim.Wmax_out(201) = 0;
h_HFsim.L_out(201) = 0;
h_HFsim.Pnet_out(201) = 0;
Wmax(201) = 0;
L(201) = 0;
Pnet(201) = 0;

if get(handles.PKNButton, 'Value') == 1
    
    h_HFsim.h = h_Units.heightIUFactor * str2double(get(handles.h_PKN, 'String')); % height input
    h = h_HFsim.h;
    t = 1 : (t_f - 1)/200 : t_f;
    
    if C == 0 && Sp == 0 % no leak-off case
        
        h_HFsim.L_out = h_Units.lengthOUFactor * 0.39 * (E*Q^3 / ((1 - nu^2)*mu*h^4))^0.2 * t.^0.8; % length output
        h_HFsim.Wmax_out = h_Units.apertureOUFactor * 2.18 * ((1 - nu^2)*mu*Q^2 / (E*h))^0.2 * t.^0.2; % max.aperture output
        h_HFsim.Pnet_out = h_Units.pressureOUFactor * 1.09 * (E^4*mu*Q^2 / ((1-nu^2)^4*h^6))^0.2 * t.^0.2; % net pressure output
        
    else % PKN-C case
        
        for i = 1 : 201
            [Wmax(i), L(i), Pnet(i)] = PKN_C(E, nu, Q, mu, C, Sp, h, t(i));
        end
        
        h_HFsim.L_out = h_Units.lengthOUFactor * L;
        h_HFsim.Wmax_out = h_Units.apertureOUFactor * Wmax;
        h_HFsim.Pnet_out = h_Units.pressureOUFactor * Pnet;
        
    end
    
    h_HFsim.h_out = h_Units.heightOUFactor * h; % height output
    h_HFsim.Wbar_out = h_HFsim.Wmax_out * pi / 5; % avr.aperture output
    h_HFsim.t_out = h_Units.timeOUFactor * t; % total injection time output
    h_HFsim.V_out = h_Units.volumeOUFactor * Q * t; % total injected volume output
 
elseif get(handles.KGDButton, 'Value') == 1
    
    h_HFsim.h = h_Units.heightIUFactor * str2double(get(handles.h_KGD, 'String'));
    h = h_HFsim.h;
    t = 1 : (t_f - 1)/200 : t_f;
    
    if C == 0 && Sp == 0 % no leak-off case
        
        h_HFsim.L_out = h_Units.lengthOUFactor * 0.38 * (E*Q^3/((1-nu^2)*mu*h^3))^(1/6) * t.^(2/3);
        h_HFsim.Wmax_out = h_Units.apertureOUFactor * 1.67 * ((1-nu^2)*mu*Q^3/(E*h^3))^(1/6) * t.^(1/3);
        h_HFsim.Pnet_out = h_Units.pressureOUFactor * 1.09 * (mu*E^2/(1-nu^2)^2)^(1/3) * t.^(-1/3);
        
    else % KGD-C case
        
        for i = 1 : 201        
            [Wmax(i), L(i), Pnet(i)] = KGD_C(E, nu, Q, mu, C, Sp, h, t(i));
        end
        
        h_HFsim.L_out = h_Units.lengthOUFactor * L;
        h_HFsim.Wmax_out = h_Units.apertureOUFactor * Wmax;
        h_HFsim.Pnet_out = h_Units.pressureOUFactor * Pnet;
        
    end
    
    h_HFsim.h_out = h_Units.heightOUFactor * h;
    h_HFsim.Wbar_out = h_HFsim.Wmax_out * pi/4;
    h_HFsim.t_out = h_Units.timeOUFactor * t;
    h_HFsim.V_out = h_Units.volumeOUFactor * Q * t;
    
elseif get(handles.radialButton, 'Value') == 1
    
    t = 1 : (t_f-1)/200 : t_f;
        
    for i = 1 : 201
        [Wmax(i), L(i), Pnet(i)] = radial_C(E, nu, Q, mu, C, Sp, t(i));
    end
      
    h_HFsim.L_out = h_Units.lengthOUFactor * L;
    h_HFsim.Wmax_out = h_Units.apertureOUFactor * Wmax;
    h_HFsim.Wbar_out = h_HFsim.Wmax_out * 8/15;
    h_HFsim.Pnet_out = h_Units.pressureOUFactor * Pnet;
    h_HFsim.t_out = h_Units.timeOUFactor * t;
    h_HFsim.V_out = h_Units.volumeOUFactor * Q * t;
    h_HFsim.h_out = h_Units.heightOUFactor * Wmax(201);

end

RTdata{1, 1} = h_HFsim.L_out(201);
RTdata{2, 1} = h_HFsim.h_out;
RTdata{3, 1} = h_HFsim.Wmax_out(201);
RTdata{4, 1} = h_HFsim.Wbar_out(201);
RTdata{5, 1} = h_HFsim.Pnet_out(201);
RTdata{6, 1} = h_HFsim.t_out(201);
RTdata{7, 1} = h_HFsim.V_out(201);

set(handles.resultTable, 'Enable', 'on');
set(handles.resultTable, 'Data', RTdata);

set(handles.LPlot, 'Enable', 'on');
set(handles.WmaxPlot, 'Enable', 'on');
set(handles.WavrPlot, 'Enable', 'on');
set(handles.PPlot, 'Enable', 'on');
set(handles.atTorV, 'Enable', 'on');
set(handles.plotButton, 'Enable', 'on');
set(handles.plot2DButton, 'Enable', 'on');
set(handles.plot3DButton, 'Enable', 'on');
set(handles.scaleFactor, 'Enable', 'on');

global uSet

if get(handles.plotToT, 'value') == 1
    set(handles.text15, 'String', 'At time t =')
    tUnit = h_Units.t_contents{uSet(9, 2)};
    set(handles.TorVunit, 'String', tUnit)
else
    set(handles.text15, 'String', 'At volume V =')
    vUnit = h_Units.V_contents{uSet(1, 2)};
    set(handles.TorVunit, 'String', vUnit)
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in LPlot.
function LPlot_Callback(hObject, eventdata, handles)
% hObject    handle to LPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LPlot


% --- Executes on button press in WmaxPlot.
function WmaxPlot_Callback(hObject, eventdata, handles)
% hObject    handle to WmaxPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WmaxPlot


% --- Executes on button press in WavrPlot.
function WavrPlot_Callback(hObject, eventdata, handles)
% hObject    handle to WavrPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WavrPlot


% --- Executes on button press in PPlot.
function PPlot_Callback(hObject, eventdata, handles)
% hObject    handle to PPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PPlot


% --- Executes on button press in plotButton.
function plotButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

global h_HFsim RTdata

if get(handles.LPlot, 'Value') == 1
    if get(handles.plotToT, 'Value') == 1
        resultPlot(h_HFsim.t_out, 'Injection time', RTdata{6, 2}, h_HFsim.L_out, 'Fracture length', RTdata{1, 2})
    elseif get(handles.plotToV, 'Value') == 1
        resultPlot(h_HFsim.V_out, 'Injected volume', RTdata{7, 2}, h_HFsim.L_out, 'Fracture length', RTdata{1, 2})
    end        
end

if get(handles.WmaxPlot, 'Value') == 1
    if get(handles.plotToT, 'Value') == 1
        resultPlot(h_HFsim.t_out, 'Injection time', RTdata{6, 2}, h_HFsim.Wmax_out, 'Maximum fracture aperture', RTdata{3, 2})
    elseif get(handles.plotToV, 'Value') == 1
        resultPlot(h_HFsim.V_out, 'Injected volume', RTdata{7, 2}, h_HFsim.Wmax_out, 'Maximum fracture aperture', RTdata{3, 2})
    end            
end

if get(handles.WavrPlot, 'Value') == 1
    if get(handles.plotToT, 'Value') == 1
        resultPlot(h_HFsim.t_out, 'Injection time', RTdata{6, 2}, h_HFsim.Wbar_out, 'Average fracture aperture', RTdata{3, 2})
    elseif get(handles.plotToV, 'Value') == 1
        resultPlot(h_HFsim.V_out, 'Injected volume', RTdata{7, 2}, h_HFsim.Wbar_out, 'Average fracture aperture', RTdata{3, 2})
    end            
end

if get(handles.PPlot, 'Value') == 1
    if get(handles.plotToT, 'Value') == 1
        resultPlot(h_HFsim.t_out, 'Injection time', RTdata{6, 2}, h_HFsim.Pnet_out, 'Net fluid pressure', RTdata{5, 2})
    elseif get(handles.plotToV, 'Value') == 1
        resultPlot(h_HFsim.V_out, 'Injected volume', RTdata{7, 2}, h_HFsim.Pnet_out, 'Net fluid pressure', RTdata{5, 2})
    end            
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function atTorV_Callback(hObject, eventdata, handles)
% hObject    handle to atTorV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of atTorV as text
%        str2double(get(hObject,'String')) returns contents of atTorV as a double


% --- Executes during object creation, after setting all properties.
function atTorV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atTorV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot2DButton.
function plot2DButton_Callback(hObject, eventdata, handles)
% hObject    handle to plot2DButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

global h_Units RTdata h_HFsim

RTdata = get(handles.resultTable, 'Data');

E = h_HFsim.E;
nu = h_HFsim.nu;
Q = h_HFsim.Q;
mu = h_HFsim.mu;
C = h_HFsim.C;
Sp = h_HFsim.Sp;

if strcmp(get(handles.text15, 'String'), 'At time t =') == 1
    t = str2double(get(handles.atTorV, 'String')) / h_Units.timeOUFactor;
elseif strcmp(get(handles.text15, 'String'), 'At volume V =') == 1
    V = str2double(get(handles.atTorV, 'String')) / h_Units.volumeOUFactor;
    t = V / Q;
end

frx = 0 : 1/200 : 1;

if get(handles.PKNButton, 'Value') == 1
    
    h = h_HFsim.h;
    
    if C == 0 && Sp == 0 % no leak-off case
        
        L = h_Units.lengthOUFactor * 0.39 * (E*Q^3 / ((1 - nu^2)*mu*h^4))^0.2 * t^0.8;
        Wmax = h_Units.apertureOUFactor * 2.18 * ((1 - nu^2)*mu*Q^2 / (E*h))^0.2 * t^0.2;    
        
    else % PKN-C case
        
        [Wmax, L, Pnet] = PKN_C(E, nu, Q, mu, C, Sp, h, t);
        L = h_Units.lengthOUFactor * L;
        Wmax = h_Units.apertureOUFactor * Wmax;
        
    end
    
    Wx = Wmax * (1 - frx).^0.25;
    
elseif get(handles.KGDButton, 'Value') == 1
    
    h = h_HFsim.h;
    
    if C == 0 && Sp == 0
        
        L = h_Units.lengthOUFactor * 0.38 * (E*Q^3/((1-nu^2)*mu*h^3))^(1/6) * t^(2/3);
        Wmax = h_Units.apertureOUFactor * 1.67 * ((1-nu^2)*mu*Q^3/(E*h^3))^(1/6) * t^(1/3);    
        
    else % KGD-C case
        
        [Wmax, L, Pnet] = KGD_C(E, nu, Q, mu, C, Sp, h, t);
        L = h_Units.lengthOUFactor * L;
        Wmax = h_Units.apertureOUFactor * Wmax;
    
    end
    
    Wx = Wmax * (1 - frx.^2).^0.5;
    
elseif get(handles.radialButton, 'Value') == 1
    
    [Wmax, Rf, Pnet] = radial_C(E, nu, Q, mu, C, Sp, t);
    L = h_Units.lengthOUFactor * Rf;
    Wmax = h_Units.apertureOUFactor * Wmax;
    Wx = Wmax * (1 - frx).^0.5;
    
end

resultPlot(frx*L, 'Distance from borehole wall, x', RTdata{1, 2}, Wx, 'Maximum fracture aperture at x', RTdata{3, 2})

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in plot3DButton.
function plot3DButton_Callback(hObject, eventdata, handles)
% hObject    handle to plot3DButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

global h_Units RTdata h_HFsim

RTdata = get(handles.resultTable, 'Data');

E = h_HFsim.E;
nu = h_HFsim.nu;
Q = h_HFsim.Q;
mu = h_HFsim.mu;
C = h_HFsim.C;
Sp = h_HFsim.Sp;
Rw = h_HFsim.Rw;

if strcmp(get(handles.text15, 'String'), 'At time t =') == 1
    t = str2double(get(handles.atTorV, 'String')) / h_Units.timeOUFactor;
elseif strcmp(get(handles.text15, 'String'), 'At volume V =') == 1
    V = str2double(get(handles.atTorV, 'String')) / h_Units.volumeOUFactor;
    t = V / Q;
end

scaleFactor = str2double(get(handles.scaleFactor, 'String'));

if get(handles.PKNButton, 'Value') == 1
    
    h = h_HFsim.h;
    h_out = h_Units.lengthOUFactor * h;
    Rw_out = h_Units.lengthOUFactor * Rw;
    
    if C == 0 && Sp == 0 % no leak-off case
       
        L = h_Units.lengthOUFactor * 0.39 * (E*Q^3 / ((1 - nu^2)*mu*h^4))^0.2 * t^0.8;
        Wmax = h_Units.lengthOUFactor * 2.18 * ((1 - nu^2)*mu*Q^2 / (E*h))^0.2 * t^0.2;
        
    else % PKN-C case
        
        [Wmax, L, Pnet] = PKN_C(E, nu, Q, mu, C, Sp, h, t);
        L = h_Units.lengthOUFactor * L;
        Wmax = h_Units.lengthOUFactor * Wmax;
    
    end
    
    PKN3D(h_out, L, Rw_out, Wmax, RTdata{1, 2}, scaleFactor)
    
elseif get(handles.KGDButton, 'Value') == 1
    
    h = h_HFsim.h;
    h_out = h_Units.lengthOUFactor * h;
    Rw_out = h_Units.lengthOUFactor * Rw;
    
    if C == 0 && Sp == 0 % no leak-off case
       
        L = h_Units.lengthOUFactor * 0.38 * (E*Q^3/((1-nu^2)*mu*h^3))^(1/6) * t^(2/3);
        Wmax = h_Units.lengthOUFactor * 1.67 * ((1-nu^2)*mu*Q^3/(E*h^3))^(1/6) * t^(1/3);
        
    else % KGD-C case
        
        [Wmax, L, Pnet] = KGD_C(E, nu, Q, mu, C, Sp, h, t);
        L = h_Units.lengthOUFactor * L;
        Wmax = h_Units.lengthOUFactor * Wmax;
    
    end
    
    KGD3D(h_out, L, Rw_out, Wmax, RTdata{1, 2}, scaleFactor)
    
elseif get(handles.radialButton, 'Value') == 1
    
    Rw_out = h_Units.lengthOUFactor * Rw;
    
    [Wmax, Rf, Pnet] = radial_C(E, nu, Q, mu, C, Sp, t);
    Rf = h_Units.lengthOUFactor * Rf;
    Wmax = h_Units.lengthOUFactor * Wmax;
    
    radial3D(Rf, Rw_out, Wmax, RTdata{1, 2}, scaleFactor)
    
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --------------------------------------------------------------------
function unitSettings_Callback(hObject, eventdata, handles)
% hObject    handle to unitSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
Units

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global uSet h_HFsim BDdata RTdata

[file, path] = uigetfile('*.txt', 'File open');
if file ~= 0
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'r');
    
    fgetl(f);
    fgetl(f);
    fgetl(f);
    fgetl(f);
    fgetl(f);
    
    
    %% load the unit settings
    unitSettingCheck = fgetl(f);
    if strcmp(unitSettingCheck, '\r\n') ~= 1 % saved unit settings exist
        
        temp = textscan(unitSettingCheck, 'Fluid volume\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(1, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Fracture length\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(2, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Fracture aperture\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(3, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Fracture height\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(4, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Injection rate\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(5, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Leakoff coefficient\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(6, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Pressure\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(7, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Spurt loss\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(8, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Time\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(9, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Young''s modulus\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(10, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Borehole radius\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(11, :) = [temp{2} temp{4}];
        temp = textscan(fgetl(f), 'Fluid viscosity\t%s\t%d\t%s\t%d\r\n', 4);
        uSet(12, :) = [temp{2} temp{4}];
        fgetl(f);

    else % no unit settings saved
        
        uSet(:, :) = 0;
        
    end
    
    %% load the base data
    
    fgetl(f);
    fgetl(f);
    baseDataCheck = fgetl(f);
    
    if strcmp(baseDataCheck, '\r\n') ~= 1 % saved base data exist
        
        temp = textscan(baseDataCheck, 'Young''s modulus\t%s\t%s\r\n', 2);
        BDdata(1, :) = [temp{1} '(Units...)'];
        temp = textscan(fgetl(f), 'Poisson''s ratio\t%s\t%s\r\n', 2);
        BDdata(2, 1) = temp{1};
        temp = textscan(fgetl(f), 'Injection rate into the borehole\t%s\t%s\r\n', 2);
        BDdata(3, :) = [temp{1} '(Units...)'];
        temp = textscan(fgetl(f), 'fluid viscosity\t%s\t%s\r\n', 2);
        BDdata(4, :) = [temp{1} '(Units...)'];
        temp = textscan(fgetl(f), 'Leakoff coefficient\t%s\t%s\r\n', 2);
        BDdata(5, :) = [temp{1} '(Units...)'];
        temp = textscan(fgetl(f), 'Spurt loss\t%s\t%s\r\n', 2);
        BDdata(6, :) = [temp{1} '(Units...)'];
        temp = textscan(fgetl(f), 'Borehole radius\t%s\t%s\r\n', 2);
        BDdata(7, :) = [temp{1} '(Units...)'];
        fgetl(f);
        
    else %no base data saved
        
        for i = 1 : 7
            BDdata(i, :) = {'' '(Units...)'};
        end
        BDdata{2, 2} = 'fraction';
        
    end
    
    set(handles.baseData, 'Data', BDdata)
    
    %% load the fracture type
    fgetl(f);
    modelCheck = fgetl(f);
    temp = textscan(modelCheck, '%s', 1);
    if strcmp(temp{1}, 'PKN')
        set(handles.PKNButton, 'Value', 1)
        set(handles.KGDButton, 'Value', 0)
        set(handles.radialButton, 'Value', 0)
        set(handles.h_PKN, 'Enable', 'On')
        set(handles.h_KGD, 'Enable', 'Off')
        temp = textscan(modelCheck, '%s %s %s\t%s', 4);
        set(handles.h_PKN, 'String', temp{4}{1})
    elseif strcmp(temp{1}, 'KGD')
        set(handles.PKNButton, 'Value', 0)
        set(handles.KGDButton, 'Value', 1)
        set(handles.radialButton, 'Value', 0)
        set(handles.h_PKN, 'Enable', 'Off')
        set(handles.h_KGD, 'Enable', 'On')
        temp = textscan(modelCheck, '%s %s %s\t%s', 4);
        set(handles.h_KGD, 'String', temp{4}{1})
    elseif strcmp(temp{1}, 'Radial')
        set(handles.PKNButton, 'Value', 0)
        set(handles.KGDButton, 'Value', 0)
        set(handles.radialButton, 'Value', 1)
    end
    
    %% load the injection parameter
    fgetl(f);
    fgetl(f);
    injecParaCheck = fgetl(f);
    temp = textscan(injecParaCheck, '%s %s %s %s\t%s', 5);
    
    if strcmp(temp{3}, 'injection') % injection parameter is time
        set(handles.tButton, 'Value', 1)
        set(handles.vButton, 'Value', 0)
        set(handles.totalV, 'Enable', 'Off')
        set(handles.totalT, 'Enable', 'On')
        set(handles.totalT, 'String', temp{5}{1})
    elseif strcmp(temp{3}, 'injected') % injection parameter is volume
        set(handles.tButton, 'Value', 0)
        set(handles.vButton, 'Value', 1)
        set(handles.totalV, 'Enable', 'On')
        set(handles.totalT, 'Enable', 'Off')
        set(handles.totalV, 'String', temp{5}{1})
    end
    
    helpdlg('To apply unit settings loaded from project file, you must open the unit settings window and click ''OK''.')
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --------------------------------------------------------------------
function SaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

global h_Units h_HFsim uSet BDdata RTdata 

[file, path] = uiputfile('*.txt', 'Save as');
if file ~= 0
   
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'W');
    fprintf(f, '%s\r\n', 'HF simulation data file');
    fprintf(f, '%s', 'Last updated date: ');
    fprintf(f, '%s\r\n\r\n', datestr(now, 'yyyy-mm-dd, HH:MM:SS'));
    
    fprintf(f, '%s\r\n', 'Unit settings');
    fprintf(f, '%s\t%s\t%s\t%s\t%s\r\n', 'Parameter', 'Input unit', 'IU id', 'Output unit', 'OU id');
    if uSet(1, 1) ~= 0
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Fluid volume', h_Units.V_contents{uSet(1, 1)}, uSet(1, 1), h_Units.V_contents{uSet(1, 2)}, uSet(1, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Fracture length', h_Units.L_contents{uSet(2, 1)}, uSet(2, 1), h_Units.L_contents{uSet(2, 2)}, uSet(2, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Fracture aperture', h_Units.W_contents{uSet(3, 1)}, uSet(3, 1), h_Units.W_contents{uSet(3, 2)}, uSet(3, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Fracture height', h_Units.h_contents{uSet(4, 1)}, uSet(4, 1), h_Units.h_contents{uSet(4, 2)}, uSet(4, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Injection rate', h_Units.Q_contents{uSet(5, 1)}, uSet(5, 1), h_Units.Q_contents{uSet(5, 2)}, uSet(5, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Leakoff coefficient', h_Units.C_contents{uSet(6, 1)}, uSet(6, 1), h_Units.C_contents{uSet(6, 2)}, uSet(6, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Pressure', h_Units.P_contents{uSet(7, 1)}, uSet(7, 1), h_Units.P_contents{uSet(7, 2)}, uSet(7, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Spurt loss', h_Units.Sp_contents{uSet(8, 1)}, uSet(8, 1), h_Units.Sp_contents{uSet(8, 2)}, uSet(8, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Time', h_Units.t_contents{uSet(9, 1)}, uSet(9, 1), h_Units.t_contents{uSet(9, 2)}, uSet(9, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Young''s modulus', h_Units.E_contents{uSet(10, 1)}, uSet(10, 1), h_Units.E_contents{uSet(10, 2)}, uSet(10, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Borehole radius', h_Units.Rw_contents{uSet(11, 1)}, uSet(11, 1), h_Units.Rw_contents{uSet(11, 2)}, uSet(11, 2));
        fprintf(f, '%s\t%s\t%d\t%s\t%d\r\n', 'Fluid viscosity', h_Units.mu_contents{uSet(12, 1)}, uSet(12, 1), h_Units.mu_contents{uSet(12, 2)}, uSet(12, 2));
    end
    
    fprintf(f, '\r\n');
    fprintf(f, '%s\r\n', 'Base data');
    fprintf(f, '%s\t%s\t%s\r\n', 'Parameter', 'Value', 'Unit');
    fprintf(f, '%s\t%s\t%s\r\n', 'Young''s modulus', BDdata{1, 1}, BDdata{1, 2});
    fprintf(f, '%s\t%s\t%s\r\n', 'Poisson''s ratio', BDdata{2, 1}, BDdata{2, 2});
    fprintf(f, '%s\t%s\t%s\r\n', 'Injection rate into the borehole', BDdata{3, 1}, BDdata{3, 2});
    fprintf(f, '%s\t%s\t%s\r\n', 'fluid viscosity', BDdata{4, 1}, BDdata{4, 2});
    fprintf(f, '%s\t%s\t%s\r\n', 'Leakoff coefficient', BDdata{5, 1}, BDdata{5, 2});
    fprintf(f, '%s\t%s\t%s\r\n', 'Spurt loss', BDdata{6, 1}, BDdata{6, 2});
    fprintf(f, '%s\t%s\t%s\r\n\r\n', 'Borehole radius', BDdata{7, 1}, BDdata{7, 2});
    
    fprintf(f, '%s\r\n', 'Fracture type');
    if get(handles.PKNButton, 'Value') == 1
        fprintf(f, '%s\t%s\t%s\r\n\r\n', 'PKN fracture, height:', get(handles.h_KGD, 'String'), get(handles.PKNhUnit, 'String'));
    elseif get(handles.KGDButton, 'Value') == 1
        fprintf(f, '%s\t%s\t%s\r\n\r\n', 'KGD fracture, height:', get(handles.h_KGD, 'String'), get(handles.KGDhUnit, 'String'));
    elseif get(handles.radialButton, 'Value') == 1
        fprintf(f, '%s\r\n\r\n', 'Radial fracture');
    end
    
    fprintf(f, '%s\r\n', 'Injection parameter');
    if get(handles.vButton, 'Value') == 1
        fprintf(f, '%s\t%s\t%s\r\n\r\n', 'By total injected volume:', get(handles.totalV, 'String'), get(handles.injecVUnit, 'String'));
    elseif get(handles.tButton, 'Value') == 1
        fprintf(f, '%s\t%s\t%s\r\n\r\n', 'By total injection time:', get(handles.totalT, 'String'), get(handles.injecTUnit, 'String'));
    end
    
    fprintf(f, '%s\r\n', 'Calculation results');
    fprintf(f, '%s\t%s\t%s\t%s\t%s\t%s\r\n', 'Injection time', 'Injected volume', 'Fracture length', 'Maximum fracture aperture', 'Average fracture aperture', 'Net fluid pressure');
    fprintf(f, '%s\t%s\t%s\t%s\t%s\t%s\r\n', RTdata{6, 2}, RTdata{7, 2}, RTdata{1, 2}, RTdata{3, 2}, RTdata{3, 2}, RTdata{5, 2});
    
    if length(h_HFsim.t_out) == 201
        for i = 1 : 201
            fprintf(f, '%0.6f\t%0.6f\t%0.6f\t%0.6f\t%0.6f\t%0.6f\r\n', h_HFsim.t_out(i), h_HFsim.V_out(i), h_HFsim.L_out(i), h_HFsim.Wmax_out(i), h_HFsim.Wbar_out(i), h_HFsim.Pnet_out(i));
        end
    end
    
    
    fprintf(f, '\r\n');
    fprintf(f, '%s\r\n', '2D aperture profile & 3D fracture shape');
    fprintf(f, '%s\t%s\t%s\r\n', get(handles.text15, 'String'), get(handles.atTorV, 'String'), get(handles.TorVunit, 'String'));
    fprintf(f, '%s\t%s\r\n', 'Aperture scale factor in 3D:', get(handles.scaleFactor, 'String'));
    
    fclose(f);
    
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes when selected cell(s) is changed in baseData.
function baseData_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to baseData (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in resultTable.
function resultTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to resultTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in baseData.
function baseData_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to baseData (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in plotToT.
function plotToT_Callback(hObject, eventdata, handles)
% hObject    handle to plotToT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotToT

try

global uSet h_Units

set(handles.text15, 'String', 'At time t =')
tUnit = h_Units.t_contents{uSet(9, 2)};
set(handles.TorVunit, 'String', tUnit)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in plotToV.
function plotToV_Callback(hObject, eventdata, handles)
% hObject    handle to plotToV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotToV

try
    
global uSet h_Units

set(handles.text15, 'String', 'At volume V =')
vUnit = h_Units.V_contents{uSet(1, 2)};
set(handles.TorVunit, 'String', vUnit)

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

function scaleFactor_Callback(hObject, eventdata, handles)
% hObject    handle to scaleFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleFactor as text
%        str2double(get(hObject,'String')) returns contents of scaleFactor as a double


% --- Executes during object creation, after setting all properties.
function scaleFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Thermal_Callback(hObject, eventdata, handles)
% hObject    handle to Thermal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Thercalculaiton_Callback(hObject, eventdata, handles)
% hObject    handle to Thercalculaiton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global h_HFsim h_Units PKNBvalue KGDBvalue radialBvalue
PKNBvalue=0;
KGDBvalue=0;
radialBvalue=0;
if length(h_HFsim.L_out)>0
    PKNBvalue = get(handles.PKNButton, 'Value');
    KGDBvalue = get(handles.KGDButton, 'Value');
    radialBvalue = get(handles.radialButton, 'Value');
end
TherCal

catch ex
    errmsg = ex.stack.line;
    msgbox([{'HFsim.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
