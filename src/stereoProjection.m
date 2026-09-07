function varargout = stereoProjection(varargin)
% STEREOPROJECTION MATLAB code for stereoProjection.fig
%      STEREOPROJECTION, by itself, creates a new STEREOPROJECTION or raises the existing
%      singleton*.
%
%      H = STEREOPROJECTION returns the handle to a new STEREOPROJECTION or the handle to
%      the existing singleton*.
%
%      STEREOPROJECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEREOPROJECTION.M with the given input arguments.
%
%      STEREOPROJECTION('Property','Value',...) creates a new STEREOPROJECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stereoProjection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stereoProjection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stereoProjection

% Last Modified by GUIDE v2.5 09-Aug-2016 16:57:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stereoProjection_OpeningFcn, ...
                   'gui_OutputFcn',  @stereoProjection_OutputFcn, ...
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


% --- Executes just before stereoProjection is made visible.
function stereoProjection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stereoProjection (see VARARGIN)

% Choose default command line output for stereoProjection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stereoProjection wait for user response (see UIRESUME)
% uiwait(handles.figure1);

try
    
axis off
set(gcf, 'color', 'w')
global drawCheck 
drawCheck = 0;
set(handles.netSlider, 'enable', 'off')
global hCircle
hCircle = cell(1);
global hWindow
hWindow = cell(1);

hg = untitled;
movegui(hg, 'east');
handles.hg = guihandles(hg);
guidata(hObject, handles);

