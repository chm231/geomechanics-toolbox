
function varargout = Units(varargin)
% UNITS MATLAB code for Units.fig
%      UNITS, by itself, creates a new UNITS or raises the existing
%      singleton*.
%
%      H = UNITS returns the handle to a new UNITS or the handle to
%      the existing singleton*.
%
%      UNITS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNITS.M with the given input arguments.
%
%      UNITS('Property','Value',...) creates a new UNITS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Units_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Units_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Units

% Last Modified by GUIDE v2.5 22-Feb-2016 16:50:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Units_OpeningFcn, ...
                   'gui_OutputFcn',  @Units_OutputFcn, ...
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


% --- Executes just before Units is made visible.
function Units_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Units (see VARARGIN)

% Choose default command line output for Units
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Units wait for user response (see UIRESUME)
% uiwait(handles.figure1);

try

global h_Units uSet uSetDesc

h_Units.V_contents = cellstr(get(handles.volumeOU, 'String'));
h_Units.L_contents = cellstr(get(handles.lengthOU, 'String'));
h_Units.W_contents = cellstr(get(handles.apertureOU, 'String'));
h_Units.h_contents = cellstr(get(handles.heightOU, 'String'));
h_Units.Q_contents = cellstr(get(handles.injecRateOU, 'String'));
h_Units.C_contents = cellstr(get(handles.leakoffOU, 'String'));
h_Units.P_contents = cellstr(get(handles.pressureOU, 'String'));
h_Units.Sp_contents = cellstr(get(handles.spurtOU, 'String'));
h_Units.t_contents = cellstr(get(handles.timeOU, 'String'));
h_Units.E_contents = cellstr(get(handles.YoungsOU, 'String'));
h_Units.Rw_contents = cellstr(get(handles.wellRadiOU, 'String'));
h_Units.mu_contents = cellstr(get(handles.viscoOU, 'String'));

if uSet(1, 1) ~= 0
    set(handles.unitsDesc, 'String', uSetDesc);
    set(handles.volumeIU, 'Value', uSet(1, 1));
    set(handles.volumeOU, 'Value', uSet(1, 2));
    set(handles.lengthIU, 'Value', uSet(2, 1));
    set(handles.lengthOU, 'Value', uSet(2, 2));
    set(handles.apertureIU, 'Value', uSet(3, 1));
    set(handles.apertureOU, 'Value', uSet(3, 2));
    set(handles.heightIU, 'Value', uSet(4, 1));
    set(handles.heightOU, 'Value', uSet(4, 2));
    set(handles.injecRateIU, 'Value', uSet(5, 1));
    set(handles.injecRateOU, 'Value', uSet(5, 2));
    set(handles.leakoffIU, 'Value', uSet(6, 1));
    set(handles.leakoffOU, 'Value', uSet(6, 2));
    set(handles.pressureIU, 'Value', uSet(7, 1));
    set(handles.pressureOU, 'Value', uSet(7, 2));
    set(handles.spurtIU, 'Value', uSet(8, 1));
    set(handles.spurtOU, 'Value', uSet(8, 2));
    set(handles.timeIU, 'Value', uSet(9, 1));
    set(handles.timeOU, 'Value', uSet(9, 2));
    set(handles.YoungsIU, 'Value', uSet(10, 1));
    set(handles.YoungsOU, 'Value', uSet(10, 2));
    set(handles.wellRadiIU, 'Value', uSet(11, 1));
    set(handles.wellRadiOU, 'Value', uSet(11, 2));
    set(handles.viscoIU, 'Value', uSet(12, 1));
    set(handles.viscoOU, 'Value', uSet(12, 2));
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Units.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Outputs from this function are returned to the command line.
function varargout = Units_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in volumeIU.
function volumeIU_Callback(hObject, eventdata, handles)
% hObject    handle to volumeIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns volumeIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from volumeIU


% --- Executes during object creation, after setting all properties.
function volumeIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lengthIU.
function lengthIU_Callback(hObject, eventdata, handles)
% hObject    handle to lengthIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lengthIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lengthIU


% --- Executes during object creation, after setting all properties.
function lengthIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lengthIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in apertureIU.
function apertureIU_Callback(hObject, eventdata, handles)
% hObject    handle to apertureIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns apertureIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from apertureIU


% --- Executes during object creation, after setting all properties.
function apertureIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to apertureIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in heightIU.
function heightIU_Callback(hObject, eventdata, handles)
% hObject    handle to heightIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns heightIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from heightIU


