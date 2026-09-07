function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 03-Aug-2016 17:42:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global list_circle list_desig list_FCM

switch hObject
    case handles.radiobutton1
        set(handles.listbox2,'String',list_circle,'Value',1);
    case handles.radiobutton2
        set(handles.listbox2,'String',list_desig,'Value',1);
    case handles.radiobutton3
        set(handles.listbox2,'String',list_FCM,'Value',1);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'untitled.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global hCircle hWindow fcmpoints list_circle list_desig list_FCM
 
n = get(handles.listbox2,'Value');
s = size(get(handles.listbox2,'String'),1);

if get(handles.radiobutton1,'Value') == 1
    if isempty(get(handles.listbox2,'String')) == 0
        for i = 0:2
            delete(hCircle{3*n-i});
        end
        tmphCircle = cell(1,3*s-3);
        if s == 1
            hCircle = [];
            list_circle = [];
            set(handles.radiobutton1,'enable','off');
            if strcmp(get(handles.radiobutton2,'enable'),'on') == 1
                set(handles.radiobutton2,'Value',1);
                set(handles.listbox2,'String',list_desig,'Value',1);
            elseif strcmp(get(handles.radiobutton3,'enable'),'on') == 1
                set(handles.radiobutton3,'Value',1);
                set(handles.listbox2,'String',list_FCM,'Value',1);
            else
                set(handles.listbox2,'String',list_circle,'Value',1);
            end

        else
            if n == s
                for i = 1:3*n-3
                    tmphCircle{i} = hCircle{i};
                end
                set(handles.listbox2,'Value',n-1);
            else
                for i = 1:3*n-3
                    tmphCircle{i} = hCircle{i};
                end
                for j = 3*n+1:3*s
                    tmphCircle{j-3} = hCircle{j};
                end
            end
            hCircle = tmphCircle;
            clearvars tmphCircle;
            list_circle(n,:) = [];
            set(handles.listbox2,'String',list_circle);
        end
    end
elseif get(handles.radiobutton2,'Value') == 1
    if isempty(get(handles.listbox2,'String')) == 0
        s = s/2;
        n = ceil(n/2);
        for i = 0:4
            delete(hWindow{5*n-i});
        end
        tmphWindow = cell(1,5*s-5);
        if s == 1
            hWindow = [];
            list_desig = [];
            set(handles.radiobutton2,'enable','off');
            if strcmp(get(handles.radiobutton1,'enable'),'on') == 1
                set(handles.radiobutton1,'Value',1);
                set(handles.listbox2,'String',list_circle,'Value',1);
            elseif strcmp(get(handles.radiobutton3,'enable'),'on') == 1
                set(handles.radiobutton3,'Value',1);
                set(handles.listbox2,'String',list_FCM,'Value',1);
            else
                set(handles.listbox2,'String',list_desig,'Value',1);
            end
        else
            if n == s
                for i = 1:5*n-5
                    tmphWindow{i} = hWindow{i};
                end
                set(handles.listbox2,'Value',2*s-2);
            else
                for i = 1:5*n-5
                    tmphWindow{i} = hWindow{i};
                end
                for j = 5*n+1:5*s
                    tmphWindow{j-5} = hWindow{j};
                end
            end
            hWindow = tmphWindow;
            clearvars tmphWindow;
            list_desig(2*n-1,:) = [];
            list_desig(2*n-1,:) = [];
            set(handles.listbox2,'String',list_desig);
        end
    end
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'untitled.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global points hCircle hWindow fcmpoints list_circle list_desig list_FCM

for i = 1:size(hCircle,2)
    delete(hCircle{i});
end
for i = 1:size(hWindow,2)
    delete(hWindow{i});
end
for i = 1:size(fcmpoints,2)
    delete(fcmpoints{i});
end
list_circle = [];
list_desig = [];
list_FCM = [];
set(handles.radiobutton1,'enable','off');
set(handles.radiobutton2,'enable','off');
set(handles.radiobutton3,'enable','off');
points.Visible = 'on';
set(handles.listbox2,'String',[]);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'untitled.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