% for test
% a = fopen('exampleData.txt','r');
% A = fscanf(a,'%d',[2 286]);
% A = num2cell(A');
% set(handles.mainTable,'Data',A);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Outputs from this function are returned to the command line.
function varargout = stereoProjection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in polePlot.
function polePlot_Callback(hObject, eventdata, handles)
% hObject    handle to polePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
hold off
global points
jData = get(handles.mainTable, 'Data');
upper = get(handles.upperHemi, 'Value');
equalAngle = get(handles.equalAngle, 'Value');

set(handles.showNet,'enable', 'on');
set(handles.showCircle,'enable', 'on');
set(handles.desigSet,'enable', 'on');
set(handles.contour,'enable', 'on');
set(handles.clustering,'enable','on');
set(handles.hg.listbox2,'enable','on');
set(handles.hg.pushbutton1,'enable','on');
set(handles.hg.pushbutton2,'enable','on');

check = 0;
for i=1:size(jData, 1)
    if strcmp(jData{i,1}, '')
        check = 1;
        break
    end
end
if check == 1
    dataSize = i-1;
else
    dataSize = i;
end

tre = zeros(dataSize,1);
plu = zeros(dataSize,1);
for i = 1:dataSize
    tre(i) = jData{i,2}*pi/180 + pi;
    plu(i) = 0.5*pi - jData{i,1}*pi/180;
end
[x, y] = convert_TPCoor(tre, plu, upper, equalAngle);

scatter(0,0,60,'+', 'markeredgecolor', 'k', 'linewidth', 1)
hold on
points = scatter(x,y,25,'s', 'linewidth', 1.3, 'markeredgecolor', 'b');
rectangle('Position', [-1 -1 2 2], 'Curvature', 1)

for i=1:36
    x = cos(pi/18*(i-1))*[1 1.05];
    y = sin(pi/18*(i-1))*[1 1.05];
    plot(x, y, 'k')
end

text(-0.04, 1.15, 'N', 'Fontsize', 16, 'fontweight', 'bold', 'color', 'k')
text(-0.04, -1.15, 'S', 'Fontsize', 16, 'fontweight', 'bold', 'color', 'k')
text(1.1, 0, 'E', 'Fontsize', 16, 'fontweight', 'bold', 'color', 'k')
text(-1.2, 0, 'W', 'Fontsize', 16, 'fontweight', 'bold', 'color', 'k')

if upper==1
    if equalAngle==1 % upper hemisphere, equal angle
        title('Equal-Angle, Upper Hemisphere', 'fontsize', 16, 'color', 'k')
    else % upper hemisphere, equal area
        title('Equal-Area, Upper Hemisphere', 'fontsize', 16, 'color', 'k')
    end
else
    if equalAngle==1 % lower hemisphere, equal angle
        title('Equal-Angle, Lower Hemisphere', 'fontsize', 16, 'color', 'k')
    else  % lower hemisphere, equal area
        title('Equal-Area, Lower Hemisphere', 'fontsize', 16, 'color', 'k')
    end 
end

axis([-1.0 1.0 -1.1 1.2])
axis off
axis equal

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end




% --- Executes on button press in importButton.
function importButton_Callback(hObject, eventdata, handles)
% hObject    handle to importButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
check = 0;
[file, path] = uigetfile('*.txt', 'File open');
if file ~= 0
    fname = sprintf('%s%s', path, file);
    f = fopen(fname, 'r');
    
    fgetl(f);
    dataCheck = fgetl(f);
    if dataCheck ~= -1 % saved joint data exist
        dc = dataCheck;
        i = 0;
        while dc ~= -1
            i=i+1;
            temp = textscan(dc, '%f\t%f\r\n', 2);
            jData(i, :) = {temp{1} temp{2}};
            check = 1;
            dc = fgetl(f);
        end
    end
    fclose(f);
end
if check
    set(handles.mainTable, 'Data', jData)
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in clearButton.
function clearButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
jData = cell(2, 2);
jData = {'' '';'' '';'' '';'' ''};
set(handles.mainTable, 'Data', jData)
set(handles.dipText, 'string', '')
set(handles.dipDirecText, 'string', '')

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
dip = get(handles.dipText, 'string');
dipDirec = get(handles.dipDirecText, 'string');
jData = get(handles.mainTable, 'Data');
check=0;
if ~(isempty(dip) || isempty(dipDirec))
    for i=1:size(jData, 1)
        if strcmp(jData{i, 1}, '')
            jData(i, :) = {str2num(dip) str2num(dipDirec)};
            check=1;
            break
        end
    end
    if check==0
        jData(i+1, :) = {str2num(dip) str2num(dipDirec)};
    end
    set(handles.mainTable, 'Data', jData)
    set(handles.dipText,'String',[]);
    set(handles.dipDirecText,'String',[]);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function dipText_Callback(hObject, eventdata, handles)
% hObject    handle to dipText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dipText as text
%        str2double(get(hObject,'String')) returns contents of dipText as a double


% --- Executes during object creation, after setting all properties.
function dipText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dipDirecText_Callback(hObject, eventdata, handles)
% hObject    handle to dipDirecText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dipDirecText as text
%        str2double(get(hObject,'String')) returns contents of dipDirecText as a double


% --- Executes during object creation, after setting all properties.
function dipDirecText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipDirecText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in upperHemi.
function upperHemi_Callback(hObject, eventdata, handles)
% hObject    handle to upperHemi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of upperHemi


% --- Executes on button press in lowerHemi.
function lowerHemi_Callback(hObject, eventdata, handles)
% hObject    handle to lowerHemi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lowerHemi


% --- Executes on button press in equalAngle.
function equalAngle_Callback(hObject, eventdata, handles)
% hObject    handle to equalAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of equalAngle


% --- Executes on button press in equalArea.
function equalArea_Callback(hObject, eventdata, handles)
% hObject    handle to equalArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of equalArea


% --- Executes on button press in enlargeButton.
function enlargeButton_Callback(hObject, eventdata, handles)
% hObject    handle to enlargeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global result

GUI_fig_children=get(gcf,'children');
Fig_Axes=findobj(GUI_fig_children,'type','Axes');
fig=figure;ax=axes;clf;
new_handle=copyobj(Fig_Axes,fig);
set(gca,'ActivePositionProperty','outerposition')
set(gca,'Units','normalized')
set(gca,'OuterPosition',[0 0 1 1])
set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
set(gcf, 'color', 'w')
if get(handles.contour, 'value') == 1
    colormap(jet(10))
    hcolorbar = colorbar('YTick', linspace(0, max(max(result)), 11));
    caxis([0 max(max(result))])
    hcolorbar.Label.String = '% of poles per 1% hemisphere area';
    hcolorbar.Label.FontSize = 12;
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on slider movement.
function netSlider_Callback(hObject, eventdata, handles)
% hObject    handle to netSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

try

global drawCheck hNet

angle = round(get(handles.netSlider, 'value'), 2);
angleText = num2str(angle);
set(handles.netRotAngle, 'String', angleText)
did = (90+angle)*pi/180;
if drawCheck == 1
    for i = 1:size(hNet, 2)
        delete(hNet{i})
    end
    drawCheck = 0;
end
if get(handles.equalAngle, 'value')==1 % show Wulff net
    hNet = wulffNet(did);
    drawCheck = 1;
else % show Schmidt net
    hNet = schmidtNet(did);
    drawCheck = 1;
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes during object creation, after setting all properties.
function netSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to netSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in netButton.
function netButton_Callback(hObject, eventdata, handles)
% hObject    handle to netButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function dipSlider_Callback(hObject, eventdata, handles)
% hObject    handle to dipSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function dipSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function dipDirecSlider_Callback(hObject, eventdata, handles)
% hObject    handle to dipDirecSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function dipDirecSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipDirecSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in showNet.
function showNet_Callback(hObject, eventdata, handles)
% hObject    handle to showNet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global drawCheck hNet

% Hint: get(hObject,'Value') returns toggle state of showNet
if get(handles.showNet, 'Value') == 1
    set(handles.netSlider, 'enable', 'on')
    set(handles.netSlider, 'value', 0)
    set(handles.text5,'enable','on')
    angle = round(get(handles.netSlider, 'value'), 2);
    angleText = num2str(angle);
    set(handles.netRotAngle, 'String', angleText)
    did = (90+angle)*pi/180;
    if drawCheck == 1
        for i = 1:size(hNet, 2)
            delete(hNet{i})
        end
        drawCheck = 0;
    end
    if get(handles.equalAngle, 'value')==1 % show Wulff net
        hNet = wulffNet(did);
        drawCheck = 1;
    else % show Schmidt net
        hNet = schmidtNet(did);
        drawCheck = 1;
    end
else
    set(handles.netSlider, 'enable', 'off')
    set(handles.netRotAngle, 'String', '')
    set(handles.text5,'enable','off')
    for i = 1:size(hNet, 2)
        delete(hNet{i})
    end
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in showCircle.
function showCircle_Callback(hObject, eventdata, handles)
% hObject    handle to showCircle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showCircle

try
    
global hCircle list_circle list_desig list_FCM
upper = get(handles.upperHemi, 'Value');
equalAngle = get(handles.equalAngle, 'Value');

if get(handles.showCircle, 'Value') == 1
    set(handles.add,'enable','on');
    set(handles.text11,'enable','on');
    set(handles.text12,'enable','on');
    set(handles.hg.radiobutton1,'enable','on','Value',1);
    set(handles.hg.listbox2,'String',list_circle);
    while true
        [x, y, button] = ginput(1);
        if button == 1
            if size(hCircle, 2) == 1
                hCircle{1} = scatter(x,y,30,'s', 'linewidth', 1.3, 'markeredgecolor', 'r', 'markerFaceColor', 'r');
            else
                hCircle{size(hCircle, 2)+1} = scatter(x,y,30,'s', 'linewidth', 1.3, 'markeredgecolor', 'r', 'markerFaceColor', 'r');
            end
            
            if upper == 1
                if equalAngle == 1 % upper, equal angle
                    plu = pi/2-2*atan(sqrt(x^2+y^2)); % plunge of pole
                    if plu == pi/2 % pole at the center
                        tre = -pi;
                    else
                        if x == 0 % pole on the NS line
                            if y > 0
                                tre = 0;
                            else
                                tre = pi;
                            end
                        elseif y == 0 % pole on the WE line
                            if x > 0
                                tre = pi/2;
                            else
                                tre = 3*pi/2;
                            end
                        else % general cases
                            if x > 0
                                tre = pi/2-atan(y/x);
                            else
                                tre = -pi/2-atan(y/x);
                            end
                        end
                    end
                    di = pi/2-plu;
                    did = tre-pi;
                    if did<0
                        did = did+2*pi;
                    end
                    hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                    label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                    hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14); 
                    
                    if isempty(list_circle) == 1
                        list_circle = label;
                    else
                        list_circle = char(list_circle,label);
                    end
                    set(handles.hg.listbox2,'String',list_circle);
                else % upper, equal area
                    plu = -pi/2+2*acos(sqrt((x^2+y^2)/2)); % plunge of pole
                    if plu == pi/2 % pole at the center
                        tre = -pi;
                    else
                        if x == 0 % pole on the NS line
                            if y > 0
                                tre = 0;
                            else
                                tre = pi;
                            end
                        elseif y == 0 % pole on the WE line
                            if x > 0
                                tre = pi/2;
                            else
                                tre = 3*pi/2;
                            end
                        else % general cases
                            if x > 0
                                tre = pi/2-atan(y/x);
                            else
                                tre = -pi/2-atan(y/x);
                            end
                        end
                    end
                    di = pi/2-plu;
                    did = tre-pi;
                    if did<0
                        did = did+2*pi;
                    end
                    hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                    label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                    hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14);
                    
                    if isempty(list_circle) == 1
                        list_circle = label;
                    else
                        list_circle = char(list_circle,label);
                    end
                    set(handles.hg.listbox2,'String',list_circle);
                end
            else
                if equalAngle == 1 % lower, equal angle
                    plu = pi/2-2*atan(sqrt(x^2+y^2)); % plunge of pole
                    if plu == pi/2 % pole at the center
                        tre = -pi;
                    else
                        if x == 0 % pole on the NS line
                            if y > 0
                                tre = 0;
                            else
                                tre = pi;
                            end
                        elseif y == 0 % pole on the WE line
                            if x > 0
                                tre = pi/2;
                            else
                                tre = 3*pi/2;
                            end
                        else % general cases
                            if x > 0
                                tre = pi/2-atan(y/x);
                            else
                                tre = -pi/2-atan(y/x);
                            end
                        end
                    end
                    di = pi/2-plu;
                    did = tre-pi;
                    if did<0
                        did = did+2*pi;
                    end
                    hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                    label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                    hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14); 

                    if isempty(list_circle) == 1
                        list_circle = label;
                    else
                        list_circle = char(list_circle,label);
                    end
                    set(handles.hg.listbox2,'String',list_circle);
                else % lower, equal area
                    plu = -pi/2+2*acos(sqrt((x^2+y^2)/2)); % plunge of pole
                    if plu == pi/2 % pole at the center
                        tre = -pi;
                    else
                        if x == 0 % pole on the NS line
                            if y > 0
                                tre = 0;
                            else
                                tre = pi;
                            end
                        elseif y == 0 % pole on the WE line
                            if x > 0
                                tre = pi/2;
                            else
                                tre = 3*pi/2;
                            end
                        else % general cases
                            if x > 0
                                tre = pi/2-atan(y/x);
                            else
                                tre = -pi/2-atan(y/x);
                            end
                        end
                    end
                    di = pi/2-plu;
                    did = tre-pi;
                    if did<0
                        did = did+2*pi;
                    end
                    hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                    label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                    hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14);

                    if isempty(list_circle) == 1
                        list_circle = label;
                    else
                        list_circle = char(list_circle,label);
                    end
                    if get(handles.hg.radiobutton1,'Value') == 1
                        set(handles.hg.listbox2,'String',list_circle);
                    end
                end
            end
        elseif button == 8
            if size(hCircle, 2) > 4
                for i = 0:2
                    delete(hCircle{size(hCircle,2)-i});
                end
                for i = 1:size(hCircle,2)-3
                    tmphCircle{i} = hCircle{i};
                end
                hCircle = tmphCircle;
                clearvars tmphCircle;
                if get(handles.hg.listbox2,'Value') == size(list_circle,1)
                    set(handles.hg.listbox2,'Value',size(list_circle,1)-1);
                end
                list_circle(size(list_circle,1),:) = [];
                set(handles.hg.listbox2,'String',list_circle);
            elseif size(hCircle, 2) == 3
                for i = 1:3
                    delete(hCircle{i}); 
                end
                hCircle = [];
                hCircle{1} = [];
                list_circle = [];
                set(handles.hg.listbox2,'String',list_circle);
            end
        elseif button == 27
            if isempty(hCircle{1}) == 1
                set(handles.showCircle,'Value',0);
                set(handles.add,'enable','off');
            end
            break;
        end
    end