% --- Executes during object creation, after setting all properties.
function heightIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in injecRateIU.
function injecRateIU_Callback(hObject, eventdata, handles)
% hObject    handle to injecRateIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns injecRateIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from injecRateIU


% --- Executes during object creation, after setting all properties.
function injecRateIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to injecRateIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in leakoffIU.
function leakoffIU_Callback(hObject, eventdata, handles)
% hObject    handle to leakoffIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns leakoffIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from leakoffIU


% --- Executes during object creation, after setting all properties.
function leakoffIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leakoffIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pressureIU.
function pressureIU_Callback(hObject, eventdata, handles)
% hObject    handle to pressureIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pressureIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pressureIU


% --- Executes during object creation, after setting all properties.
function pressureIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pressureIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in spurtIU.
function spurtIU_Callback(hObject, eventdata, handles)
% hObject    handle to spurtIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spurtIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spurtIU


% --- Executes during object creation, after setting all properties.
function spurtIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spurtIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in timeIU.
function timeIU_Callback(hObject, eventdata, handles)
% hObject    handle to timeIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns timeIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from timeIU


% --- Executes during object creation, after setting all properties.
function timeIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YoungsIU.
function YoungsIU_Callback(hObject, eventdata, handles)
% hObject    handle to YoungsIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YoungsIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YoungsIU


% --- Executes during object creation, after setting all properties.
function YoungsIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YoungsIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wellRadiIU.
function wellRadiIU_Callback(~, eventdata, handles)
% hObject    handle to wellRadiIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wellRadiIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wellRadiIU


% --- Executes during object creation, after setting all properties.
function wellRadiIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wellRadiIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in volumeOU.
function volumeOU_Callback(hObject, eventdata, handles)
% hObject    handle to volumeOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns volumeOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from volumeOU

% --- Executes during object creation, after setting all properties.
function volumeOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumeOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in lengthOU.
function lengthOU_Callback(hObject, eventdata, handles)
% hObject    handle to lengthOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lengthOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lengthOU


% --- Executes during object creation, after setting all properties.
function lengthOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lengthOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in apertureOU.
function apertureOU_Callback(hObject, eventdata, handles)
% hObject    handle to apertureOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns apertureOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from apertureOU


% --- Executes during object creation, after setting all properties.
function apertureOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to apertureOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in heightOU.
function heightOU_Callback(hObject, eventdata, handles)
% hObject    handle to heightOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns heightOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from heightOU


% --- Executes during object creation, after setting all properties.
function heightOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in injecRateOU.
function injecRateOU_Callback(hObject, eventdata, handles)
% hObject    handle to injecRateOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns injecRateOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from injecRateOU


% --- Executes during object creation, after setting all properties.
function injecRateOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to injecRateOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in leakoffOU.
function leakoffOU_Callback(hObject, eventdata, handles)
% hObject    handle to leakoffOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns leakoffOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from leakoffOU


% --- Executes during object creation, after setting all properties.
function leakoffOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leakoffOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pressureOU.
function pressureOU_Callback(hObject, eventdata, handles)
% hObject    handle to pressureOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pressureOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pressureOU


% --- Executes during object creation, after setting all properties.
function pressureOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pressureOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in spurtOU.
function spurtOU_Callback(hObject, eventdata, handles)
% hObject    handle to spurtOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spurtOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spurtOU


% --- Executes during object creation, after setting all properties.
function spurtOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spurtOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in timeOU.
function timeOU_Callback(hObject, eventdata, handles)
% hObject    handle to timeOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns timeOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from timeOU


% --- Executes during object creation, after setting all properties.
function timeOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YoungsOU.
function YoungsOU_Callback(hObject, eventdata, handles)
% hObject    handle to YoungsOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YoungsOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YoungsOU


% --- Executes during object creation, after setting all properties.
function YoungsOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YoungsOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wellRadiOU.
function wellRadiOU_Callback(hObject, eventdata, handles)
% hObject    handle to wellRadiOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wellRadiOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wellRadiOU


% --- Executes during object creation, after setting all properties.
function wellRadiOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wellRadiOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in viscoIU.
function viscoIU_Callback(hObject, eventdata, handles)
% hObject    handle to viscoIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns viscoIU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from viscoIU


% --- Executes during object creation, after setting all properties.
function viscoIU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to viscoIU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in viscoOU.
function viscoOU_Callback(hObject, eventdata, handles)
% hObject    handle to viscoOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns viscoOU contents as cell array
%        contents{get(hObject,'Value')} returns selected item from viscoOU


