function varargout = Simulator(varargin)
% SIMULATOR MATLAB code for Simulator.fig
%      SIMULATOR, by itself, creates a new SIMULATOR or raises the existing
%      singleton*.
%
%      H = SIMULATOR returns the handle to a new SIMULATOR or the handle to
%      the existing singleton*.
%
%      SIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMULATOR.M with the given input arguments.
%
%      SIMULATOR('Property','Value',...) creates a new SIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Simulator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Simulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Simulator

% Last Modified by GUIDE v2.5 17-Apr-2017 15:52:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Simulator_OpeningFcn, ...
                   'gui_OutputFcn',  @Simulator_OutputFcn, ...
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


% --- Executes just before Simulator is made visible.
function Simulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Simulator (see VARARGIN)

% Choose default command line output for Simulator
handles.output = hObject;

% Update handles structure
try
    
guidata(hObject, handles);
[x,map]=imread('3.jpg');
imshow(x, 'Parent', handles.axes1)
[x,map]=imread('7.jpg');
imshow(x, 'Parent', handles.axes3)
[x,map]=imread('5.jpg');
imshow(x, 'Parent', handles.axes4)
[x,map]=imread('b.jpg');
imshow(x, 'Parent', handles.axes5)
[x,map]=imread('9.jpg');
imshow(x, 'Parent', handles.axes6)
[x,map]=imread('8.jpg');
imshow(x, 'Parent', handles.axes7)
% UIWAIT makes Simulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Outputs from this function are returned to the command line.
function varargout = Simulator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in DFNbutton.
function DFNbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DFNbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try    
threeddfngui
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in BSAbutton.
function BSAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to BSAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
BSA210831_v2
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in HFbutton.
function HFbutton_Callback(hObject, eventdata, handles)
% hObject    handle to HFbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
HFsim
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in HSbutton.
function HSbutton_Callback(hObject, eventdata, handles)
% hObject    handle to HSbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
HSsim
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in Tempbutton.
function Tempbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Tempbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
TherCal
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in stereoButton.
function stereoButton_Callback(hObject, eventdata, handles)
% hObject    handle to stereoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
stereoProjection
catch ex
    errmsg = ex.stack.line;
    msgbox([{'Simulator.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