else
    set(handles.add,'enable','off');
    set(handles.text11,'enable','off');
    set(handles.text12,'enable','off');
    set(handles.hg.radiobutton1,'enable','off');
    list_circle = [];
    if get(handles.hg.radiobutton1,'Value') == 1
        if strcmp(get(handles.hg.radiobutton2,'enable'),'on') == 1
            set(handles.hg.radiobutton2,'Value',1);
            set(handles.hg.listbox2,'String',list_desig,'Value',1);
        elseif strcmp(get(handles.hg.radiobutton3,'enable'),'on') == 1
            set(handles.hg.radiobutton3,'Value',1);
            set(handles.hg.listbox2,'String',list_FCM,'Value',1);
        else
            set(handles.hg.listbox2,'String',list_circle);
        end
    end
    for i = 1:size(hCircle, 2)
        delete(hCircle{i})
    end
    clearvars -global hCircle
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

global hCircle list_circle
upper = get(handles.upperHemi, 'Value');
equalAngle = get(handles.equalAngle, 'Value');

while true
    [x, y, button] = ginput(1);
    if button == 1
        if size(hCircle, 2) == 1
            hCircle{1} = scatter(x,y,30,'s', 'linewidth', 1.3, 'markeredgecolor', 'r', 'markerFaceColor', 'r');
        else
            hCircle{size(hCircle, 2)+1} = scatter(x,y,30,'s', 'linewidth', 1.3, 'markeredgecolor', 'r', 'markerFaceColor', 'r');
        end

        if upper == 1
            if equalAngle == 1 % upper, equal angle
                plu = pi/2-2*atan(sqrt(x^2+y^2)); % plunge of pole
                if plu == pi/2 % pole at the center
                    tre = -pi;
                else
                    if x == 0 % pole on the NS line
                        if y > 0
                            tre = 0;
                        else
                            tre = pi;
                        end
                    elseif y == 0 % pole on the WE line
                        if x > 0
                            tre = pi/2;
                        else
                            tre = 3*pi/2;
                        end
                    else % general cases
                        if x > 0
                            tre = pi/2-atan(y/x);
                        else
                            tre = -pi/2-atan(y/x);
                        end
                    end
                end
                di = pi/2-plu;
                did = tre-pi;
                if did<0
                    did = did+2*pi;
                end
                hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14); 

                if isempty(list_circle) == 1
                    list_circle = label;
                else
                    list_circle = char(list_circle,label);
                end
                set(handles.hg.listbox2,'String',list_circle);
            else % upper, equal area
                plu = -pi/2+2*acos(sqrt((x^2+y^2)/2)); % plunge of pole
                if plu == pi/2 % pole at the center
                    tre = -pi;
                else
                    if x == 0 % pole on the NS line
                        if y > 0
                            tre = 0;
                        else
                            tre = pi;
                        end
                    elseif y == 0 % pole on the WE line
                        if x > 0
                            tre = pi/2;
                        else
                            tre = 3*pi/2;
                        end
                    else % general cases
                        if x > 0
                            tre = pi/2-atan(y/x);
                        else
                            tre = -pi/2-atan(y/x);
                        end
                    end
                end
                di = pi/2-plu;
                did = tre-pi;
                if did<0
                    did = did+2*pi;
                end
                hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14);

                if isempty(list_circle) == 1
                    list_circle = label;
                else
                    list_circle = char(list_circle,label);
                end
                set(handles.hg.listbox2,'String',list_circle);
            end
        else
            if equalAngle == 1 % lower, equal angle
                plu = pi/2-2*atan(sqrt(x^2+y^2)); % plunge of pole
                if plu == pi/2 % pole at the center
                    tre = -pi;
                else
                    if x == 0 % pole on the NS line
                        if y > 0
                            tre = 0;
                        else
                            tre = pi;
                        end
                    elseif y == 0 % pole on the WE line
                        if x > 0
                            tre = pi/2;
                        else
                            tre = 3*pi/2;
                        end
                    else % general cases
                        if x > 0
                            tre = pi/2-atan(y/x);
                        else
                            tre = -pi/2-atan(y/x);
                        end
                    end
                end
                di = pi/2-plu;
                did = tre-pi;
                if did<0
                    did = did+2*pi;
                end
                hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14); 

                if isempty(list_circle) == 1
                    list_circle = label;
                else
                    list_circle = char(list_circle,label);
                end
                set(handles.hg.listbox2,'String',list_circle);
            else % lower, equal area
                plu = -pi/2+2*acos(sqrt((x^2+y^2)/2)); % plunge of pole
                if plu == pi/2 % pole at the center
                    tre = -pi;
                else
                    if x == 0 % pole on the NS line
                        if y > 0
                            tre = 0;
                        else
                            tre = pi;
                        end
                    elseif y == 0 % pole on the WE line
                        if x > 0
                            tre = pi/2;
                        else
                            tre = 3*pi/2;
                        end
                    else % general cases
                        if x > 0
                            tre = pi/2-atan(y/x);
                        else
                            tre = -pi/2-atan(y/x);
                        end
                    end
                end
                di = pi/2-plu;
                did = tre-pi;
                if did<0
                    did = did+2*pi;
                end
                hCircle{size(hCircle, 2)+1} = wulffCircle(di, did, upper);
                label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
                hCircle{size(hCircle, 2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14);

                if isempty(list_circle) == 1
                    list_circle = label;
                else
                    list_circle = char(list_circle,label);
                end
                if get(handles.hg.radiobutton1,'Value') == 1
                    set(handles.hg.listbox2,'String',list_circle);
                end
            end
        end
    elseif button == 8
        if size(hCircle, 2) > 4
            for i = 0:2
                delete(hCircle{size(hCircle,2)-i});
            end
            for i = 1:size(hCircle,2)-3
                tmphCircle{i} = hCircle{i};
            end
            hCircle = tmphCircle;
            clearvars tmphCircle;
            if get(handles.hg.listbox2,'Value') == size(list_circle,1)
                set(handles.hg.listbox2,'Value',size(list_circle,1)-1);
            end
            list_circle(size(list_circle,1),:) = [];
            set(handles.hg.listbox2,'String',list_circle);
        elseif size(hCircle, 2) == 3
            for i = 1:3
                delete(hCircle{i}); 
            end
            hCircle = [];
            hCircle{1} = [];
            list_circle = [];
            set(handles.hg.listbox2,'String',list_circle);
        end
    elseif button == 27
        if isempty(hCircle) == 1
            set(handles.showCircle,'Value',0);
        end
        break;
    end
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, handles)
% hObject    handle to clearPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global hcolorbar