% --- Executes during object creation, after setting all properties.
function viscoOU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to viscoOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function unitsDesc_Callback(hObject, eventdata, handles)
% hObject    handle to unitsDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of unitsDesc as text
%        str2double(get(hObject,'String')) returns contents of unitsDesc as a double


% --- Executes during object creation, after setting all properties.
function unitsDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unitsDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global uSet uSetDesc

[file, path] = uigetfile('*txt', 'Load units');
if file ~= 0
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'r');
    
    fgetl(f);
    uSetDesc = fgetl(f);
    fgetl(f);
    fgetl(f);

    uSet(1, :) = fscanf(f, 'Fluid volume\t%d\t%d\r\n', 2);
    uSet(2, :) = fscanf(f, 'Fracture length\t%d\t%d\r\n', 2);
    uSet(3, :) = fscanf(f, 'Fracture aperture\t%d\t%d\r\n', 2);
    uSet(4, :) = fscanf(f, 'Fracture height\t%d\t%d\r\n', 2);
    uSet(5, :) = fscanf(f, 'Injection rate\t%d\t%d\r\n', 2);
    uSet(6, :) = fscanf(f, 'Leakoff coefficient\t%d\t%d\r\n', 2);
    uSet(7, :) = fscanf(f, 'Pressure\t%d\t%d\r\n', 2);
    uSet(8, :) = fscanf(f, 'Spurt loss\t%d\t%d\r\n', 2);
    uSet(9, :) = fscanf(f, 'Time\t%d\t%d\r\n', 2);
    uSet(10, :) = fscanf(f, 'Young''s modulus\t%d\t%d\r\n', 2);
    uSet(11, :) = fscanf(f, 'Borehole radius\t%d\t%d\r\n', 2);
    uSet(12, :) = fscanf(f, 'Fluid viscosity\t%d\t%d\r\n', 2);

    set(handles.unitsDesc, 'String', uSetDesc);
    set(handles.volumeIU, 'Value', uSet(1, 1));
    set(handles.volumeOU, 'Value', uSet(1, 2));
    set(handles.lengthIU, 'Value', uSet(2, 1));
    set(handles.lengthOU, 'Value', uSet(2, 2));
    set(handles.apertureIU, 'Value', uSet(3, 1));
    set(handles.apertureOU, 'Value', uSet(3, 2));
    set(handles.heightIU, 'Value', uSet(4, 1));
    set(handles.heightOU, 'Value', uSet(4, 2));
    set(handles.injecRateIU, 'Value', uSet(5, 1));
    set(handles.injecRateOU, 'Value', uSet(5, 2));
    set(handles.leakoffIU, 'Value', uSet(6, 1));
    set(handles.leakoffOU, 'Value', uSet(6, 2));
    set(handles.pressureIU, 'Value', uSet(7, 1));
    set(handles.pressureOU, 'Value', uSet(7, 2));
    set(handles.spurtIU, 'Value', uSet(8, 1));
    set(handles.spurtOU, 'Value', uSet(8, 2));
    set(handles.timeIU, 'Value', uSet(9, 1));
    set(handles.timeOU, 'Value', uSet(9, 2));
    set(handles.YoungsIU, 'Value', uSet(10, 1));
    set(handles.YoungsOU, 'Value', uSet(10, 2));
    set(handles.wellRadiIU, 'Value', uSet(11, 1));
    set(handles.wellRadiOU, 'Value', uSet(11, 2));
    set(handles.viscoIU, 'Value', uSet(12, 1));
    set(handles.viscoOU, 'Value', uSet(12, 2));
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Units.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global uSet uSetDesc

