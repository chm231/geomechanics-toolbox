function varargout = descriptions(varargin)
% DESCRIPTIONS MATLAB code for descriptions.fig
%      DESCRIPTIONS, by itself, creates a new DESCRIPTIONS or raises the existing
%      singleton*.
%
%      H = DESCRIPTIONS returns the handle to a new DESCRIPTIONS or the handle to
%      the existing singleton*.
%
%      DESCRIPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESCRIPTIONS.M with the given input arguments.
%
%      DESCRIPTIONS('Property','Value',...) creates a new DESCRIPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before descriptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to descriptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help descriptions

% Last Modified by GUIDE v2.5 29-Mar-2016 02:16:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @descriptions_OpeningFcn, ...
                   'gui_OutputFcn',  @descriptions_OutputFcn, ...
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


% --- Executes just before descriptions is made visible.
function descriptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to descriptions (see VARARGIN)

% Choose default command line output for descriptions
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes descriptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = descriptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