if get(handles.colorbar,'Value') == 1  
    delete(hcolorbar);
end

set(handles.showNet, 'enable', 'off','Value',0)
set(handles.netSlider, 'enable', 'off')
set(handles.text5, 'enable', 'off')
set(handles.showCircle, 'enable', 'off','Value',0)
set(handles.add, 'enable', 'off')
set(handles.text11, 'enable', 'off')
set(handles.text12, 'enable', 'off')
set(handles.desigSet, 'enable', 'off','Value',0)
set(handles.text13, 'enable', 'off')
set(handles.text14, 'enable', 'off')
set(handles.treFrom, 'enable', 'off','String',[])
set(handles.treTo, 'enable', 'off','String',[])
set(handles.pluFrom, 'enable', 'off','String',[])
set(handles.pluTo, 'enable', 'off','String',[])
set(handles.meanDButton, 'enable', 'off')
set(handles.contour, 'enable', 'off','Value',0)
set(handles.colorbar, 'enable', 'off','Value',0)
set(handles.clustering, 'enable', 'off','Value',0)
set(handles.text25, 'enable', 'off')
set(handles.edit10, 'enable', 'off','String',[])
set(handles.FCM, 'enable', 'off')
set(handles.hg.radiobutton1,'enable','off');
set(handles.hg.radiobutton2,'enable','off');
set(handles.hg.radiobutton3,'enable','off');
set(handles.hg.listbox2,'String',[]);
set(handles.hg.pushbutton1,'enable','off');
set(handles.hg.pushbutton2,'enable','off');
clearvars -global
delete(findall(findall(gcf,'Type','axe'),'Type','text'))
cla;

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in roseButton.
function roseButton_Callback(hObject, eventdata, handles)
% hObject    handle to roseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
jData = get(handles.mainTable, 'Data');