[file, path] = uiputfile('*.txt', 'Save units');
if file ~= 0
    
    uSetDesc = get(handles.unitsDesc, 'String');
    uSet(1, 1) = get(handles.volumeIU, 'Value');
    uSet(1, 2) = get(handles.volumeOU, 'Value');
    uSet(2, 1) = get(handles.lengthIU, 'Value');
    uSet(2, 2) = get(handles.lengthOU, 'Value');
    uSet(3, 1) = get(handles.apertureIU, 'Value');
    uSet(3, 2) = get(handles.apertureOU, 'Value');
    uSet(4, 1) = get(handles.heightIU, 'Value');
    uSet(4, 2) = get(handles.heightOU, 'Value');
    uSet(5, 1) = get(handles.injecRateIU, 'Value');
    uSet(5, 2) = get(handles.injecRateOU, 'Value');
    uSet(6, 1) = get(handles.leakoffIU, 'Value');
    uSet(6, 2) = get(handles.leakoffOU, 'Value');
    uSet(7, 1) = get(handles.pressureIU, 'Value');
    uSet(7, 2) = get(handles.pressureOU, 'Value');
    uSet(8, 1) = get(handles.spurtIU, 'Value');
    uSet(8, 2) = get(handles.spurtOU, 'Value');
    uSet(9, 1) = get(handles.timeIU, 'Value');
    uSet(9, 2) = get(handles.timeOU, 'Value');
    uSet(10, 1) = get(handles.YoungsIU, 'Value');
    uSet(10, 2) = get(handles.YoungsOU, 'Value');
    uSet(11, 1) = get(handles.wellRadiIU, 'Value');
    uSet(11, 2) = get(handles.wellRadiOU, 'Value');
    uSet(12, 1) = get(handles.viscoIU, 'Value');
    uSet(12, 2) = get(handles.viscoOU, 'Value');
    
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'W');
    fprintf(f, '%s\r\n', 'Description:');
    fprintf(f, '%s \r\n\r\n', uSetDesc);
    fprintf(f, '%s\t%s\t%s\r\n', 'Parameter', 'Input unit', 'Output unit');
    fprintf(f, '%s\t%d\t%d\r\n', 'Fluid volume', uSet(1, 1), uSet(1, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Fracture length', uSet(2, 1), uSet(2, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Fracture aperture', uSet(3, 1), uSet(3, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Fracture height', uSet(4, 1), uSet(4, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Injection rate', uSet(5, 1), uSet(5, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Leakoff coefficient', uSet(6, 1), uSet(6, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Pressure', uSet(7, 1), uSet(7, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Spurt loss', uSet(8, 1), uSet(8, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Time', uSet(9, 1), uSet(9, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Young''s modulus', uSet(10, 1), uSet(10, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Borehole radius', uSet(11, 1), uSet(11, 2));
    fprintf(f, '%s\t%d\t%d\r\n', 'Fluid viscosity', uSet(12, 1), uSet(12, 2));
    fclose(f);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Units.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end



% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global uSet h_HFsim h_Units BDdata RTdata 

uSet(1, 1) = get(handles.volumeIU, 'Value');
uSet(1, 2) = get(handles.volumeOU, 'Value');
uSet(2, 1) = get(handles.lengthIU, 'Value');
uSet(2, 2) = get(handles.lengthOU, 'Value');
uSet(3, 1) = get(handles.apertureIU, 'Value');
uSet(3, 2) = get(handles.apertureOU, 'Value');
uSet(4, 1) = get(handles.heightIU, 'Value');
uSet(4, 2) = get(handles.heightOU, 'Value');
uSet(5, 1) = get(handles.injecRateIU, 'Value');
uSet(5, 2) = get(handles.injecRateOU, 'Value');
uSet(6, 1) = get(handles.leakoffIU, 'Value');
uSet(6, 2) = get(handles.leakoffOU, 'Value');
uSet(7, 1) = get(handles.pressureIU, 'Value');
uSet(7, 2) = get(handles.pressureOU, 'Value');
uSet(8, 1) = get(handles.spurtIU, 'Value');
uSet(8, 2) = get(handles.spurtOU, 'Value');
uSet(9, 1) = get(handles.timeIU, 'Value');
uSet(9, 2) = get(handles.timeOU, 'Value');
uSet(10, 1) = get(handles.YoungsIU, 'Value');
uSet(10, 2) = get(handles.YoungsOU, 'Value');
uSet(11, 1) = get(handles.wellRadiIU, 'Value');
uSet(11, 2) = get(handles.wellRadiOU, 'Value');
uSet(12, 1) = get(handles.viscoIU, 'Value');
uSet(12, 2) = get(handles.viscoOU, 'Value');

unit = h_Units.h_contents{uSet(4, 1)};
set(h_HFsim.PKNhUnit, 'String', unit); 
set(h_HFsim.KGDhUnit, 'String', unit);
switch uSet(4, 1)
    case 1
        h_Units.heightIUFactor = 1.0e-2;
    case 2
        h_Units.heightIUFactor = 0.3048;
    case 3
        h_Units.heightIUFactor = 0.0254;
    case 4
        h_Units.heightIUFactor = 1.0e3;
    case 5
        h_Units.heightIUFactor = 1;
    case 6
        h_Units.heightIUFactor = 0.9144;
end

unit = h_Units.V_contents{uSet(1, 1)};
set(h_HFsim.injecVUnit, 'String', unit);
BDdata{6, 2} = unit;
switch uSet(1, 1)
    case 1
        h_Units.volumeIUFactor = 4.54609188;
    case 2
        h_Units.volumeIUFactor = 3.78541178;
    case 3
        h_Units.volumeIUFactor = 0.11924071;
    case 4
        h_Units.volumeIUFactor = 2.83168466e-2;
    case 5
        h_Units.volumeIUFactor = 0.001;
    case 6
        h_Units.volumeIUFactor = 1;
    case 7
        h_Units.volumeIUFactor = 4.54609188e-3;
    case 8
        h_Units.volumeIUFactor = 3.78541178e-3;
end

unit = h_Units.t_contents{uSet(9, 1)};
set(h_HFsim.injecTUnit, 'String', unit);
switch uSet(9, 1)
    case 1
        h_Units.timeIUFactor = 8.64e4;
    case 2
        h_Units.timeIUFactor = 3600;
    case 3
        h_Units.timeIUFactor = 60;
    case 4
        h_Units.timeIUFactor = 1;
    case 5
        h_Units.timeIUFactor = 3.1536e7;
end

unit = h_Units.t_contents{uSet(9, 2)};
RTdata{6, 2} = unit;
switch uSet(9, 2)
    case 1
        h_Units.timeOUFactor = 1.15740741e-5;
    case 2
        h_Units.timeOUFactor = 2.77777778e-4;
    case 3
        h_Units.timeOUFactor = 1.66666667e-2;
    case 4
        h_Units.timeOUFactor = 1;
    case 5
        h_Units.timeOUFactor = 3.17097920e-8;
end

unit = h_Units.E_contents{uSet(10, 1)};
BDdata{1, 2} = unit;
switch uSet(10, 1)
    case 1
        h_Units.YoungsIUFactor = 6.89476e9;
    case 2
        h_Units.YoungsIUFactor = 6.89476e6;
    case 3
        h_Units.YoungsIUFactor = 101325;
    case 4
        h_Units.YoungsIUFactor = 100000;
    case 5
        h_Units.YoungsIUFactor = 1.0e9;
    case 6
        h_Units.YoungsIUFactor = 9.80665e4;
    case 7
        h_Units.YoungsIUFactor = 1000;
    case 8
        h_Units.YoungsIUFactor = 4.78802590;
    case 9
        h_Units.YoungsIUFactor = 1.0e6;
    case 10
        h_Units.YoungsIUFactor = 1;
    case 11
        h_Units.YoungsIUFactor = 6.89476e3;
end

unit = h_Units.Q_contents{uSet(5, 1)};
BDdata{3, 2} = unit;
switch uSet(5, 1)
    case 1
        h_Units.injecRateIUFactor = 6.30901963e-4;
    case 2
        h_Units.injecRateIUFactor = 1.38010081e-6;
    case 3
        h_Units.injecRateIUFactor = 1.98734517e-3;
    case 4
        h_Units.injecRateIUFactor = 3.2774128e-7;
    case 5
        h_Units.injecRateIUFactor = 4.71947443e-4;
    case 6
        h_Units.injecRateIUFactor = 1.66666667e-5;
    case 7
        h_Units.injecRateIUFactor = 1.15740741e-5;
    case 8
        h_Units.injecRateIUFactor = 1.66666667e-2;
    case 9
        h_Units.injecRateIUFactor = 7.5768198e-5;
    case 10
        h_Units.injecRateIUFactor = 4.38126363e-8;
    case 11
        h_Units.injecRateIUFactor = 6.30901963e-5;
    case 12
        h_Units.injecRateIUFactor = 0.001;
end

unit = h_Units.mu_contents{uSet(12, 1)};
BDdata{4, 2} = unit;
switch uSet(12, 1)
    case 1
        h_Units.viscoIUFactor = 1;
    case 2
        h_Units.viscoIUFactor = 0.1;
    case 3
        h_Units.viscoIUFactor = 0.001;
end

unit = h_Units.C_contents{uSet(6, 1)};
BDdata{5, 2} = unit;
switch uSet(6, 1)
    case 1
        h_Units.leakoffIUFactor = 1.29099445e-3;
    case 2
        h_Units.leakoffIUFactor = 0.01;
    case 3
        h_Units.leakoffIUFactor = 3.93495108e-2;
    case 4
        h_Units.leakoffIUFactor = 0.3048;
    case 5
        h_Units.leakoffIUFactor = 1.29099445e-1;
    case 6
        h_Units.leakoffIUFactor = 1;
    case 7
        h_Units.leakoffIUFactor = 1.29099445e-4;
    case 8
        h_Units.leakoffIUFactor = 0.001;
end

unit = h_Units.Sp_contents{uSet(8, 1)};
BDdata{6, 2} = unit;
switch uSet(8, 1)
    case 1
        h_Units.spurtIUFactor = 0.01;
    case 2
        h_Units.spurtIUFactor = 0.3048;
    case 3
        h_Units.spurtIUFactor = 0.0254;
    case 4
        h_Units.spurtIUFactor = 1000;
    case 5
        h_Units.spurtIUFactor = 1;
    case 6
        h_Units.spurtIUFactor = 0.9144;
end

unit = h_Units.Rw_contents{uSet(11, 1)};
BDdata{7, 2} = unit;
switch uSet(11, 1)
    case 1
        h_Units.wellRadiIUFactor = 0.01;
    case 2
        h_Units.wellRadiIUFactor = 0.3048;
    case 3
        h_Units.wellRadiIUFactor = 0.0254;
    case 4
        h_Units.wellRadiIUFactor = 1000;
    case 5
        h_Units.wellRadiIUFactor = 1;
    case 6
        h_Units.wellRadiIUFactor = 0.001;
    case 7
        h_Units.wellRadiIUFactor = 0.9144;
end

unit = h_Units.L_contents{uSet(2, 2)};
RTdata{1, 2} = unit;
switch uSet(2, 2)
    case 1
        h_Units.lengthOUFactor = 100;
    case 2
        h_Units.lengthOUFactor = 3.2808399;
    case 3
        h_Units.lengthOUFactor = 39.3700787;
    case 4
        h_Units.lengthOUFactor = 0.001;
    case 5
        h_Units.lengthOUFactor = 1;
    case 6
        h_Units.lengthOUFactor = 1.0936133;
end

unit = h_Units.h_contents{uSet(4, 2)};
RTdata{2, 2} = unit;
switch uSet(4, 2)
    case 1
        h_Units.heightOUFactor = 100;
    case 2
        h_Units.heightOUFactor = 3.2808399;
    case 3
        h_Units.heightOUFactor = 39.3700787;
    case 4
        h_Units.heightOUFactor = 0.001;
    case 5
        h_Units.heightOUFactor = 1;
    case 6
        h_Units.heightOUFactor = 1.0936133;
end

unit = h_Units.W_contents{uSet(3, 2)};
RTdata{3, 2} = unit;
RTdata{4, 2} = unit;
switch uSet(3, 2)
    case 1
        h_Units.apertureOUFactor = 100;
    case 2
        h_Units.apertureOUFactor = 3.2808399;
    case 3
        h_Units.apertureOUFactor = 39.3700787;
    case 4
        h_Units.apertureOUFactor = 1000;
end

unit = h_Units.P_contents{uSet(7,2)};
RTdata{5, 2} = unit;
switch uSet(7, 2)
    case 1
        h_Units.pressureOUFactor = 1.45037681e-10;
    case 2
        h_Units.pressureOUFactor = 1.45037681e-7;
    case 3
        h_Units.pressureOUFactor = 9.86923267e-6;
    case 4
        h_Units.pressureOUFactor = 1.0e-5;
    case 5
        h_Units.pressureOUFactor = 1.01971621e-5;
    case 6
        h_Units.pressureOUFactor = 0.001;
    case 7
        h_Units.pressureOUFactor = 2.08854342e-2;
    case 8
        h_Units.pressureOUFactor = 1.0e-6;
    case 9
        h_Units.pressureOUFactor = 1;
    case 10
        h_Units.pressureOUFactor = 1.45037681e-4;
end

unit = h_Units.V_contents{uSet(1, 2)};
RTdata{7, 2} = unit;
switch uSet(1, 2)
    case 1
        h_Units.volumeOUFactor = 0.219969157;
    case 2
        h_Units.volumeOUFactor = 0.264172053;
    case 3
        h_Units.volumeOUFactor = 8.38639757;
    case 4
        h_Units.volumeOUFactor = 35.3146667;
    case 5
        h_Units.volumeOUFactor = 1000;
    case 6
        h_Units.volumeOUFactor = 1;
    case 7
        h_Units.volumeOUFactor = 219.969157;
    case 8
        h_Units.volumeOUFactor = 264.172053;
end

set(h_HFsim.baseData, 'Data', BDdata);
set(h_HFsim.resultTable, 'Data', RTdata);

close Units

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Units.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