check = 0;
for i=1:size(jData, 1)
    if strcmp(jData{i,1}, '')
        check = 1;
        break
    end
end
if check == 1
    dataSize = i-1;
else
    dataSize = i;
end

did(dataSize) = 0; % allocating the size

for i = 1:dataSize
    did(i) = jData{i, 2};
end
figure();
h = roseDiagram(did);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in desigSet.
function desigSet_Callback(hObject, eventdata, handles)
% hObject    handle to desigSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of desigSet

try
    
global hWindow list_circle list_desig list_FCM

if get(handles.desigSet,'value') == 1
    set(handles.treFrom,'string', '','enable', 'on')
    set(handles.treTo,'string', '','enable', 'on')
    set(handles.pluFrom,'string', '','enable', 'on')
    set(handles.pluTo,'string', '','enable', 'on')
    set(handles.meanDButton,'enable','on');
    set(handles.text13,'enable','on');
    set(handles.text14,'enable','on');
    set(handles.hg.radiobutton2,'enable','on','Value',1);
    set(handles.hg.listbox2,'String',list_desig,'Value',1);
else
    list_desig = [];
    if get(handles.hg.radiobutton2,'Value') == 1
        set(handles.hg.listbox2,'String',list_desig);
    end
    for i = 1:size(hWindow, 2)
        delete(hWindow{i})
    end
    clearvars -global hWindow
    set(handles.treFrom,'string', '','enable', 'off')
    set(handles.treTo,'string', '','enable', 'off')
    set(handles.pluFrom,'string', '','enable', 'off')
    set(handles.pluTo,'string', '','enable', 'off')
    set(handles.meanDButton,'enable','off');
    set(handles.text13,'enable','off');
    set(handles.text14,'enable','off');
    set(handles.hg.radiobutton2,'enable','off');
    if strcmp(get(handles.hg.radiobutton1,'enable'),'on') == 1
        set(handles.hg.radiobutton1,'Value',1);
        set(handles.hg.listbox2,'String',list_circle,'Value',1);
    elseif strcmp(get(handles.hg.radiobutton3,'enable'),'on') == 1
        set(handles.hg.radiobutton3,'Value',1);
        set(handles.hg.listbox2,'String',list_FCM,'Value',1);
    else
        set(handles.hg.listbox2,'String',list_desig);
    end
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function treFrom_Callback(hObject, eventdata, handles)
% hObject    handle to treFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of treFrom as text
%        str2double(get(hObject,'String')) returns contents of treFrom as a double


% --- Executes during object creation, after setting all properties.
function treFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function treTo_Callback(hObject, eventdata, handles)
% hObject    handle to treTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of treTo as text
%        str2double(get(hObject,'String')) returns contents of treTo as a double


% --- Executes during object creation, after setting all properties.
function treTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to treTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pluFrom_Callback(hObject, eventdata, handles)
% hObject    handle to pluFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pluFrom as text
%        str2double(get(hObject,'String')) returns contents of pluFrom as a double


% --- Executes during object creation, after setting all properties.
function pluFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pluFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pluTo_Callback(hObject, eventdata, handles)
% hObject    handle to pluTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pluTo as text
%        str2double(get(hObject,'String')) returns contents of pluTo as a double


% --- Executes during object creation, after setting all properties.
function pluTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pluTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in meanDButton.
function meanDButton_Callback(hObject, eventdata, handles)
% hObject    handle to meanDButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
jData = get(handles.mainTable, 'Data');
treFrom = str2num(get(handles.treFrom, 'String'))*pi/180;
treTo = str2num(get(handles.treTo, 'String'))*pi/180;
pluFrom = str2num(get(handles.pluFrom, 'string'))*pi/180;
pluTo = str2num(get(handles.pluTo, 'string'))*pi/180;
upper = get(handles.upperHemi, 'Value');
equalAngle = get(handles.equalAngle, 'Value');

global hWindow list_desig 

tmp = [];

if treFrom < treTo
    theta = treFrom:1/1000:treTo;
else
    theta = treFrom-2*pi:1/1000:treTo;
end        

if pluFrom < 0
    [x1(1), y1(1)] = convert_TPCoor(treFrom-pi, -pluFrom, upper, equalAngle);
    [x1(2), y1(2)] = convert_TPCoor(treFrom-pi, 0, upper, equalAngle);
    [x2(1), y2(1)] = convert_TPCoor(treTo-pi, -pluFrom, upper, equalAngle);
    [x2(2), y2(2)] = convert_TPCoor(treTo-pi, 0, upper, equalAngle);
    [x3(1), y3(1)] = convert_TPCoor(treFrom, pluTo, upper, equalAngle);
    [x3(2), y3(2)] = convert_TPCoor(treFrom, 0, upper, equalAngle);
    [x4(1), y4(1)] = convert_TPCoor(treTo, pluTo, upper, equalAngle);
    [x4(2), y4(2)] = convert_TPCoor(treTo, 0, upper, equalAngle);
    if size(hWindow,2) == 1
        hWindow{1} = plot(x1, y1, 'r', x2, y2, 'r', x3, y3, 'r', x4, y4, 'r');
    else
        hWindow{size(hWindow,2)+1} = plot(x1, y1, 'r', x2, y2, 'r', x3, y3, 'r', x4, y4, 'r');
    end

    [x1, y1] = convert_TPCoor(theta-pi, -pluFrom*ones(1,size(theta,2)), upper, equalAngle);
    [x2, y2] = convert_TPCoor(theta-pi, 0*ones(1,size(theta,2)), upper, equalAngle);
    [x3, y3] = convert_TPCoor(theta, pluTo*ones(1,size(theta,2)), upper, equalAngle);
    [x4, y4] = convert_TPCoor(theta, 0*ones(1,size(theta,2)), upper, equalAngle);
    hWindow{size(hWindow,2)+1} = plot(x1, y1, 'r', x2, y2, 'r', x3, y3, 'r', x4, y4, 'r');

    if isempty(list_desig) == 1
        list_desig = sprintf('%.0f%c~%.0f%c / %.0f%c~%.0f%c',treFrom*180/pi,char(176),treTo*180/pi,char(176),pluFrom*180/pi,char(176),pluTo*180/pi,char(176));
    else
        tmpc = sprintf('%.0f%c~%.0f%c / %.0f%c~%.0f%c',treFrom*180/pi,char(176),treTo*180/pi,char(176),pluFrom*180/pi,char(176),pluTo*180/pi,char(176));
        list_desig = char(list_desig,tmpc);
    end
    if get(handles.hg.radiobutton2,'Value') == 1
        set(handles.hg.listbox2,'String',list_desig);
    end
    
    for i=1:size(jData,1)
        tre = jData{i,2}*pi/180 + pi; % trend
        if tre >= 2*pi
            tre = tre - 2*pi;
        end
        if tre >= pi
            tre_sym = tre - pi;
        else
            tre_sym = tre + pi;
        end
        plu = pi/2 - jData{i,1}*pi/180; % plunge
        if plu < 0
            plu = plu + 2*pi;
        end
        
        if treFrom < treTo
            if (treFrom <= tre) && (tre <= treTo) && (plu <= pluTo)
                tmp = [tmp;cos(plu)*cos(tre), cos(plu)*sin(tre), sin(plu)];
            elseif (treFrom <= tre_sym) && (tre_sym <= treTo) && (plu <= (-pluFrom))
                tmp = [tmp;-cos(plu)*cos(tre), -cos(plu)*sin(tre), -sin(plu)];
            end
        else
            if ((treFrom <= tre) || (tre <= treTo)) && (plu <= pluTo)
                tmp = [tmp;cos(plu)*cos(tre), cos(plu)*sin(tre), sin(plu)];
            elseif ((treFrom <= tre_sym) || (tre_sym <= treTo)) && (plu <= (-pluFrom))
                tmp = [tmp;-cos(plu)*cos(tre), -cos(plu)*sin(tre), -sin(plu)];
            end
        end
    end
    avg = mean(tmp);
    avg = avg/norm(avg);
    
else
    [x1(1), y1(1)] = convert_TPCoor(treFrom, pluFrom, upper, equalAngle);
    [x1(2), y1(2)] = convert_TPCoor(treFrom, pluTo, upper, equalAngle);
    [x2(1), y2(1)] = convert_TPCoor(treTo, pluFrom, upper, equalAngle);
    [x2(2), y2(2)] = convert_TPCoor(treTo, pluTo, upper, equalAngle);
    if size(hWindow,2) == 1
        hWindow{1} = plot(x1, y1, 'r', x2, y2, 'r');
    else
        hWindow{size(hWindow,2)+1} = plot(x1, y1, 'r', x2, y2, 'r');
    end

    [x1, y1] = convert_TPCoor(theta, pluFrom*ones(1,size(theta,2)), upper, equalAngle);
    [x2, y2] = convert_TPCoor(theta, pluTo*ones(1,size(theta,2)), upper, equalAngle);
    hWindow{size(hWindow,2)+1} = plot(x1, y1, 'r', x2, y2, 'r');

    if isempty(list_desig) == 1
        list_desig = sprintf('%.0f%c~%.0f%c / %.0f%c~%.0f%c',treFrom*180/pi,char(176),treTo*180/pi,char(176),pluFrom*180/pi,char(176),pluTo*180/pi,char(176));
    else
        tmpc = sprintf('%.0f%c~%.0f%c / %.0f%c~%.0f%c',treFrom*180/pi,char(176),treTo*180/pi,char(176),pluFrom*180/pi,char(176),pluTo*180/pi,char(176));
        list_desig = char(list_desig,tmpc);
    end
    if get(handles.hg.radiobutton2,'Value') == 1
        set(handles.hg.listbox2,'String',list_desig);
    end
    
    for i=1:size(jData,1)
        tre = jData{i,2}*pi/180 +pi; % trend
        if tre > 2*pi
            tre = tre - 2*pi;
        end
        plu = pi/2 - jData{i,1}*pi/180; % plunge
        if plu < 0
            plu = plu + 2*pi;
        end
        
        if treFrom < treTo
            if (treFrom <= tre) && (tre <= treTo) && (pluFrom <= plu) && (plu <= pluTo)
                tmp = [tmp;cos(plu)*cos(tre), cos(plu)*sin(tre), sin(plu)];
            end
        else
            if ((treFrom <= tre) || (tre <= treTo)) && (pluFrom <= plu) && (plu <= pluTo)
                tmp = [tmp;cos(plu)*cos(tre), cos(plu)*sin(tre), sin(plu)];
            end
        end
    end
    
    if size(tmp,1) == 1
        avg = tmp;
    else
        avg = mean(tmp);
        avg = avg/norm(avg);
    end
end

if isnan(avg) == 0
    set(handles.text30,'String',[]);
    [tre_avg, plu_avg] = convert_VecTP(avg(1),avg(2),avg(3));

    % for draw wulffCircle
    di = pi/2 - plu_avg; 
    did = tre_avg - pi;
    if did < 0
        did = did + 2*pi;
    end

    [x, y] = convert_TPCoor(tre_avg, plu_avg, upper, equalAngle);
    hWindow{size(hWindow,2)+1} = wulffCircle(di, did, upper);
    hWindow{size(hWindow,2)+1} = scatter(x,y,30,'s', 'linewidth', 1.3, 'markeredgecolor', 'r', 'markerFaceColor', 'r');
    label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
    hWindow{size(hWindow,2)+1} = text(x, y-0.05, label, 'color', 'k', 'fontsize', 14); 
    a = sprintf('¦¦ %.1f, %.1f',di*180/pi, did*180/pi);
    list_desig = char(list_desig,a);
    if get(handles.hg.radiobutton2,'Value') == 1
        set(handles.hg.listbox2,'String',list_desig);
    end
else
    set(handles.text30,'String','No data');
    hWindow{size(hWindow,2)+1} = scatter(0,0,'Visible','off');
    hWindow{size(hWindow,2)+1} = scatter(0,0,'Visible','off');
    hWindow{size(hWindow,2)+1} = scatter(0,0,'Visible','off');
    list_desig = char(list_desig,'¦¦ NaN, NaN');
    if get(handles.hg.radiobutton2,'Value') == 1
        set(handles.hg.listbox2,'String',list_desig);
    end
end

set(handles.treFrom,'String',[]);
set(handles.treTo,'String',[]);
set(handles.pluFrom,'String',[]);
set(handles.pluTo,'String',[]);

% when desgnating a set over the boundary,
% pluFrom should be (-) and pluTo should be (+)
% trend will be the trend of pluTo

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in FCM.
function FCM_Callback(hObject, eventdata, handles)
% hObject    handle to FCM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global points fcmpoints list_FCM

jData = get(handles.mainTable, 'Data');
jDataSize = size(jData,1);
upper = get(handles.upperHemi, 'Value');
equalAngle = get(handles.equalAngle, 'Value');
n = get(handles.edit10,'String');
n = str2num(n);
data = zeros(jDataSize,3);
error = 0;

if isempty(n) == 1
    set(handles.text27,'String','Set NUMBER');
elseif n <= 0
    set(handles.text27,'String','Set NUMBER');
else
    for i=1:jDataSize
        tre = jData{i,2} + 180; % trend
        if tre >= 360
            tre = tre - 360;
        end
        plu = 90 - jData{i,1}; % plunge
        if plu < 0
            plu = plu + 360;
        end
        data(i,:) = [cos(plu/180*pi)*cos(tre/180*pi), cos(plu/180*pi)*sin(tre/180*pi), sin(plu/180*pi)];
    end

    % Fuzzy C-mean Clustering
    [centers, U] = fcm_new(data,n);

    tre_center = zeros(n,1);
    plu_center = zeros(n,1);
    maxU = max(U);

    if isempty(fcmpoints) == 1
        points.Visible = 'off';
    else
        list_FCM = [];
        if get(handles.hg.radiobutton3,'Value') == 1
            set(handles.hg.listbox2,'String',list_FCM);
        end
        for i = 1:size(fcmpoints,2)
            delete(fcmpoints{i});
        end
        fcmpoints = [];
    end

map = [[1 0 0]; [0.1 0.7 0.1]; [0 0 1]; [1 0.4 0.1]; [0 0.5 0.7]; [0.7 0 0.5]];
i_random = randperm(6,n);
    
    for i = 1:n
        index{i} = find(U(i,:) == maxU);
        if isempty(index{i}) == 0 
            tmp{i} = [data(index{i},1),data(index{i},2),data(index{i},3)];
            center{i} = fcm_new(tmp{i},1);
            [tre_center(i), plu_center(i)] = convert_VecTP(center{i}(:,1),center{i}(:,2),center{i}(:,3));
            di = pi/2-plu_center(i);
            did = tre_center(i)-pi;
            if did < 0
                did = did + 2*pi;
            end
            [c1, c2] = convert_TPCoor(tre_center(i), plu_center(i), upper, equalAngle);
            color = map(i_random(i),:);
            fcmpoints{size(fcmpoints,2)+1} = plot(c1,c2,'x','color',color,'Markersize',15,'LineWidth',3);
            label = sprintf('%.1f, %.1f', di*180/pi, did*180/pi);
            fcmpoints{size(fcmpoints,2)+1} = text(c1, c2-0.05, label, 'color', 'k', 'fontsize', 14);
            hold on;

            if isempty(list_FCM) == 1
                list_FCM = label;
            else
                list_FCM = char(list_FCM,label);
            end
            if get(handles.hg.radiobutton3,'Value') == 1
                set(handles.hg.listbox2,'String',list_FCM,'Value',1);
            end
            [tre_tmp, plu_tmp] = convert_VecTP(data(index{i},1),data(index{i},2),data(index{i},3));
            [t1, t2] = convert_TPCoor(tre_tmp, plu_tmp, upper, equalAngle);
            fcmpoints{size(fcmpoints,2)+1} = plot(t1, t2, 'o', 'color', color, 'MarkerSize', 4, 'LineWidth', 1.3);
            hold on;
        else
            error = error + 1;
        end
    end

    if error ~= 0
        set(handles.text27,'String',['There are only ' num2str(n - error) ' sets are found']);
    else
        set(handles.text27,'String',[]);
    end
end
   
catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in contour.
function contour_Callback(hObject, eventdata, handles)
% hObject    handle to contour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global hcontour hcolorbar points result

jData = get(handles.mainTable, 'Data');
upper = get(handles.upperHemi, 'Value');
equalAngle = get(handles.equalAngle, 'Value');
vec = zeros(2*size(jData,1), 3);
theta = acos(99/100);

if get(handles.contour,'Value') == 1
    points.Visible = 'off';
    r1 = 50;
    r2 = 100;
    result = zeros(r2,r1);

    for i=1:size(jData,1)
        tre = jData{i,2} + 180; % trend
        if tre >= 360
            tre = tre - 360;
        end
        plu = 90 - jData{i,1}; % plunge
        if plu < 0
            plu = plu + 360;
        end
        vec(2*i-1,:) = [cos(plu*pi/180)*cos(tre*pi/180) cos(plu*pi/180)*sin(tre*pi/180) sin(plu*pi/180)];
        vec(2*i,:) = [-cos(plu*pi/180)*cos(tre*pi/180) -cos(plu*pi/180)*sin(tre*pi/180) -sin(plu*pi/180)];
    end

    for i=0:(r1-1)
        for j=0:(r2-1)
            tmp = [cos(i*pi/2/(r1-1))*cos(j*2*pi/(r2-1)) cos(i*pi/2/(r1-1))*sin(j*2*pi/(r2-1)) sin(i*pi/2/(r1-1))];
            dis = dist3(vec, tmp);
            num = sum(dis <= 2*sin(theta/2));
            result(j+1,i+1) = num / size(jData,1) * 100;
        end
    end

    x = zeros(r2,r1);
    y = zeros(r2,r1);

    for i=0:(r1-1)
        for j=0:(r2-1)
            tre = j*2*pi/(r2-1);
            plu = i*pi/2/(r1-1);
            [x(j+1, i+1), y(j+1, i+1)] = convert_TPCoor(tre, plu, upper, equalAngle);
        end
    end
    
    % for i=1:(r1*r2)
    %     text(x(i),y(i),num2str(result(i)));
    % end
    [C,hcontour] = contourf(x,y,result);
    hcontour.LineStyle = 'none';
    colormap(jet(10))
    %colormap(parula(10));
%     colormap(hot(10));
    set(handles.colorbar,'enable','on','Value',1);
    hcolorbar = colorbar('YTick', linspace(0, max(max(result)), 11));
    caxis([0 max(max(result))])
    hcolorbar.Label.String = '% of poles per 1% hemisphere area';
    hcolorbar.Label.FontSize = 12;
else
    points.Visible = 'on';
    delete(hcontour);
    if get(handles.colorbar,'Value') == 1
        delete(hcolorbar);
    end
    set(handles.colorbar,'enable','off','Value',0);
end
% Hint: get(hObject,'Value') returns toggle state of contour

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in colorbar.
function colorbar_Callback(hObject, eventdata, handles)
% hObject    handle to colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global hcolorbar result

if get(handles.colorbar,'Value') == 1  
    hcolorbar = colorbar('YTick', linspace(0, max(max(result)), 11));
    caxis([0 max(max(result))])
    hcolorbar.Label.String = '% of poles per 1% hemisphere area';
    hcolorbar.Label.FontSize = 12;
else
    delete(hcolorbar);
end
% Hint: get(hObject,'Value') returns toggle state of colorbar

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over showCircle.
function showCircle_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to showCircle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
close(untitled);
clearvars -global;
% Hint: delete(hObject) closes the figure
delete(hObject);
catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

% --- Executes on button press in clustering.
function clustering_Callback(hObject, eventdata, handles)
% hObject    handle to clustering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
global points fcmpoints list_circle list_desig list_FCM

if get(handles.clustering,'Value') == 1
    set(handles.edit10,'enable','on');
    set(handles.FCM,'enable','on');
    set(handles.text25,'enable','on');
    set(handles.hg.radiobutton3,'enable','on','Value',1);
    set(handles.hg.listbox2,'String',list_FCM,'Value',1);
else
    set(handles.edit10,'enable','off','String',[]);
    set(handles.FCM,'enable','off');
    set(handles.text25,'enable','off');
    set(handles.text27,'String',[]);
    set(handles.hg.radiobutton3,'enable','off');
    points.Visible = 'on';
    list_FCM = [];
    if strcmp(get(handles.hg.radiobutton1,'enable'),'on') == 1
        set(handles.hg.radiobutton1,'Value',1);
        set(handles.hg.listbox2,'String',list_circle,'Value',1);
    elseif strcmp(get(handles.hg.radiobutton2,'enable'),'on') == 1
        set(handles.hg.radiobutton2,'Value',1);
        set(handles.hg.listbox2,'String',list_desig,'Value',1);
    else
        set(handles.hg.listbox2,'String',list_FCM);
    end
    for i = 1:size(fcmpoints,2)
        delete(fcmpoints{i});
    end
    fcmpoints = [];
end
    
% Hint: get(hObject,'Value') returns toggle state of clustering

catch ex
    errmsg = ex.stack.line;
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end


% --- Executes on button press in importDFNbutton.
function importDFNbutton_Callback(hObject, eventdata, handles)
% hObject    handle to importDFNbutton (see GCBO)
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
        jData(i, :) = {temp{4} temp{5}};
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
            jData(i, :) = {temp{4} temp{5}};
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
    msgbox([{'stereoProjection.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end
            
