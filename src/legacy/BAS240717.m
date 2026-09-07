50%생각해 볼 부분
%anisotropy와 isotropy 선택, isotropy는 입력하지 않아도 커쉬 솔루션으로 가능?
%thermalst : 열응력성분 (도시필요)
%Colorbar (caxis) 조절하는 기능

%updated    
%szz 버그 수정

%updated_181116
%결과 그래프 표시 압력단위 MPa 로 고정
%Rbbo, thetabbo 계산 코드 수정
%모어원 도시 코드에서 복소수항 실수화

function main(hObject, eventdata, handles, varargin)
global fig1 rmesh thmesh
try

%main interface
fig1 = figure('position', [811 109 650 648],'Color',[240/255,240/255,240/255],'MenuBar','none','Resize','off');
handles.mnfile1=uimenu(fig1,'label','File');
handles.mnmesh=uimenu(handles.mnfile1,'label','Mesh Setting', 'Callback',{@Callmnmesh, handles});
handles.title=uicontrol('style','text','units','normalized','position',[0.09 0.88 0.82 0.1],'string', 'Borehole Stability Analyzer', 'FontName','Times New Roman', 'FontSize',28);

handles.pan5=uibuttongroup('Title', 'Elastic Parameters', 'units','normalized', 'Position', [0.07 0.352 0.46 0.26]);
handles.butiso=uicontrol('parent',handles.pan5,'style','radiobutton','units','normalized','position',[0.029 0.65 0.26 0.29], 'string', 'Isotropic');
handles.buttrans=uicontrol('parent',handles.pan5,'style','radiobutton','units','normalized','position',[0.265 0.65 0.5 0.29], 'string', 'Transversely Isotropic');
handles.butortho=uicontrol('parent',handles.pan5,'style','radiobutton','units','normalized','position',[0.725 0.65 0.27 0.29], 'string', 'Orthotropic');
handles.apply=uicontrol('parent', handles.pan5, 'style', 'pushbutton' , 'units', 'normalized', 'position', [0.76 0.07 0.18 0.15], 'string', 'Apply');

handles.text51=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.08 0.5 0.07 0.14],'String','v');
handles.text52=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.23 0.5 0.07 0.14],'String','v''');
handles.text53=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.38 0.5 0.07 0.14],'String','E');
handles.text54=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.59 0.5 0.07 0.14],'String','E''');
handles.text55=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.8 0.5 0.07 0.14],'String','G''');
handles.edit51=uicontrol('parent', handles.pan5,'style', 'edit','units','normalized','position',[0.07 0.35 0.1 0.15],'backgroundcolor',[1 1 1], 'String','0.25');
handles.edit52=uicontrol('parent', handles.pan5,'style', 'edit','units','normalized','position',[0.22 0.35 0.1 0.15],'backgroundcolor',[1 1 1], 'String','0.25', 'Enable','off');
handles.edit53=uicontrol('parent', handles.pan5,'style', 'edit','units','normalized','position',[0.37 0.35 0.1 0.15],'backgroundcolor',[1 1 1], 'String','100');
handles.edit54=uicontrol('parent', handles.pan5,'style', 'edit','units','normalized','position',[0.58 0.35 0.1 0.15],'backgroundcolor',[1 1 1], 'String','100', 'Enable','off');
handles.edit55=uicontrol('parent', handles.pan5,'style', 'edit','units','normalized','position',[0.79 0.35 0.1 0.15],'backgroundcolor',[1 1 1], 'String','100', 'Enable', 'off');
%handles.text61=uicontrol('style','text','units','normalized','position',[0.07 0.345 0.1 0.03],'String','(Unit : GPa)');
handles.text56=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.48 0.32 0.08 0.14],'String','GPa');
handles.text57=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.69 0.32 0.08 0.14],'String','GPa');
handles.text58=uicontrol('parent',handles.pan5,'style','text','units','normalized','position',[0.9 0.32 0.08 0.14],'String','GPa');


handles.pmatrix=uicontrol('style', 'popupmenu', 'units','normalized', 'position', [0.07 0.295 0.46 0.04],'string', '3D Elastic Modulus Matrix(Voigt)|3D Compliance Matrix(Voigt)','backgroundcolor',[1 1 1],'Value',2);
handles.elatable=uitable('units','normalized', 'position', [0.07 0.1 0.46 0.185], ...
    'Data', zeros(6), ...
    'ColumnEditable', false, ...
    'ColumnName', [], 'RowName', [], ...
    'ColumnFormat', {'short','Numeric','Numeric','Numeric','Numeric','Numeric'}, ...
    'ColumnWidth', {49 49 49 49 49 49},'Data',[0.02 -0.004 -0.004 0 0 0; -0.004 0.02 -0.004 0 0 0; -0.004 -0.004 0.02 0 0 0; 0 0 0 0.048 0 0; 0 0 0 0 0.048 0; 0 0 0 0 0 0.048]);
handles.text1=uicontrol('style','text', 'units','normalized', 'position', [0.36 0.06 0.18 0.03], 'String', '(Unit : GPa or 1/GPa)');
handles.pan1=uipanel('Title','Boundary Condition', 'Position', [0.545 0.415 0.39 0.37]);

set(handles.butiso,'callback',{@Calliso,handles})
set(handles.buttrans,'callback',{@Calltrans,handles})
set(handles.butortho,'callback',{@Callortho,handles})
set(handles.apply, 'callback', {@Callapply,handles})


handles.text2c=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.5 0.80 0.15 0.08],'String','Sxy ', 'HorizontalAlignment', 'right');
handles.text3c=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.5 0.67 0.15 0.08],'String','Syz ', 'HorizontalAlignment', 'right');
handles.text4c=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.5 0.54 0.15 0.08],'String','Sxz ', 'HorizontalAlignment', 'right');
handles.edit2c=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.67 0.80 0.15 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit3c=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.67 0.67 0.15 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit4c=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.67 0.54 0.15 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.text6c=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.84 0.80 0.126 0.08],'String','MPa ', 'HorizontalAlignment', 'left');
handles.text7c=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.84 0.67 0.126 0.08],'String','MPa', 'HorizontalAlignment', 'left');
handles.text8c=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.84 0.54 0.126 0.08],'String','MPa ', 'HorizontalAlignment', 'left');
handles.text2=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.02 0.80 0.15 0.08],'String','Sx ', 'HorizontalAlignment', 'right');
handles.text3=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.02 0.67 0.15 0.08],'String','Sy ', 'HorizontalAlignment', 'right');
handles.text4=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.02 0.54 0.15 0.08],'String','Sz ', 'HorizontalAlignment', 'right');
handles.text41=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.05 0.35 0.4 0.15],'String','Pore Pressure ', 'HorizontalAlignment', 'right');
handles.RadFlu=uicontrol('parent',handles.pan1,'style','radiobutton','units','normalized','position',[0.08 0.22 0.8 0.15], 'String', 'Fluid Injection');
handles.text5=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.08 0.04 0.38 0.17],'String','Injection Pressure (Bottomhole) ', 'HorizontalAlignment', 'right');
handles.text6=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.35 0.80 0.126 0.08],'String','MPa ', 'HorizontalAlignment', 'left');
handles.text7=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.35 0.67 0.126 0.08],'String','MPa', 'HorizontalAlignment', 'left');
handles.text8=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.35 0.54 0.126 0.08],'String','MPa ', 'HorizontalAlignment', 'left');
handles.text42=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.79 0.09 0.12 0.08],'String','MPa ', 'HorizontalAlignment', 'left');
handles.text9=uicontrol('parent',handles.pan1,'style','text','units','normalized','position',[0.786 0.35 0.11 0.14],'String','MPa ', 'HorizontalAlignment', 'left');
handles.edit2=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.18 0.80 0.15 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit3=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.18 0.67 0.15 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit4=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.18 0.54 0.15 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit41=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.5 0.42 0.25 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit5=uicontrol('parent',handles.pan1,'style','edit','units','normalized','position',[0.5 0.1 0.25 0.08],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','Enable','off','String','0');
set(handles.RadFlu,'callback',{@CallRadFlu,handles})

handles.bgroup1=uibuttongroup('title', 'Select Analysis', 'Position', [0.545 0.79 0.39 0.1]);
handles.RadAna=uicontrol('parent',handles.bgroup1,'style','radiobutton','units','normalized','position',[0.13 0.13 0.5 0.8], 'string', 'Analytic Solution');
handles.RadFEM=uicontrol('parent',handles.bgroup1,'style','radiobutton','units','normalized','position',[0.66 0.13 0.24 0.8], 'string', 'FEM');

handles.pan2=uipanel('Title','Thermal Properties','Position',[0.545 0.2 0.39 0.21]);
handles.RadThe=uicontrol('parent',handles.pan2,'style','radiobutton','units','normalized','position',[0.13 0.7 0.8 0.23], 'String', 'Thermal Effect');
handles.text10=uicontrol('parent',handles.pan2,'style','text','units','normalized','position',[0.13 0.4 0.32 0.27],'String','Temperature Change ', 'HorizontalAlignment', 'right');
handles.text11=uicontrol('parent',handles.pan2,'style','text','units','normalized','position',[0.13 0.03 0.33 0.27],'String','Expansion Coef. ', 'HorizontalAlignment', 'right');
handles.edit6=uicontrol('parent', handles.pan2,'style', 'edit','units','normalized','position',[0.5 0.46 0.25 0.145],'backgroundcolor',[1 1 1],'HorizontalAlignment','right', 'Enable','off','String','0');
handles.edit7=uicontrol('parent', handles.pan2,'style', 'edit','units','normalized','position',[0.5 0.15 0.25 0.145],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','Enable','off','String','0');
handles.text12=uicontrol('parent',handles.pan2,'style','text','units','normalized','position',[0.78 0.38 0.2 0.23],'String','K ', 'HorizontalAlignment', 'left');
set(handles.RadThe,'callback',{@CallRadThe,handles})

handles.pan3=uibuttongroup('Title','Borehole Information', 'Position', [0.07 0.62 0.46 0.27]);
handles.text13=uicontrol('parent',handles.pan3,'style','text','units','normalized','position',[0.23 0.58 0.16 0.1],'String','Radius ', 'HorizontalAlignment', 'right');
handles.text14=uicontrol('parent',handles.pan3,'style','text','units','normalized','position',[0.15 0.38 0.25 0.1],'String','Polar Angle ', 'HorizontalAlignment', 'right');
handles.text15=uicontrol('parent',handles.pan3,'style','text','units','normalized','position',[0.05 0.2 0.35 0.1],'String','Azimuthal Angle ', 'HorizontalAlignment', 'right');
handles.edit8=uicontrol('parent', handles.pan3,'style', 'edit','units','normalized','position',[0.43 0.57 0.21 0.12],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0.1');
handles.edit9=uicontrol('parent', handles.pan3,'style', 'edit','units','normalized','position',[0.43 0.38 0.21 0.12],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.edit10=uicontrol('parent', handles.pan3,'style', 'edit','units','normalized','position',[0.43 0.18 0.21 0.12],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','String','0');
handles.text16=uicontrol('parent',handles.pan3,'style','text','units','normalized','position',[0.69 0.57 0.04 0.11],'String','m', 'HorizontalAlignment', 'left');
handles.text17=uicontrol('parent',handles.pan3,'style','text','units','normalized','position',[0.69 0.37 0.2 0.11],'String','degree', 'HorizontalAlignment', 'left');
handles.text18=uicontrol('parent',handles.pan3,'style','text','units','normalized','position',[0.69 0.17 0.2 0.12],'String','degree', 'HorizontalAlignment', 'left');

handles.one=uicontrol('parent', handles.pan3, 'style', 'radiobutton', 'units', 'normalized', 'position', [0.13 0.8 0.38 0.13], 'String','Single Orientation');
handles.all=uicontrol('parent', handles.pan3, 'style', 'radiobutton', 'units', 'normalized', 'position', [0.55 0.8 0.38 0.13], 'String','All Orientation');
set(handles.one, 'callback',{@Callone,handles})
set(handles.all,'callback',{@Callall,handles})

handles.Run=uicontrol('style','pushbutton','units','normalized','String','Run','position',[0.545 0.127 0.39 0.06]);
handles.Reset=uicontrol('style','pushbutton','units','normalized','String','Reset','position',[0.545 0.06 0.39 0.06]);

set(handles.Run, 'callback',{@CallRun,handles})
set(handles.Reset,'callback',{@CallReset,handles})

rmesh=60; %FEM 기본설정
thmesh=60;

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end


function CallRadThe(hObject,eventdata,handles) 
% handles=guidata(hObject);
% callback when Thermal Effect option in Thermal Properties is selected
try

onoff=get(hObject,'Value');
if onoff==0

    set(handles.edit6, 'String',0,'Enable','off');
    set(handles.edit7, 'Enable','off');
end
if onoff==1
    set(handles.edit6,'Enable','on');
    set(handles.edit7, 'Enable','on');
end
% guidata(hObject,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=CallRadFlu(hObject,eventdata,handles)
% handles=guidata(hObject);
% callback when Fluid Injection option in Boundary Condition is selected
try
    
onoff=get(hObject,'Value');
if onoff==0
    set(handles.edit5, 'String',0,'Enable','off');
end
if onoff==1
    set(handles.edit5,'Enable','on');
end
% guidata(hObject,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Calliso(hObject,eventdata,handles)
% callback when Isotropic option in Elastic Parameters is selected
try

onoff=get(hObject,'Value');

if onoff==1
    set(handles.buttrans, 'value', 0);
    set(handles.butortho, 'value', 0);
    set(handles.edit51, 'Enable','on');
    set(handles.edit52, 'String',0.25,'Enable','off');
    set(handles.edit53, 'Enable','on');
    set(handles.edit54, 'String',100,'Enable','off');
    set(handles.edit55, 'String',100,'Enable','off');
    set(handles.elatable, 'ColumnEditable', false);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Calltrans(hObject,eventdata,handles)
% callback when Transversely isotropic option in Elastic Parameters is selected

try

onoff=get(hObject,'Value');

if onoff==1
    set(handles.butiso, 'value', 0);
    set(handles.butortho, 'value', 0);
    set(handles.edit51,'Enable','on');
    set(handles.edit52,'Enable','on');
    set(handles.edit53,'Enable','on');
    set(handles.edit54,'Enable','on');
    set(handles.edit55,'Enable','on');
    set(handles.elatable, 'ColumnEditable', false);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Callortho(hObject,eventdata,handles)
% callback when Orthotropic option in Elastic Parameters is selected

try

onoff=get(hObject,'Value');

if onoff==1
    set(handles.butiso, 'value', 0);
    set(handles.buttrans, 'value', 0);
    set(handles.edit51, 'String',0.25,'Enable','off');
    set(handles.edit52, 'String',0.25,'Enable','off');
    set(handles.edit53, 'String',100,'Enable','off');
    set(handles.edit54, 'String',100,'Enable','off');
    set(handles.edit55, 'String',100,'Enable','off');
    set(handles.elatable, 'ColumnEditable', true);
end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Callapply(hObject,eventdata,handles)
% callback when Apply button is clicked
try

onoff=get(hObject,'Value');

if onoff==1
    iso=get(handles.butiso, 'value');
    if iso==1
        v=str2double(get(handles.edit51,'String'));
        E=str2double(get(handles.edit53,'String'));
        set(handles.elatable, 'Data', [1/E -v/E -v/E 0 0 0; -v/E 1/E -v/E 0 0 0; -v/E -v/E 1/E 0 0 0; 0 0 0 2*(1+v)/E 0 0; 0 0 0 0 2*(1+v)/E 0; 0 0 0 0 0 2*(1+v)/E]);
    end
    
    trans=get(handles.buttrans, 'value');
    if trans==1
        v=str2double(get(handles.edit51,'String'));
        v_=str2double(get(handles.edit52,'String'));
        E=str2double(get(handles.edit53,'String'));
        E_=str2double(get(handles.edit54,'String'));
        G=str2double(get(handles.edit55,'String'));
        set(handles.elatable, 'Data',[1/E -v/E -v_/E_ 0 0 0; -v/E 1/E -v_/E_ 0 0 0; -v_/E_ -v_/E_ 1/E_ 0 0 0; 0 0 0 1/G 0 0; 0 0 0 0 1/G 0; 0 0 0 0 0 2*(1+v)/E]);    
    end

end

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Callone(hObject,eventdata,handles)
% handles=guidata(hObject);
% callback when Single Orientation option in Borehole informatino is selected

try
    
onoff=get(hObject,'Value');
if onoff==0
    set(handles.edit8, 'String',0,'Enable','off');
    set(handles.edit9, 'String',0,'Enable','off');
    set(handles.edit10, 'String',0,'Enable','off');
    
end
if onoff==1
    set(handles.edit8,'Enable','on');
    set(handles.edit9,'Enable','on');
    set(handles.edit10,'Enable','on');
    set(handles.buttrans, 'Enable','on');
    set(handles.butortho, 'Enable','on');
    set(handles.RadFEM, 'Enable', 'on');
end
% guidata(hObject,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Callall(hObject,eventdata,handles)
%handles=guidata(hObject);
% callback when All Orientation option in Borehole informatino is selected

try
    
onoff=get(hObject,'Value');

if onoff==0
    set(handles.edit8,'Enable','on');
    set(handles.edit9,'Enable','on');
    set(handles.edit10,'Enable','on');
end

if onoff==1
    set(handles.edit8, 'String',0.1,'Enable','off');
    set(handles.edit9, 'String',0,'Enable','off');
    set(handles.edit10, 'String',0,'Enable','off');
    set(handles.buttrans, 'Enable','off');
    set(handles.butortho, 'Enable','off');
    set(handles.RadFEM, 'Enable',' off');

end
% guidata(hObject,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=CallReset(hObject,eventdata,handles)
end

function handles=Callmnmesh(hObject,eventdata,handles)

try
    
figmesh=figure('position', [600 400 200 100],'Color',[240/255,240/255,240/255],'MenuBar','none','Resize','off');
handles=guihandles(figmesh);
handles.text1m=uicontrol('style','text','position',[10 70 80 20],'String','R Mesh ', 'HorizontalAlignment','right');
handles.edit1m=uicontrol('style','edit','position',[110 70 60 20],'String','60','backgroundcolor',[1 1 1],'HorizontalAlignment','right');
handles.text2m=uicontrol('style','text','position',[10 40 80 20],'String','Theta Mesh ', 'HorizontalAlignment','right');
handles.edit2m=uicontrol('style','edit','position',[110 40 60 20],'String','60','backgroundcolor',[1 1 1],'HorizontalAlignment','right');
handles.meshapply=uicontrol('style','pushbutton','position',[70 10 60 20],'String','Apply');
set(handles.meshapply,'Callback',{@Callmeshapply,handles})
guidata(figmesh,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end
    
function handles=Callmeshapply(hObject,eventdata,handles)
global rmesh thmesh 
try
    

rmesh=str2double(get(handles.edit1m,'String'));
thmesh=str2double(get(handles.edit2m,'String'));
close

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end
    
function handles=CallRun(hObject,eventdata,handles)
global rmesh thmesh thetaop rop Sp1op Sp2op Sp3op Srop Stop
% callback when Run button is clicked

try

one=get(handles.one, 'value');
if one==0
handles_fig1 = handles;
end
if one==1


    tic

    % Analytic Calculation
    % Calculating Compliance matrix
    iso=get(handles.butiso, 'value');
    if iso==1
        v=str2double(get(handles.edit51,'String'));
        E=str2double(get(handles.edit53,'String'));
        Gmat=[1/E -v/E -v/E 0 0 0; -v/E 1/E -v/E 0 0 0; -v/E -v/E 1/E 0 0 0; 0 0 0 2*(1+v)/E 0 0; 0 0 0 0 2*(1+v)/E 0; 0 0 0 0 0 2*(1+v)/E];
    end
    
    trans=get(handles.buttrans, 'value');
    if trans==1
        v=str2double(get(handles.edit51,'String'));
        v_=str2double(get(handles.edit52,'String'));
        E=str2double(get(handles.edit53,'String'));
        E_=str2double(get(handles.edit54,'String'));
        G=str2double(get(handles.edit55,'String'));
        Gmat=[1/E -v/E -v_/E_ 0 0 0; -v/E 1/E -v_/E_ 0 0 0; -v_/E_ -v_/E_ 1/E_ 0 0 0; 0 0 0 1/G 0 0; 0 0 0 0 1/G 0; 0 0 0 0 0 2*(1+v)/E];    
    end
    
    ortho=get(handles.butortho, 'value');
    if ortho==1
        Gmat=get(handles.elatable,'Data');
    end
    
    matrixselect=get(handles.pmatrix, 'value');
    if matrixselect==1
        amatte=inv(Gmat)*10^6;
    end
    if matrixselect==2
        amatte=Gmat/10^6;
    end

    Gpp=str2double(get(handles.edit41, 'String'));
    Gsxi=(str2double(get(handles.edit2, 'String'))-Gpp)*10^6;
    Gsyi=(str2double(get(handles.edit3, 'String'))-Gpp)*10^6;
    Gszi=(str2double(get(handles.edit4, 'String'))-Gpp)*10^6;
    Gsxyi=str2double(get(handles.edit2c, 'String'))*10^6;
    Gsyzi=str2double(get(handles.edit3c, 'String'))*10^6;
    Gsxzi=str2double(get(handles.edit4c, 'String'))*10^6;


    Gfp=0;
    if get(handles.RadFlu,'value')==1
        Gpmud=str2double(get(handles.edit5, 'String'));
        Gfp=(Gpmud-Gpp)*10^6;
    end
    Gtc=0;
    Gec=0;
    if get(handles.RadThe,'value')==1
        Gtc=str2double(get(handles.edit6, 'String'));
        Gec=str2double(get(handles.edit7, 'String'));
    end
    theffect=Gtc*Gec*(1/amatte(1,1))/(1-amatte(2,1)/amatte(1,1));
    Gr=str2double(get(handles.edit8,'String'));
    Gpol=str2double(get(handles.edit9,'String'))*2*pi/360;
    Gazi=str2double(get(handles.edit10,'String'))*2*pi/360;



    % Matrix Transform by Ong(1994)
    L1=cos(Gpol)*cos(Gazi);  
    L2=-sin(Gazi);
    L3=sin(Gpol)*cos(Gazi);
    M1=cos(Gpol)*sin(Gazi);
    M2=cos(Gazi);
    M3=sin(Gazi)*sin(Gpol);
    N1=-sin(Gpol);
    N2=0;
    N3=cos(Gpol);

    Tsig=[L1^2 M1^2 N1^2 2*M1*N1 2*N1*L1 2*L1*M1; 
        L2^2 M2^2 N2^2 2*M2*N2 2*N2*L2 2*L2*M2; 
        L3^2 M3^2 N3^2 2*M3*N3 2*N3*L3 2*L3*M3; 
        L2*L3 M2*M3 N2*N3 M2*N3+M3*N2 N2*L3+N3*L2 L2*M3+L3*M2; 
        L3*L1 M3*M1 N3*N1 M1*N3+M3*N1 N1*L3+N3*L1 L1*M3+L3*M1; 
        L1*L2 M1*M2 N1*N2 M1*N2+M2*N1 N1*L2+N2*L1 L1*M2+L2*M1];

            
    devst=Tsig*[Gsxi;Gsyi;Gszi;Gsxzi;Gsyzi;Gsxyi];  %시추공 좌표계로 변환된 응력값
    Gsx=devst(1);
    Gsy=devst(2);
    Gsz=devst(3);
    Gtyz=devst(4);
    Gtxz=devst(5);
    Gtxy=devst(6);

    amat=transpose(Tsig)*amatte*Tsig;
    if get(handles.RadAna, 'value')==1

    bmat=zeros([6,6]); %reduced strain coefficient by Lekhnitskii
    for i=1:6
        for j=1:6
            bmat(i,j)=amat(i,j)-(amat(i,3)*amat(j,3))/amat(3,3);
        end
    end
    % syms symmu
    % eqn = (bmat(1,1)*symmu^4-2*bmat(1,6)*symmu^3+(2*bmat(1,2)+bmat(6,6))*symmu^2 -2*bmat(2,6)*symmu+bmat(2,2))*(bmat(5,5)*symmu^2-2*bmat(4,5)*symmu+bmat(4,4))-(bmat(1,5)*symmu^3-(bmat(1,4)+bmat(5,6))*symmu^2+(bmat(2,5)+bmat(4,6))*symmu-bmat(2,4))^2 ==0;
    % solmu=solve(eqn, symmu);

    %Ong(1994), equation 3.3.4-3.3.5
    p = [ bmat(1,1)*bmat(5,5)-bmat(1,5)^2 ...
        2*bmat(1,5)*(bmat(1,4)+bmat(5,6))-2*bmat(1,1)*bmat(4,5)-2*bmat(1,6)*bmat(5,5) ...
        bmat(1,1)*bmat(4,4)+4*bmat(1,6)*bmat(4,5)+bmat(5,5)*(2*bmat(1,2)+bmat(6,6))-2*bmat(1,5)*(bmat(2,5)+bmat(4,6))-(bmat(1,4)+bmat(5,6))^2 ...
        2*bmat(1,5)*bmat(2,4)+2*(bmat(1,4)+bmat(5,6))*(bmat(2,5)+bmat(4,6))-2*bmat(1,6)*bmat(4,4)-2*bmat(4,5)*(2*bmat(1,2)+bmat(6,6))-2*bmat(2,6)*bmat(5,5) ...
        bmat(4,4)*(2*bmat(1,2)+bmat(6,6))+4*bmat(2,6)*bmat(4,5)+bmat(2,2)*bmat(5,5)-2*bmat(2,4)*(bmat(1,4)+bmat(5,6))-(bmat(2,5)+bmat(4,6))^2 ...
        2*bmat(2,4)*(bmat(2,5)+bmat(4,6))-2*bmat(2,6)*bmat(4,4)-2*bmat(2,2)*bmat(4,5) ...
        bmat(2,2)*bmat(4,4)-bmat(2,4)^2 ];
    solmu = roots(p);    

    doublesolmu=double(solmu);
    solj=1;
    tempmu=zeros([1,6]);
    for solk=1:6
        if imag(doublesolmu(solk))>0
            tempmu(solj)=doublesolmu(solk);
            solj=solj+1;
        end
    end

    mu(1)=1.0001*tempmu(1);
    mu(2)=1.0002*tempmu(2);
    mu(3)=1.0003*tempmu(3);
    sort(mu, 'descend');


    lbd(1)=-(bmat(1,5)*mu(1)^3-(bmat(1,4)+bmat(5,6))*mu(1)^2+(bmat(2,5)+bmat(4,6))*mu(1)-bmat(2,4))/(bmat(5,5)*mu(1)^2-2*bmat(4,5)*mu(1)+bmat(4,4));
    lbd(2)=-(bmat(1,5)*mu(2)^3-(bmat(1,4)+bmat(5,6))*mu(2)^2+(bmat(2,5)+bmat(4,6))*mu(2)-bmat(2,4))/(bmat(5,5)*mu(2)^2-2*bmat(4,5)*mu(2)+bmat(4,4));
    lbd(3)=-(bmat(1,5)*mu(3)^3-(bmat(1,4)+bmat(5,6))*mu(3)^2+(bmat(2,5)+bmat(4,6))*mu(3)-bmat(2,4))/(bmat(1,1)*mu(3)^4-2*bmat(1,6)*mu(3)^3+(2*bmat(1,2)+bmat(6,6))*mu(3)^2 -2*bmat(2,6)*mu(3)+bmat(2,2));



%   r=Gr:0.001:10*Gr;
    r=(1:0.05:10)*Gr;
    r=r';
    theta=0: 1/360 *pi/2 : 2*pi;
    theta=theta';
    R=Gr;
    Del=mu(2)-mu(1)+lbd(3)*lbd(2)*(mu(1)-mu(3)) +lbd(1)*lbd(3)*(mu(3)-mu(2));
    p1=bmat(1,1)*mu(1)^2 +bmat(1,2)-bmat(1,6)*mu(1)+lbd(1)*(bmat(1,5)*mu(1)-bmat(1,4));
    p2=bmat(1,1)*mu(2)^2+bmat(1,2)-bmat(1,6)*mu(2)+lbd(2)*(bmat(1,5)*mu(2)-bmat(1,4));
    p3=lbd(3)*(bmat(1,1)*mu(3)^2+bmat(1,2)-bmat(1,6)*mu(3))+bmat(1,5)*mu(3)-bmat(1,4);
    q1=bmat(1,2)*mu(1)+bmat(2,2)/mu(1)-bmat(2,6)+lbd(1)*(bmat(2,5)-bmat(2,4)/mu(1));
    q2=bmat(1,2)*mu(2)+bmat(2,2)/mu(2)-bmat(2,6)+lbd(2)*(bmat(2,5)-bmat(2,4)/mu(2));
    q3=lbd(3)*(bmat(1,2)*mu(3)+bmat(2,2)/mu(3) -bmat(2,6))+bmat(2,5)-bmat(2,4)/mu(3);

    z1=zeros([length(r),length(theta)]);
    z2=zeros([length(r),length(theta)]);
    z3=zeros([length(r),length(theta)]);
    deter1=zeros([length(r),length(theta)]);
    deter2=zeros([length(r),length(theta)]);
    deter3=zeros([length(r),length(theta)]);
    detert1=zeros([length(r),length(theta)]);
    detert2=zeros([length(r),length(theta)]);
    detert3=zeros([length(r),length(theta)]);
    zeta1=zeros([length(r),length(theta)]);
    zeta2=zeros([length(r),length(theta)]);
    zeta3=zeros([length(r),length(theta)]);
    Phi1=zeros([length(r),length(theta)]);
    Phi2=zeros([length(r),length(theta)]);
    Phi3=zeros([length(r),length(theta)]);
    Txy=zeros([length(r),length(theta)]);
    Txz=zeros([length(r),length(theta)]);
    Tyz=zeros([length(r),length(theta)]);
    Sxx=zeros([length(r),length(theta)]);
    Syy=zeros([length(r),length(theta)]);
    Szz=zeros([length(r),length(theta)]);
    pphi1=zeros([length(r),length(theta)]);
    pphi2=zeros([length(r),length(theta)]);
    pphi3=zeros([length(r),length(theta)]);
    dispxx=zeros([length(r),length(theta)]);
    dispyy=zeros([length(r),length(theta)]);
    epxx=zeros([length(r),length(theta)]);
    epyy=zeros([length(r),length(theta)]);
    Sr=zeros([length(r),length(theta)]);
    St=zeros([length(r),length(theta)]);
    Sz=zeros([length(r),length(theta)]);
    Trt=zeros([length(r),length(theta)]);
    Trz=zeros([length(r),length(theta)]);
    Ttz=zeros([length(r),length(theta)]);
    Sp1=zeros([length(r),length(theta)]);
    Sp2=zeros([length(r),length(theta)]);
    Sp3=zeros([length(r),length(theta)]);
    thermalst = zeros([length(r),length(theta)]);

    %Following Ong(1994), 3.4
    for countr=1:length(r)
        stsign1=1;
        stsign2=1;
        stsign3=1;
        detsign1=1;
        detsign2=1;
        detsign3=1;
        for countth=1:length(theta)
            z1(countr,countth)=r(countr)*(cos(theta(countth)) + mu(1)*sin(theta(countth)));
            z2(countr,countth)=r(countr)*(cos(theta(countth)) + mu(2)*sin(theta(countth)));
            z3(countr,countth)=r(countr)*(cos(theta(countth)) + mu(3)*sin(theta(countth)));
            deter1(countr,countth)=(z1(countr,countth)/R)^2 -1 -mu(1)^2; 
            deter2(countr,countth)=(z2(countr,countth)/R)^2 -1 -mu(2)^2;
            deter3(countr,countth)=(z3(countr,countth)/R)^2 -1 -mu(3)^2;
            if stsign1==1
                if imag(deter1(countr,countth))>0
                    stsign1=-1;
                end
            end
            if stsign1==-1
                if imag(deter1(countr,countth))<0
                    stsign1=+1;
                    detsign1=-detsign1;
                end
            end
            if stsign2==1
                if imag(deter2(countr,countth))>0
                    stsign2=-1;
                end
            end
            if stsign2==-1
                if imag(deter2(countr,countth))<0
                    stsign2=+1;
                    detsign2=-detsign2;
                end
            end
            if stsign3==1
                if imag(deter3(countr,countth))>0
                    stsign3=-1;
                end
            end
            if stsign3==-1
                if imag(deter3(countr,countth))<0
                    stsign3=+1;
                    detsign3=-detsign3;
                end
            end
            detert1(countr,countth)=detsign1*sqrt((z1(countr,countth)/R)^2 -1 -mu(1)^2);
            detert2(countr,countth)=detsign2*sqrt((z2(countr,countth)/R)^2 -1 -mu(2)^2);
            detert3(countr,countth)=detsign3*sqrt((z3(countr,countth)/R)^2 -1 -mu(3)^2);
            zeta1(countr,countth)=(z1(countr,countth)/R + detert1(countr,countth))/(1-1i*mu(1)); %Ong(1994), eq 3.4.7
            zeta2(countr,countth)=(z2(countr,countth)/R + detert2(countr,countth))/(1-1i*mu(2));
            zeta3(countr,countth)=(z3(countr,countth)/R + detert3(countr,countth))/(1-1i*mu(3));
            Phi1(countr,countth)=-(1/(2*Del*zeta1(countr,countth)*detert1(countr,countth)))    *((1i*Gtxy - Gsy+Gfp)*(mu(2)-lbd(2)*lbd(3)*mu(3))+(Gtxy-1i*Gsx+1i*Gfp)*(lbd(2)*lbd(3)-1)+(Gtyz-1i*Gtxz)*lbd(3)*(mu(3)-mu(2))); %Ong(1994), eq 3.4.11
            Phi2(countr,countth)=-(1/(2*Del*zeta2(countr,countth)*detert2(countr,countth)))    *((1i*Gtxy - Gsy+Gfp)*(lbd(1)*lbd(3)*mu(3)-mu(1))+(Gtxy-1i*Gsx+1i*Gfp)*(1-lbd(1)*lbd(3))+(Gtyz-1i*Gtxz)*lbd(3)*(mu(1)-mu(3)));
            Phi3(countr,countth)=-(1/(2*Del*zeta3(countr,countth)*detert3(countr,countth)))    *((1i*Gtxy - Gsy+Gfp)*(mu(1)*lbd(2)-mu(2)*lbd(1))+(Gtxy-1i*Gsx+1i*Gfp)*(lbd(1)-lbd(2))+(Gtyz-1i*Gtxz)*(mu(2)-mu(1)));
            Sxx(countr,countth)=Gsx+2*real(mu(1)^2*Phi1(countr,countth)+mu(2)^2*Phi2(countr,countth)+(lbd(3)*mu(3)^2)*Phi3(countr,countth)); %Ong(1994), eq 3.3.20
            Syy(countr,countth)=Gsy+2*real(Phi1(countr,countth)+Phi2(countr,countth)+lbd(3)*Phi3(countr,countth));
            Txy(countr,countth)=Gtxy-2*real(mu(1)*Phi1(countr,countth)+mu(2)*Phi2(countr,countth)+(lbd(3)*mu(3)*Phi3(countr,countth)));
            Txz(countr,countth)=Gtxz+2*real(mu(1)*lbd(1)*Phi1(countr,countth)+mu(2)*lbd(2)*Phi2(countr,countth)+mu(3)*Phi3(countr,countth));
            Tyz(countr,countth)=Gtyz-2*real(lbd(1)*Phi1(countr,countth)+lbd(2)*Phi2(countr,countth)+Phi3(countr,countth));
            Szz(countr,countth)=Gsz-(1/amat(3,3))*(amat(3,1)*(Sxx(countr,countth)-Gsx)+amat(3,2)*(Syy(countr,countth)-Gsy)+amat(3,4)*(Tyz(countr,countth)-Gtyz)+amat(3,5)*(Txz(countr,countth)-Gtxz)+amat(3,6)*(Txy(countr,countth)-Gtxy));
            pphi1(countr,countth)=R/(2*Del*zeta1(countr,countth)) *((1i*Gtxy - Gsy+Gfp)*(mu(2)-lbd(2)*lbd(3)*mu(3))+(Gtxy-1i*Gsx+1i*Gfp)*(lbd(2)*lbd(3)-1)+(Gtyz-1i*Gsz)*lbd(3)*(mu(3)-mu(2)));
            pphi2(countr,countth)=R/(2*Del*zeta2(countr,countth)) *((1i*Gtxy - Gsy+Gfp)*(lbd(1)*lbd(3)*mu(3)-mu(1))+(Gtxy-1i*Gsx+1i*Gfp)*(1-lbd(1)*lbd(3))+(Gtyz-1i*Gsz)*lbd(3)*(mu(1)-mu(3)));
            pphi3(countr,countth)=R/(2*Del*zeta3(countr,countth)) *((1i*Gtxy - Gsy+Gfp)*(mu(1)*lbd(2)-mu(2)*lbd(1))+(Gtxy-1i*Gsx+1i*Gfp)*(lbd(1)-lbd(2))+(Gtyz-1i*Gsz)*(mu(2)-mu(1)));
            dispxx(countr,countth)=2*real(p1*pphi1(countr,countth)+p2*pphi2(countr,countth)+p3*pphi3(countr,countth));
            dispyy(countr,countth)=2*real(q1*pphi1(countr,countth)+q2*pphi2(countr,countth)+q3*pphi3(countr,countth));
        end
    end

    % Thermal expansion
    ep=zeros(1,6);
    eptemp=zeros(6,6);

    for countr=1:length(r)
    for countth=1:length(theta)
        L11=cos(theta(countth));  
        L22=-sin(theta(countth));
        L33=0;
        M11=sin(theta(countth));
        M22=cos(theta(countth));
        M33=0;
        N11=0;
        N22=0;
        N33=1;

        eptrans=[L11^2 M11^2 N11^2 2*M11*N11 2*N11*L11 2*L11*M11; 
            L22^2 M22^2 N22^2 2*M22*N22 2*N22*L22 2*L22*M22; 
            L33^2 M33^2 N33^2 2*M33*N33 2*N33*L33 2*L33*M33; 
            L22*L33 M22*M33 N22*N33 M22*N33+M33*N22 N22*L33+N33*L22 L22*M33+L33*M22; 
            L33*L11 M33*M11 N33*N11 M11*N33+M33*N11 N11*L33+N33*L11 L11*M33+L33*M11; 
            L11*L22 M11*M22 N11*N22 M11*N22+M22*N11 N11*L22+N22*L11 L11*M22+L22*M11];

        epthertemp=transpose(eptrans)*amat*eptrans;
        epther=epthertemp(2:3,2:3);
        stthertemp=mldivide(epther,[Gtc*Gec;Gtc*Gec]);
        thermalst(countr,countth)=stthertemp(1);
        stther=mldivide(eptrans,[0;stthertemp(1);stthertemp(2);0;0;0]);

        Sxx(countr,countth)=Sxx(countr,countth)+stther(1);
        Syy(countr,countth)=Syy(countr,countth)+stther(2);
        Szz(countr,countth)=Szz(countr,countth)+stther(3);
        Tyz(countr,countth)=Tyz(countr,countth)+stther(4);
        Txz(countr,countth)=Txz(countr,countth)+stther(5);
        Txy(countr,countth)=Txy(countr,countth)+stther(6);
    end
    end


    for countr=1:length(r)
    for countth=1:length(theta)
    temp=[cos(theta(countth)) sin(theta(countth)) 0; 
        -sin(theta(countth)) cos(theta(countth)) 0; 
        0 0 1]*[Sxx(countr,countth) Txy(countr,countth) Txz(countr,countth);
        Txy(countr,countth) Syy(countr,countth) Tyz(countr,countth);
        Txz(countr,countth) Tyz(countr,countth) Szz(countr,countth)]*[cos(theta(countth)) -sin(theta(countth)) 0; 
        sin(theta(countth)) cos(theta(countth)) 0; 
        0 0 1];
    Sr(countr,countth)=temp(1,1);
    St(countr,countth)=temp(2,2);
    Sz(countr,countth)=temp(3,3);
    Trt(countr,countth)=temp(1,2);
    Trz(countr,countth)=temp(1,3);
    Ttz(countr,countth)=temp(2,3);
    end
    end

    for i=1:length(Sr(:,1))
    for j=1:length(Sr(1,:))
        Aeig=eig([Sr(i,j) Trt(i,j) Trz(i,j); 
            Trt(i,j) St(i,j) Ttz(i,j); 
            Trz(i,j) Ttz(i,j) Sz(i,j)]);
        Beig = sort(Aeig);
        Sp1(i,j) = Beig(3); %Max
        Sp2(i,j) = Beig(2); %Mid
        Sp3(i,j) = Beig(1); %Min
    end
    end
    [gridtheta, gridr]=meshgrid(theta,r);
    nodetheta=gridtheta;
    noder=gridr;
    end



    %% FEM analysis

    if get(handles.RadFEM,'value')==1


        % Loading Condition


        % Mesh Generation
        rend=8*Gr;
        rghpo=floor(2*rmesh/3);           %rougher point
        rghco=10;                        %rougher coefficient
        nodep=zeros([(rmesh+1)*thmesh,2]);
        nodet=zeros([rmesh*thmesh, 4]);
        for thc=0:(thmesh/4 -1)
            r0x=Gr*cos(thc*2*pi/thmesh +pi/4);
            r0y=Gr*sin(thc*2*pi/thmesh +pi/4);
            rex=rend-thc*rend/(thmesh/8);
            rey=rend; 
            for rc=0:rghpo
            nodep(1+rc+(1+rmesh)*thc,:)=[r0x+(rex-r0x)*rc/rghco/rmesh,r0y+(rey-r0y)*rc/rghco/rmesh];
            end
            rghlox=r0x+(rex-r0x)*rghpo/rghco/rmesh;
            rghloy=r0y+(rey-r0y)*rghpo/rghco/rmesh;
            for rc=rghpo+1:rmesh
            nodep(1+rc+(1+rmesh)*thc,:)=[rghlox+(rex-rghlox)*(rc-rghpo)/(rmesh-rghpo),rghloy+(rey-rghloy)*(rc-rghpo)/(rmesh-rghpo)];
            end
        end
        for thc=(thmesh/4):(thmesh/2 -1)
            r0x=Gr*cos(thc*2*pi/thmesh +pi/4);
            r0y=Gr*sin(thc*2*pi/thmesh +pi/4);
            rex=-rend;
            rey=rend-(thc-thmesh/4)*rend/(thmesh/8);
            for rc=0:rghpo
            nodep(1+rc+(1+rmesh)*thc,:)=[r0x+(rex-r0x)*rc/rghco/rmesh,r0y+(rey-r0y)*rc/rghco/rmesh];
            end
            rghlox=r0x+(rex-r0x)*rghpo/rghco/rmesh;
            rghloy=r0y+(rey-r0y)*rghpo/rghco/rmesh;
            for rc=rghpo+1:rmesh
            nodep(1+rc+(1+rmesh)*thc,:)=[rghlox+(rex-rghlox)*(rc-rghpo)/(rmesh-rghpo),rghloy+(rey-rghloy)*(rc-rghpo)/(rmesh-rghpo)];
            end
        end
        for thc=(thmesh/2):(thmesh*3/4 -1)
            r0x=Gr*cos(thc*2*pi/thmesh +pi/4);
            r0y=Gr*sin(thc*2*pi/thmesh +pi/4);
            rex=-rend+(thc-thmesh/2)*rend/(thmesh/8);
            rey=-rend;
            for rc=0:rghpo
            nodep(1+rc+(1+rmesh)*thc,:)=[r0x+(rex-r0x)*rc/rghco/rmesh,r0y+(rey-r0y)*rc/rghco/rmesh];
            end
            rghlox=r0x+(rex-r0x)*rghpo/rghco/rmesh;
            rghloy=r0y+(rey-r0y)*rghpo/rghco/rmesh;
            for rc=rghpo+1:rmesh
            nodep(1+rc+(1+rmesh)*thc,:)=[rghlox+(rex-rghlox)*(rc-rghpo)/(rmesh-rghpo),rghloy+(rey-rghloy)*(rc-rghpo)/(rmesh-rghpo)];
            end
        end
        for thc=(thmesh*3/4):(thmesh-1)
            r0x=Gr*cos(thc*2*pi/thmesh +pi/4);
            r0y=Gr*sin(thc*2*pi/thmesh +pi/4);
            rex=rend;
            rey=-rend+(thc-thmesh*3/4)*rend/(thmesh/8);
            for rc=0:rghpo
            nodep(1+rc+(1+rmesh)*thc,:)=[r0x+(rex-r0x)*rc/rghco/rmesh,r0y+(rey-r0y)*rc/rghco/rmesh];
            end
            rghlox=r0x+(rex-r0x)*rghpo/rghco/rmesh;
            rghloy=r0y+(rey-r0y)*rghpo/rghco/rmesh;
            for rc=rghpo+1:rmesh
            nodep(1+rc+(1+rmesh)*thc,:)=[rghlox+(rex-rghlox)*(rc-rghpo)/(rmesh-rghpo),rghloy+(rey-rghloy)*(rc-rghpo)/(rmesh-rghpo)];
            end
        end
        for thc=0:thmesh-2
            for rc=1:rmesh
                nodet(rc-1+thc*rmesh+1,:)=[rc+thc*(rmesh+1),rc+thc*(rmesh+1)+1,rc+(thc+1)*(rmesh+1)+1,rc+(thc+1)*(rmesh+1)];
            end
        end
        thc=thmesh-1;
        for rc=1:rmesh
            nodet(rc-1+thc*rmesh+1,:)=[rc+thc*(rmesh+1),rc+thc*(rmesh+1)+1,rc+(0)*(rmesh+1)+1,rc+(0)*(rmesh+1)];
        end       

            % Material properties


        inva=inv(amat);
        invC=[amat(1,1) amat(2,1) amat(6,1); amat(2,1) amat(2,2) amat(2,6); amat(6,1) amat(6,2) amat(6,6)];
        C=inv(invC);
        %% Setting system equation

        % Default K and F matrix
        Ktot=zeros(2*size(nodep,1));
        Ftot=zeros(2*size(nodep,1),1);

        for kcount=1:size(nodet,1)       % repeat for every element
            % Numbering each node
            no1=nodet(kcount,1);
            no2=nodet(kcount,2);
            no3=nodet(kcount,3);
            no4=nodet(kcount,4);

            %coordinate of each node
            x1=nodep(no1,1);
            x2=nodep(no2,1);
            x3=nodep(no3,1);
            x4=nodep(no4,1);
            y1=nodep(no1,2);
            y2=nodep(no2,2);
            y3=nodep(no3,2);
            y4=nodep(no4,2);

    %             gp=[-1/sqrt(3),1/sqrt(3)];      %Gauss point for Gauss-Legandre quadrature rules
            gp=[-sqrt(3/5), 0, sqrt(3/5)];
            gpwt=[25/81, 40/81, 25/81; 40/81, 64/81, 40/81; 25/81, 40/81, 25/81];
            for gpx=1:length(gp)
                for gpy=1:length(gp)
                    gpzeta=gp(gpx);
                    gpeta=gp(gpy);
                    gpjacob=(1/4) * [(x2-x1)*(1-gpeta)+(x3-x4)*(1+gpeta) (y2-y1)*(1-gpeta)+(y3-y4)*(1+gpeta);
                        (x4-x1)*(1-gpzeta)+(x3-x2)*(1+gpzeta) (y4-y1)*(1-gpzeta)+(y3-y2)*(1+gpzeta)];

                    bmat=(1/4/abs(det(gpjacob))) * [-(1-gpeta)*gpjacob(2,2)+(1-gpzeta)*gpjacob(1,2),0,(1-gpeta)*gpjacob(2,2)+(1+gpzeta)*gpjacob(1,2),0,(1+gpeta)*gpjacob(2,2)-(1+gpzeta)*gpjacob(1,2),0,-(1+gpeta)*gpjacob(2,2)-(1-gpzeta)*gpjacob(1,2),0;
                        0,(1-gpeta)*gpjacob(2,1)-(1-gpzeta)*gpjacob(1,1),0,-(1-gpeta)*gpjacob(2,1)-(1+gpzeta)*gpjacob(1,1),0,-(1+gpeta)*gpjacob(2,1)+(1+gpzeta)*gpjacob(1,1),0,(1+gpeta)*gpjacob(2,1)+(1-gpzeta)*gpjacob(1,1);
                        (1-gpeta)*gpjacob(2,1)-(1-gpzeta)*gpjacob(1,1),-(1-gpeta)*gpjacob(2,2)+(1-gpzeta)*gpjacob(1,2),-(1-gpeta)*gpjacob(2,1)-(1+gpzeta)*gpjacob(1,1),(1-gpeta)*gpjacob(2,2)+(1+gpzeta)*gpjacob(1,2),-(1+gpeta)*gpjacob(2,1)+(1+gpzeta)*gpjacob(1,1),(1+gpeta)*gpjacob(2,2)-(1+gpzeta)*gpjacob(1,2),(1+gpeta)*gpjacob(2,1)+(1-gpzeta)*gpjacob(1,1),-(1+gpeta)*gpjacob(2,2)-(1-gpzeta)*gpjacob(1,2)];


                    K=gpwt(gpx,gpy)*bmat'*C*bmat*abs(det(gpjacob));



                    nomat=[no1,no2,no3,no4];
                    for nomatnum2=1:4
                        for nomatnum1=1:4
                            Ktot(nomat(nomatnum1)*2-1,nomat(nomatnum2)*2-1)=Ktot(nomat(nomatnum1)*2-1,nomat(nomatnum2)*2-1)+K(2*nomatnum1-1,2*nomatnum2-1);
                            Ktot(nomat(nomatnum1)*2,nomat(nomatnum2)*2-1)=Ktot(nomat(nomatnum1)*2,nomat(nomatnum2)*2-1)+K(2*nomatnum1,2*nomatnum2-1);
                            Ktot(nomat(nomatnum1)*2-1,nomat(nomatnum2)*2)=Ktot(nomat(nomatnum1)*2-1,nomat(nomatnum2)*2)+K(2*nomatnum1-1,2*nomatnum2);
                            Ktot(nomat(nomatnum1)*2,nomat(nomatnum2)*2)=Ktot(nomat(nomatnum1)*2,nomat(nomatnum2)*2)+K(2*nomatnum1,2*nomatnum2);
                        end
                    end
                end
            end

        end




        %% Boundary Condtion
        kcount=rmesh+1;
        Ftot(2*kcount,1)=Ftot(2*kcount,1)+ rend/(thmesh/4)* (Gsy+Gtxy);  
        Ftot(2*kcount-1,1)=Ftot(2*kcount,1)+ rend/(thmesh/4)* (Gsx+Gtxy);  
        for kcount=2*rmesh+2:rmesh+1:length(nodep)/4
            Ftot(2*kcount,1)=Ftot(2*kcount,1)+ rend*2/(thmesh/4)* Gsy;  
            Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)+ rend*2/(thmesh/4)*Gtxy;
        end
        kcount=length(nodep)/4 +rmesh+1;
        Ftot(2*kcount,1)=Ftot(2*kcount,1)+ rend/(thmesh/4)* (Gsy+Gtxy);  
        Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)- rend/(thmesh/4)* (Gsx+Gtxy);  

        for kcount=length(nodep)/4 +2*rmesh+2:rmesh+1:length(nodep)/2
            Ftot(2*kcount,1)=Ftot(2*kcount,1)- rend*2/(thmesh/4)* Gtxy;
            Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)- rend*2/(thmesh/4)* Gsx;  
        end
        kcount=length(nodep)/2+rmesh+1;
        Ftot(2*kcount,1)=Ftot(2*kcount,1)- rend/(thmesh/4)* (Gsy+Gtxy);  
        Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)- rend/(thmesh/4)* (Gsx+Gtxy);  
        for kcount=length(nodep)/2+2*rmesh+2:rmesh+1:length(nodep)*3/4
            Ftot(2*kcount,1)=Ftot(2*kcount,1)- rend*2/(thmesh/4)* Gsy;     
            Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)- rend*2/(thmesh/4)* Gtxy;    
        end
        kcount=length(nodep)*3/4 +rmesh+1;
        Ftot(2*kcount,1)=Ftot(2*kcount,1)- rend/(thmesh/4)* (Gsy+Gtxy);  
        Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)+ rend/(thmesh/4)* (Gsx+Gtxy);  
        for kcount=length(nodep)*3/4+2*rmesh+2:rmesh+1:length(nodep)
            Ftot(2*kcount,1)=Ftot(2*kcount,1)+ rend*2/(thmesh/4)* Gtxy;
            Ftot(2*kcount-1,1)=Ftot(2*kcount-1,1)+ rend*2/(thmesh/4)* Gsx;     
        end
        %Fluid pressure
        for kcount=1:rmesh+1:length(nodep)

            Ftot(2*kcount-1)=Ftot(2*kcount-1)-Gfp*nodep(kcount,1)*2*pi/thmesh;
            Ftot(2*kcount)=Ftot(2*kcount)-Gfp*nodep(kcount,2)*2*pi/thmesh;
        end

        atot=pinv(Ktot)*Ftot; %


        %% Evaluating Flux

        strainele=zeros([size(nodet,1),3]);
        stressele=zeros([size(nodet,1),3]);
        xele=zeros([size(nodet,1),1]);
        yele=zeros([size(nodet,1),1]);
        srrele=zeros([size(nodet,1),1]);
        sttele=zeros([size(nodet,1),1]);
        srtele=zeros([size(nodet,1),1]);
        sxxele=zeros([size(nodet,1),1]);
        syyele=zeros([size(nodet,1),1]);
        sxyele=zeros([size(nodet,1),1]);
        thermalstele=zeros([size(nodet,1),1]);
        for kcount=1:size(nodet,1)

            no1=nodet(kcount,1);
            no2=nodet(kcount,2); 
            no3=nodet(kcount,3); 
            no4=nodet(kcount,4); 
            x1=nodep(no1,1);
            x2=nodep(no2,1);
            x3=nodep(no3,1); 
            x4=nodep(no4,1);
            y1=nodep(no1,2);
            y2=nodep(no2,2);
            y3=nodep(no3,2);
            y4=nodep(no4,2);
            gpeta=0;
            gpzeta=0;
            gpjacob=1/4 * [(x2-x1)*(1-gpeta)+(x3-x4)*(1+gpeta) (y2-y1)*(1-gpeta)+(y3-y4)*(1+gpeta);
            (x4-x1)*(1-gpzeta)+(x3-x2)*(1+gpzeta) (y4-y1)*(1-gpzeta)+(y3-y2)*(1+gpzeta)];
                    bmat=(1/4/abs(det(gpjacob))) * [-(1-gpeta)*gpjacob(2,2)+(1-gpzeta)*gpjacob(1,2),0,(1-gpeta)*gpjacob(2,2)+(1+gpzeta)*gpjacob(1,2),0,(1+gpeta)*gpjacob(2,2)-(1+gpzeta)*gpjacob(1,2),0,-(1+gpeta)*gpjacob(2,2)-(1-gpzeta)*gpjacob(1,2),0;
                        0,(1-gpeta)*gpjacob(2,1)-(1-gpzeta)*gpjacob(1,1),0,-(1-gpeta)*gpjacob(2,1)-(1+gpzeta)*gpjacob(1,1),0,-(1+gpeta)*gpjacob(2,1)+(1+gpzeta)*gpjacob(1,1),0,(1+gpeta)*gpjacob(2,1)+(1-gpzeta)*gpjacob(1,1);
                        (1-gpeta)*gpjacob(2,1)-(1-gpzeta)*gpjacob(1,1),-(1-gpeta)*gpjacob(2,2)+(1-gpzeta)*gpjacob(1,2),-(1-gpeta)*gpjacob(2,1)-(1+gpzeta)*gpjacob(1,1),(1-gpeta)*gpjacob(2,2)+(1+gpzeta)*gpjacob(1,2),-(1+gpeta)*gpjacob(2,1)+(1+gpzeta)*gpjacob(1,1),(1+gpeta)*gpjacob(2,2)-(1+gpzeta)*gpjacob(1,2),(1+gpeta)*gpjacob(2,1)+(1-gpzeta)*gpjacob(1,1),-(1+gpeta)*gpjacob(2,2)-(1-gpzeta)*gpjacob(1,2)];


            % Calculation of a matrix for this node (displacement)
            aele(1,1)=atot(2*no1-1,1);
            aele(2,1)=atot(2*no1,1);
            aele(3,1)=atot(2*no2-1,1);
            aele(4,1)=atot(2*no2,1);
            aele(5,1)=atot(2*no3-1,1);
            aele(6,1)=atot(2*no3,1);
            aele(7,1)=atot(2*no4-1,1);
            aele(8,1)=atot(2*no4,1);



            strainele(kcount,:)=(bmat*aele)';           % total strain matrix for each element, (x, y, xy)
            stressele(kcount,:)=(C*bmat*aele)';         % total stress matrix for each element, (x, y, xy)
            xele(kcount)=(x1+x2+x3+x4)/4;
            yele(kcount)=(y1+y2+y3+y4)/4;               % coordinate of each element
            [thele,rele]=cart2pol(xele,yele);   % polar coordinate of each element

            % calculation of polar coordinate stress distribution
            srrele(kcount)=stressele(kcount,1) * (cos(thele(kcount)))^2 +2*stressele(kcount,3)*(sin(thele(kcount)) *cos(thele(kcount)))+stressele(kcount,2) *(sin(thele(kcount)))^2;
            sttele(kcount)=stressele(kcount,1) * (sin(thele(kcount)))^2 -2*stressele(kcount,3)*(sin(thele(kcount)) *cos(thele(kcount)))+stressele(kcount,2) *(cos(thele(kcount)))^2;
            srtele(kcount)=(stressele(kcount,2)-stressele(kcount,1))*sin(thele(kcount))*cos(thele(kcount)) +stressele(kcount,3)*((cos(thele(kcount)))^2 -(sin(thele(kcount)))^2);

            %         Thermal stress
            ep=zeros(1,6);
            eptemp=zeros(6,6);

            L11=cos(thele(kcount));  
            L22=-sin(thele(kcount));
            L33=0;
            M11=sin(thele(kcount));
            M22=cos(thele(kcount));
            M33=0;
            N11=0;
            N22=0;
            N33=1;

            eptrans=[L11^2 M11^2 N11^2 2*M11*N11 2*N11*L11 2*L11*M11; L22^2 M22^2 N22^2 2*M22*N22 2*N22*L22 2*L22*M22; L33^2 M33^2 N33^2 2*M33*N33 2*N33*L33 2*L33*M33; L22*L33 M22*M33 N22*N33 M22*N33+M33*N22 N22*L33+N33*L22 L22*M33+L33*M22; L33*L11 M33*M11 N33*N11 M11*N33+M33*N11 N11*L33+N33*L11 L11*M33+L33*M11; L11*L22 M11*M22 N11*N22 M11*N22+M22*N11 N11*L22+N22*L11 L11*M22+L22*M11];

            epthertemp=transpose(eptrans)*amat*eptrans;
            epther=epthertemp(2:3,2:3);
            stthertemp=epther\[Gtc*Gec;Gtc*Gec];
            thermalstele(kcount)=stthertemp(1);
            sttele(kcount)=sttele(kcount)+thermalstele(kcount);
            stther=eptrans\[0;stthertemp(1);stthertemp(2);0;0;0];

            sxxele(kcount)=stther(1);
            syyele(kcount)=stther(2);
            sxyele(kcount)=stther(6);
        end

        % Stress distribution
        sxxele=sxxele+stressele(:,1);
        syyele=syyele+stressele(:,2);
        sxyele=sxyele+stressele(:,3);

        %interpolation
        intpolno=5000; %interpolation number
        [thfem,rfem]=cart2pol(xele,yele);

        [RFEM,THFEM] = meshgrid(linspace(min(rfem),max(rfem),intpolno), linspace(0,2*pi,intpolno));
        [XFEM,YFEM]=pol2cart(THFEM,RFEM);
        f = scatteredInterpolant(xele,yele,sttele);         
        St=f(XFEM,YFEM)';
        f = scatteredInterpolant(xele,yele,srrele);    
        Sr=f(XFEM,YFEM)';
        f = scatteredInterpolant(xele,yele,srtele);
        Trt=f(XFEM,YFEM)';
        f = scatteredInterpolant(xele,yele,sxxele);         
        Sxx=f(XFEM,YFEM)';
        f = scatteredInterpolant(xele,yele,syyele);         
        Syy=f(XFEM,YFEM)';
        f = scatteredInterpolant(xele,yele,sxyele);         
        Txy=f(XFEM,YFEM)';
        f = scatteredInterpolant(xele,yele,thermalstele);
        thermalst=f(XFEM,YFEM)';
        Tyz=zeros(size(XFEM));
        Txz=zeros(size(XFEM));
        Trz=zeros(size(XFEM));
        Ttz=zeros(size(XFEM));
        Sz=zeros(size(XFEM));
        Szz=zeros(size(XFEM));




        for i=1:length(Sr(:,1))
            for j=1:length(Sr(1,:))
                Aeig=eig([Sr(i,j), Trt(i,j); Trt(i,j), St(i,j)]);
                Beig = sort(Aeig);
                Sp1(i,j) = Beig(2); %Max
                Sp2(i,j) = Beig(2); %Mid
                Sp3(i,j) = Beig(1); %Min
            end
        end
        xnode=nodep(:,1);
        ynode=nodep(:,2);
        atotx=zeros(length(atot)/2,1);
        atoty=zeros(length(atot)/2,1);
        for i=1:length(atot)/2
            atotx(i)=atot(i*2-1);
            atoty(i)=atot(i*2);
        end
        [~,rnode]=cart2pol(xnode,ynode);
        [RFEM2,THFEM2]=meshgrid(linspace(min(rnode),max(rnode),intpolno), linspace(0,2*pi,intpolno));
        [XFEM2,YFEM2]=pol2cart(THFEM2,RFEM2);
        f = scatteredInterpolant(xnode,ynode,atotx);
        dispxx=f(XFEM2,YFEM2)';
        f = scatteredInterpolant(xnode,ynode,atoty);
        dispyy=f(XFEM2,YFEM2)';

        gridr=RFEM';
        gridtheta=THFEM';

        noder=RFEM2';
        nodetheta=THFEM2';

    end
    handles_fig1 = handles;



    %% 2nd figure GUI setting when Single orientation option is selected
    fig2=figure('position',[500 200 750 500],'Color',[240/255,240/255,240/255],'MenuBar','none','Resize','off');
    handles=guihandles(fig2);
    handles.mnfile=uimenu(fig2,'label','File');
    handles.mnsave=uimenu(handles.mnfile,'label','Save Raw Data', 'Callback',{@Callmnsave, handles});
    handles.Graph=axes('units','normalized','position',[50/750 50/500 400/750 400/500]);
    handles.Gr=Gr;
    handles.Sr=Sr;
    handles.St=St;
    handles.r=gridr;
    handles.theta=gridtheta;

    handles.Sz=Sz;
    handles.Trt=Trt;
    handles.Trz=Trz;
    handles.Ttz=Ttz;
    handles.Sxx=Sxx;
    handles.Syy=Syy;
    handles.Szz=Szz;
    handles.Txy=Txy;
    handles.Tyz=Tyz;
    handles.Txz=Txz;
    handles.noder=noder;
    handles.nodetheta=nodetheta;
    handles.dispxx=dispxx;
    handles.dispyy=dispyy;

    handles.Sp1=Sp1;
    handles.Sp2=Sp2;
    handles.Sp3=Sp3;


    thetaop=gridtheta;
    rop=gridr;
    Sp1op=handles.Sp1;
    Sp2op=handles.Sp2;
    Sp3op=handles.Sp3;
    Srop=handles.Sr;
    Stop=handles.St;


    handles.pan1a=uipanel('Title','Failure Criteria', 'position',[500/750, 270/500, 200/750, 200/500], 'visible','on');
    handles.RadSta=uicontrol('parent', handles.pan1a,'style','radiobutton','units','normalized','position',[5/100 86/100 80/100 11/100],'string','Apply failure criteria');
    set(handles.RadSta,'callback',{@CallRadSta, handles})
    handles.text1a=uicontrol('parent', handles.pan1a,'style','text','units','normalized','position',[5/100 69/100 29/100 11/100],'String','UCS ','HorizontalAlignment','right');
    handles.edit1a=uicontrol('parent', handles.pan1a,'style','edit','units','normalized','position',[38/100 71/100 30/100 10/100],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','enable','off');
    handles.text1a=uicontrol('parent', handles.pan1a,'style','text','units','normalized','position',[70/100 69/100 29/100 10/100],'String','MPa','HorizontalAlignment','left');
    handles.text2a=uicontrol('parent', handles.pan1a,'style','text','units','normalized','position',[5/100 52/100 29/100 15/100],'String','Friction Angle ','HorizontalAlignment','right');
    handles.edit2a=uicontrol('parent', handles.pan1a,'style','edit','units','normalized','position',[38/100 54/100 30/100 10/100],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','enable','off');
    handles.text2a=uicontrol('parent', handles.pan1a,'style','text','units','normalized','position',[70/100 52/100 29/100 10/100],'String','degree','HorizontalAlignment','left');
    handles.text3a=uicontrol('parent', handles.pan1a,'style','text','units','normalized','position',[5/100 34/100 29/100 15/100],'String','Tensile Strength ','HorizontalAlignment','right');
    handles.edit3a=uicontrol('parent', handles.pan1a,'style','edit','units','normalized','position',[38/100 37/100 30/100 10/100],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','enable','off');
    handles.text3a=uicontrol('parent', handles.pan1a,'style','text','units','normalized','position',[70/100 34/100 29/100 10/100],'String','MPa','HorizontalAlignment','left');

    handles.pan2a=uipanel('Title','Plotting Option', 'position',[500/750, 110/500, 200/750, 150/500], 'visible','on');
    handles.ctype=uicontrol('parent',handles.pan2a,'style','popupmenu','units','normalized','position',[5/100, 80/100, 90/100, 15/100],'string','Tangential Stress|Radial Stress|Z-axis Stress|Maximum Prinicipal Stress|Minimum Principal Stress|Tresca Stress|Von-Mises Stress','backgroundcolor',[1 1 1], 'enable','on');
    handles.Radcty=uicontrol('parent',handles.pan2a,'style','Radiobutton', 'units','normalized','position',[5/100, 60/100, 90/100, 15/100], 'string', 'Contour Graph', 'HorizontalAlignment','left','value',1);
    set(handles.Radcty,'callback',{@CallRadcty, handles})
    handles.Radpty=uicontrol('parent',handles.pan2a,'style','Radiobutton', 'units','normalized','position',[5/100, 40/100, 90/100, 15/100], 'string', 'Line Graph', 'HorizontalAlignment','left');
    set(handles.Radpty,'callback',{@CallRadpty, handles})
    handles.Radptyr=uicontrol('parent',handles.pan2a,'style','Radiobutton', 'units','normalized','position',[10/100, 22/100, 70/100, 12/100], 'string', 'by R =                m', 'HorizontalAlignment','left','enable','off');
    set(handles.Radptyr,'callback',{@CallRadptyr, handles})
    handles.edit4a=uicontrol('parent',handles.pan2a,'style','edit', 'units','normalized','position',[37/100, 22/100,20/100, 12/100],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','enable','off');
    handles.Radptyth=uicontrol('parent',handles.pan2a,'style','Radiobutton', 'units','normalized','position',[10/100, 6/100, 70/100, 12/100], 'string', 'by Θ =                degree', 'HorizontalAlignment','left','enable','off');
    set(handles.Radptyth,'callback',{@CallRadptyth, handles})
    handles.edit5a=uicontrol('parent',handles.pan2a,'style','edit', 'units','normalized','position',[37/100, 6/100, 20/100, 12/100],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','enable','off');


    handles.Plot=uicontrol('style','pushbutton','units','normalized','position',[525/750, 60/500, 150/750, 30/500],'string','Plot');
    set(handles.Plot,'Callback',{@CallPlot, handles})
    handles.Detail=uicontrol('style','pushbutton','units','normalized','position',[525/750, 20/500, 150/750, 30/500],'string','Local Failure Analysis');
    set(handles.Detail,'Callback',{@CallDetail, handles})
    guidata(fig2,handles);
    toc
end    

handles = handles_fig1;
if get(handles.all, 'value')==1  

    iso=get(handles.butiso, 'value');
    if iso==0
    error('isotropic cases are only available for "all direction"')
    end

    fem=get(handles.RadFEM, 'value');
    if fem==1
    error('analytic solution is only available for "all direction"')
    end

    %% 2nd figure GUI setting when All orientation option is selected
    fig3=figure('position',[500 200 550 500],'Color',[240/255,240/255,240/255], 'resize', 'off')
    annotation(fig3,'textarrow',[0.85 0.81],...
    [0.53 0.53],'String',{'SHmax'});
    annotation(fig3,'textarrow',[0.52 0.52],...
    [0.9 0.85],'String',{'Shmin'});  

    v=str2double(get(handles.edit51,'String'));
    E=str2double(get(handles.edit53,'String'));
    Gmat=[1/E -v/E -v/E 0 0 0; -v/E 1/E -v/E 0 0 0; -v/E -v/E 1/E 0 0 0; 0 0 0 2*(1+v)/E 0 0; 0 0 0 0 2*(1+v)/E 0; 0 0 0 0 0 2*(1+v)/E];

    matrixselect=get(handles.pmatrix, 'value');
    if matrixselect==1
        amatte=inv(Gmat)*10^6;
    end
    if matrixselect==2
        amatte=Gmat/10^6;
    end

    Gpp=str2double(get(handles.edit41, 'String'));
    Gsxi=(str2double(get(handles.edit2, 'String'))-Gpp);
    Gsyi=(str2double(get(handles.edit3, 'String'))-Gpp);
    Gszi=(str2double(get(handles.edit4, 'String'))-Gpp);
    Gfp=0;
    if get(handles.RadFlu,'value')==1
        Gfp=(str2double(get(handles.edit5, 'String'))-Gpp);
    end

    Gtc=0;
    Gec=0;
    if get(handles.RadThe,'value')==1
        Gtc=str2double(get(handles.edit6, 'String'));
        Gec=str2double(get(handles.edit7, 'String'));
    end
    theffect=Gtc*Gec*(1/amatte(1,1))/(1-amatte(2,1)/amatte(1,1));
    Gr=str2double(get(handles.edit8,'String'));

    SHmax=Gsxi;
    Shmin=Gsyi;
    Sv=Gszi;
    Pp=Gpp;
    Pmud=Gpp+Gfp;

    X = [0, 1, 0];
    Y = [1, 0, 0];
    Z = [0, 0, -1];

    % angle from the geographic coordinate system, Y(East)->X(North) is positive
    d_SHmax = 0*pi/180; % angle from the Y(East) axis
    d_Shmin = pi/2; % angle from the X(North) axis, (d_SHmax - pi/2)
    %d_v is same with original Z axis

    % direction vector of stress field
    v_SHmax = [cos(d_SHmax), sin(d_SHmax), 0];
    v_Shmin = [cos(d_Shmin), sin(d_Shmin), 0];
    v_Sv = Z;

    S = sort([SHmax, Shmin, Sv],'descend');
    S_s = [S(1),0,0;0,S(2),0;0,0,S(3)];

    % define direction cosine
    if Sv == S(1) %normal
        dS1 = v_Sv;
        dS2 = v_SHmax;
        dS3 = v_Shmin;

        l1 = dot(dS1,X)/(norm(dS1)*norm(X)); l2 = dot(dS1,Y)/(norm(dS1)*norm(Y)); l3 = dot(dS1,Z)/(norm(dS1)*norm(Z));
        m1 = dot(dS2,X)/(norm(dS2)*norm(X)); m2 = dot(dS2,Y)/(norm(dS2)*norm(Y)); m3 = dot(dS2,Z)/(norm(dS2)*norm(Z));
        n1 = dot(dS3,X)/(norm(dS3)*norm(X)); n2 = dot(dS3,Y)/(norm(dS3)*norm(Y)); n3 = dot(dS3,Z)/(norm(dS3)*norm(Z));

    elseif Sv == S(2) %strike-slip
        dS1 = v_SHmax;
        dS2 = v_Sv;
        dS3 = v_Shmin;

        l1 = dot(dS1,X)/(norm(dS1)*norm(X)); l2 = dot(dS1,Y)/(norm(dS1)*norm(Y)); l3 = dot(dS1,Z)/(norm(dS1)*norm(Z));
        m1 = dot(dS2,X)/(norm(dS2)*norm(X)); m2 = dot(dS2,Y)/(norm(dS2)*norm(Y)); m3 = dot(dS2,Z)/(norm(dS2)*norm(Z));
        n1 = dot(dS3,X)/(norm(dS3)*norm(X)); n2 = dot(dS3,Y)/(norm(dS3)*norm(Y)); n3 = dot(dS3,Z)/(norm(dS3)*norm(Z));   
    else
        dS1 = v_SHmax;
        dS2 = v_Shmin;
        dS3 = v_Sv;

        l1 = dot(dS1,X)/(norm(dS1)*norm(X)); l2 = dot(dS1,Y)/(norm(dS1)*norm(Y)); l3 = dot(dS1,Z)/(norm(dS1)*norm(Z));
        m1 = dot(dS2,X)/(norm(dS2)*norm(X)); m2 = dot(dS2,Y)/(norm(dS2)*norm(Y)); m3 = dot(dS2,Z)/(norm(dS2)*norm(Z));
        n1 = dot(dS3,X)/(norm(dS3)*norm(X)); n2 = dot(dS3,Y)/(norm(dS3)*norm(Y)); n3 = dot(dS3,Z)/(norm(dS3)*norm(Z));
    end

    R_s = [l1, l2, l3; m1, m2, m3; n1, n2, n3];
    S_g = R_s'*S_s*R_s;

    delta = 0: pi/20: 2*pi;
    phi = 0: pi/20: pi/2;

    %delta = -22*pi/180; %delta는 X(North) -> Y(East) 방향으로 계산, 한 방향에 대해 계산할
    %때
    %phi = 48*pi/180; 

    R = 1; %radius of wellbore

    %lower hemisphere projection
    for i = 1 : length(delta)
        for j = 1 : length(phi)
            %X_fig(i,j) = R*tan(phi(j)/2)*sin(delta(i)); %equal angle
            %Y_fig(i,j) = R*tan(phi(j)/2)*cos(delta(i));
            X_fig(i,j) = sqrt(2)*R*cos(pi/2-phi(j)/2)*sin(delta(i)); %equal area
            Y_fig(i,j) = sqrt(2)*R*cos(pi/2-phi(j)/2)*cos(delta(i));
            UCS(i,j) = calUCS(delta(i), phi(j), Pp, Pmud, v, S_g, amatte, Gtc, Gec);
        end
    end


    hold on
    surf(X_fig,Y_fig,UCS);
    axis equal;
    shading interp;
    colormap jet;
    c=colorbar;
    c.Label.String = '(MPa)';
    c.Location = 'southoutside'
    xlim([-R R]);
    ylim([-R R]);
    xticks([]);
    yticks([]);
    xticklabels({});
    yticklabels({});
    title ({'Required UCS';' ';' '}, 'Fontsize', 14);

    deltaobb = 0 : pi/12 : 2*pi; 
    phiobb = 0 : pi/12 : pi/2; 

    for i = 1 : length(deltaobb)
        for j = 1 : length(phiobb)
            %X_figobb(i,j) = R*tan(phiobb(j)/2)*sin(deltaobb(i)); 
            %Y_figobb(i,j) = R*tan(phiobb(j)/2)*cos(deltaobb(i));
            X_figobb(i,j) = sqrt(2)*R*cos(pi/2-phiobb(j)/2)*sin(deltaobb(i)); 
            Y_figobb(i,j) = sqrt(2)*R*cos(pi/2-phiobb(j)/2)*cos(deltaobb(i));
            OBB(i,j) = calOBB(deltaobb(i), phiobb(j), Pp, Pmud, v, S_g, amatte, Gtc, Gec);
        end
    end
    
    hold on
    phi_line = linspace(0, 2*pi, 13);
    [x_line, y_line]=pol2cart(phi_line,R);
    for i = 1:6
        plot3([x_line(i) x_line(i+6)], [y_line(i) y_line(i+6)], [9999 9999], 'LineWidth', 0.1, 'color', 'k')
    end
    

    xre = reshape(X_figobb,[],1);
    yre = reshape(Y_figobb,[],1);
    obbre = reshape(OBB,[],1);
    thetare = atan(yre./xre);
    total = thetare-obbre;


    fig4=figure('position',[1000 200 550 500],'Color',[240/255,240/255,240/255], 'menubar', 'none', 'resize', 'off')

    const = R/20;
    for i=1:length(xre) %시추공의 공벽파괴 방향
        plot([xre(i)+const*cos(total(i)), xre(i)-const*cos(total(i))], ...
            [yre(i)+const*sin(total(i)), yre(i)-const*sin(total(i))], 'r', 'linewidth', 2 )
        hold on
    end
    hold on
    for i=1:length(xre) %시추공의 x축 방향 (시추공 좌표계)
        plot([xre(i)+const*cos(thetare(i)), xre(i)-const*cos(thetare(i))], ...
            [yre(i)+const*sin(thetare(i)), yre(i)-const*sin(thetare(i))], 'k')
        hold on
    end

    xlim([-R*1.25 R*1.25]);
    ylim([-R*1.25 R*1.25]);
    xticks([]);
    yticks([]);
    xticklabels({});
    yticklabels({});
    axis square
    title ('Borehole Breakout Orientation', 'Fontsize', 14);
end



catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end


function CallRadSta(hObject,eventdata,handles)
% callback when Apply Failure Criteria button is clicked

try
    
    handles=guidata(gcbo);

    if get(handles.RadSta,'Value')==1
        set(handles.edit1a,'enable','on')
        set(handles.edit2a,'enable','on')
        set(handles.edit3a,'enable','on')
    end
    if get(handles.RadSta,'Value')==0
        set(handles.edit1a,'enable','off')
        set(handles.edit2a,'enable','off')
        set(handles.edit3a,'enable','off')
    end
    guidata(gcbo,handles);  
    
catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallRadcty(hObject, eventdata, handles)
% callback when Contour Graph option in Plotting Option is selected
try

handles=guidata(gcbo);

if get(handles.Radcty,'value')==1
    set(handles.Radpty, 'value', 0)
    set(handles.Radptyr, 'enable','off')
    set(handles.Radptyth, 'enable','off')
    set(handles.edit4a, 'enable','off')
    set(handles.edit5a, 'enable','off')
end
if get(handles.Radcty,'value')==0
    set(handles.Radpty, 'value', 1)
    set(handles.Radptyr, 'enable','on')
    set(handles.Radptyth, 'enable','on')
    set(handles.edit4a, 'enable','on')
    set(handles.edit5a, 'enable','on')
end
guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallRadpty(hObject, eventdata, handles)
% callback when Line Graph option in Plotting Option is selected
try
    
handles=guidata(gcbo);

if get(handles.Radpty,'value')==0
    set(handles.Radcty, 'value', 1)
    set(handles.Radptyr, 'enable','off')
    set(handles.Radptyth, 'enable','off')
    set(handles.edit4a, 'enable','off')
    set(handles.edit5a, 'enable','off')
end
if get(handles.Radpty,'value')==1
    set(handles.Radcty, 'value', 0)
    set(handles.Radptyr, 'enable','on')
    set(handles.Radptyth, 'enable','on')
    set(handles.edit4a, 'enable','on')
    set(handles.edit5a, 'enable','on')
end
guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallRadptyr(hObject, eventdata, handles)
% callback when 'by R=' option in Line Graph is selected
try
    
handles=guidata(gcbo);
if get(handles.Radptyr,'value')==0
    set(handles.Radptyth,'value',1)
end
if get(handles.Radptyr,'value')==1
    set(handles.Radptyth,'value',0)
end
guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallRadptyth(hObject, eventdata, handles)
% callback when 'by theta=' option in Line Graph is selected
try
    
handles=guidata(gcbo);
if get(handles.Radptyth,'value')==0
    set(handles.Radptyr,'value',1)
end
if get(handles.Radptyth,'value')==1
    set(handles.Radptyr,'value',0)
end
guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end
    
    
function CallPlot(hObject, eventdata, handles)
global Gucs Gfri Gten Whradsta
try
    
handles=guidata(gcbo);
switch get(handles.ctype, 'value')
    case 1
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=handles.St*10^-6;
        plottitle='Tangential stress (MPa)';
    case 2
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=handles.Sr*10^-6;
        plottitle='Radial stress (MPa)';
    case 3
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=handles.Sz*10^-6;
        plottitle='Axial stress (MPa)';
    case 4
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=handles.Sp1*10^-6;
        plottitle='Maximum principal stress (MPa)';
    case 5
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=handles.Sp3*10^-6;
        plottitle='Minimum principal stress (MPa)';
    case 6
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=(handles.Sp1-handles.Sp3)*10^-6;
        plottitle='Tresca stress (MPa)';
    case 7
        [contx,conty]=pol2cart(handles.theta,handles.r);
        plotvalue=((1/sqrt(2))*((handles.Sp1-handles.Sp2).^2+(handles.Sp2-handles.Sp3).^2+(handles.Sp3-handles.Sp1).^2).^(1/2))*10^-6;
        plottitle='Von-mises stress';
%         case 8
%             [contx,conty]=pol2cart(handles.nodetheta,handles.noder);
%             plotvalue=handles.dispxx;
%             plottitle='X-axis displacment';
%         case 9
%             [contx,conty]=pol2cart(handles.nodetheta,handles.noder);
%             plotvalue=handles.dispyy;
%             plottitle='Y-axis displacment';
end
if get(handles.Radcty, 'value')==1


%         [meshtheta,meshr]=meshgrid(handles.theta,handles.r);
    handles.Graph = pcolor(contx,conty,plotvalue);
    shading interp
    colormap(jet(256))
    daspect([1 1 1])
    limdata=handles.Gr*3;
    xlim([-limdata limdata])
    ylim([-limdata limdata])
    title(plottitle)
    colorbar;
    caxis([min(min(plotvalue)) max(max((plotvalue)))])

    Gucs=0;
    Gfri=0;
    Gten=0;
    Whradsta=0;
    if get(handles.RadSta, 'Value')==1
        Whradsta=1;
        Gucs=str2double(get(handles.edit1a, 'String'))*10^6;
        Gfri=str2double(get(handles.edit2a, 'String'))*2*pi/360;
        Gten=str2double(get(handles.edit3a, 'String'))*10^6;
        sign=-(Gucs+handles.Sp3.*(1+sin(Gfri))./(1-sin(Gfri))-handles.Sp1);
        sign2=-(handles.Sp3+Gten);
        hold on
        contour(contx,conty,sign,[0 0], 'k','LineWidth', 1.5);
        contour(contx,conty,sign2,[0 0], 'r', 'LineWidth', 1.5);
        hold off
    end
end

if get(handles.Radpty, 'value')==1
    if get(handles.Radptyr, 'value')==1
        plotr=str2double(get(handles.edit4a, 'String'));
        [minr1,minr2]=min((handles.r(:,1)-plotr).^2);
        handles.Graph=plot(handles.theta(minr2,:)*360/(2*pi), plotvalue(minr2,:));
        title(plottitle)
        xlabel('Angle(degree)')
        ylabel('Stress(MPa)')
        xlim([0 360])
    end
    if get(handles.Radptyth, 'value')==1
        plottheta=str2double(get(handles.edit5a, 'String'))/360 *2*pi;
        [minth1,minth2]=min((handles.theta(1,:)-plottheta).^2);
        handles.Graph=plot(handles.r(:,minth2), plotvalue(:,minth2));
        title(plottitle)
        xlabel('Radius(m)')
        ylabel('Stress(MPa)')
    end
end

guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Callmnsave(hObject,eventdata,handles)

try
    
figsave=figure('position', [600 400 200 100],'Color',[240/255,240/255,240/255],'MenuBar','none','Resize','off');
%     handles=guidata(gcbo);
handles=guihandles(figsave);
handles.Rad1mn=uicontrol('style','Radiobutton','position',[25 75 200 20],'String','Along the borehole wall ', 'HorizontalAlignment','right','Value',1);
set(handles.Rad1mn,'callback',{@CallRad1mn, handles})
handles.Rad2mn=uicontrol('style','Radiobutton','position',[25 45 80 20],'String','by θ=', 'HorizontalAlignment','right');
set(handles.Rad2mn,'callback',{@CallRad2mn, handles})
handles.edit2mn=uicontrol('style','edit','position',[95 45 65 20],'backgroundcolor',[1 1 1],'HorizontalAlignment','right','string','0','enable','off');
handles.text2mn=uicontrol('style','text','position',[165 42 40 20],'String','deg', 'HorizontalAlignment','left');
%handles.text1mn=uicontrol('style','text','position',[30 52 80 20],'String','File name', 'HorizontalAlignment','left');
%handles.edit3mn=uicontrol('style','edit','position',[95 55 65 20],'backgroundcolor',[1 1 1],'HorizontalAlignment','right');

handles.mnsaveok=uicontrol('style','pushbutton','position',[70 10 60 20],'String','Save as');
set(handles.mnsaveok,'Callback',{@Callmnsaveok,handles})

guidata(figsave,handles);
%         guidata(gcbo,handles);  

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallRad1mn(hObject,eventdata,handles)

try
    
handles=guidata(gcbo);
if get(handles.Rad1mn,'Value')==1
    set(handles.Rad2mn,'Value',0)
    set(handles.edit2mn,'enable','off')
end
if get(handles.Rad1mn,'Value')==0
    set(handles.Rad2mn,'Value',1)
    set(handles.edit2mn,'enable','on')
end
guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallRad2mn(hObject,eventdata,handles)

try
    
handles=guidata(gcbo);
if get(handles.Rad2mn,'Value')==1
    set(handles.Rad1mn,'Value',0)
    set(handles.edit2mn,'enable','on')
end
if get(handles.Rad2mn,'Value')==0
    set(handles.Rad1mn,'Value',1)
    set(handles.edit2mn,'enable','off')
end
guidata(gcbo,handles);

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function handles=Callmnsaveok(hObject,eventdata,handles)
global thetaop rop Sp1op Sp3op Srop Stop Gucs Gfri Whradsta
try

handles=guidata(gcbo);




[file, path] = uiputfile('*', 'Save as');
if file ~= 0
    
    filetheta=str2double(get(handles.edit2mn,'String'))*2*pi/360 ;
    
    [min3,min4]=min((thetaop(1,:)-filetheta).^2);
    
    fname = sprintf('%s%s', path, file);

    if Whradsta==1 % when 'failure criteria' option is enabled
        
        Smc(1,1:length(thetaop(1,:)))=Gucs+Sp3op(1,1:length(thetaop(1,:)))*(1+sin(Gfri))/(1-sin(Gfri))-Sp1op(1,1:length(thetaop(1,:)));
        rbbo=0;
        thetabbo=0;
        [minSmc, i_theta_minSmc] = min(Smc(1,:));
        %[min.Smc on the borehole wall, theta index of min.Smc]
        if minSmc<=0 % meets M-C criterion on some point of the borehole wall
            if max(Smc)<=0 % M-C failure in all around the borehole wall
                thetabbo=pi;
                for i_theta = i_theta_minSmc-359:i_theta_minSmc+359
                    i_r = 1;
                    while Gucs+Sp3op(i_r,i_theta)*(1+sin(Gfri))/(1-sin(Gfri))-Sp1op(i_r,i_theta)<=0
                        i_r=i_r+1;
                    end
                    if rop(i_r-1,1)>rbbo
                        rbbo=rop(i_r-1,1);
                    end
                end
            else % typical borehole breakout
                i_theta=i_theta_minSmc;
                while Gucs+Sp3op(1,i_theta)*(1+sin(Gfri))/(1-sin(Gfri))-Sp1op(1,i_theta)<=0
                    i_theta=i_theta-1;
                end
                i_theta1=i_theta+1;
                i_theta=i_theta_minSmc;
                while Gucs+Sp3op(1,i_theta)*(1+sin(Gfri))/(1-sin(Gfri))-Sp1op(1,i_theta)<=0
                    i_theta=i_theta+1;
                end
                i_theta2=i_theta-1;
                thetabbo=thetaop(1,i_theta2)-thetaop(1,i_theta1);
                for i_theta = i_theta1:i_theta2
                    i_r = 1;
                    while Gucs+Sp3op(i_r,i_theta)*(1+sin(Gfri))/(1-sin(Gfri))-Sp1op(i_r,i_theta)<=0
                        i_r=i_r+1;
                    end
                    if rop(i_r-1,1)>rbbo
                        rbbo=rop(i_r-1,1);
                    end
                end
            end
        end
                
        
        fileID=fopen([fname,'_bbo.txt'],'w');
        fprintf(fileID, 'Rbbo = %5f\r\nθbbo = %5f\r\n',[rbbo,thetabbo*180/pi]);
        fclose(fileID);
    end
    if get(handles.Rad2mn,'Value')==1
        fileID=fopen([fname,'_r.txt'],'w');
        outputdata=[rop(:,min4)';Srop(:,min4)'.*10^-6];
        fprintf(fileID,'Radius (m)  Radial stress (MPa)\r\n');
        fprintf(fileID,'%4f   %12.6f\r\n',outputdata);
        fclose(fileID);
        fileID=fopen([fname,'_t.txt'],'w');
        outputdata=[rop(:,min4)';Stop(:,min4)'.*10^-6];
        fprintf(fileID,'Radius (m)  Tangential stress (MPa)\r\n');
        fprintf(fileID,'%4f   %12.6f\r\n',outputdata);
        fclose(fileID);
    end
    if get(handles.Rad1mn,'Value')==1
        fileID=fopen([fname,'_r.txt'],'w');
        outputdata=[thetaop(1,:);Srop(1,:).*10^-6];
        fprintf(fileID,'Angle (rad)  Radial stress (MPa)\r\n');
        fprintf(fileID,'%4f   %12.6f\r\n',outputdata);
        fclose(fileID);
        fileID=fopen([fname,'_t.txt'],'w');
        outputdata=[thetaop(1,:);Stop(1,:).*10^-6];
        fprintf(fileID,'Angle (rad)  Tangential stress (MPa)\r\n');
        fprintf(fileID,'%4f   %12.6f\r\n',outputdata);
        fclose(fileID);
    end
    
end

guidata(gcbo,handles);
close

catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end

function CallDetail(hObject, eventdata, handles)

try
    
handles=guidata(gcbo);
[xginput, yginput]=ginput(1);
[thginput,rginput]=cart2pol(xginput,yginput);
rad=handles.r;

if rginput<rad
elseif rginput>rad*3
else
    [xx,yy]=pol2cart(handles.theta,handles.r);
    [mina1,mina2]=min((xx-xginput).^2 + (yy-yginput).^2);
    [minb1,minb2]=min((mina1));

    rget=handles.r(mina2(minb2),minb2);
    thget=handles.theta(mina2(minb2),minb2);
    Sp1=handles.Sp1(mina2(minb2), minb2);
    Sp2=handles.Sp2(mina2(minb2), minb2);
    Sp3=handles.Sp3(mina2(minb2), minb2);
    Sx=handles.Sxx(mina2(minb2), minb2);
    Sy=handles.Syy(mina2(minb2), minb2);
    Sr=handles.Sr(mina2(minb2), minb2);
    St=handles.St(mina2(minb2), minb2);
    Sz=handles.Szz(mina2(minb2), minb2);
    Trt=handles.Trt(mina2(minb2), minb2);
    Ttz=handles.Ttz(mina2(minb2), minb2);
    Trz=handles.Trz(mina2(minb2), minb2);
    
    t = Sp3:10000:Sp1;

    y1 = real(sqrt(((Sp2-Sp3)/2).^2-(t-(Sp2+Sp3)/2).^2)) ;  
    y2 = real(sqrt(((Sp3-Sp1)/2).^2-(t-(Sp3+Sp1)/2).^2)) ;
    y3 = real(sqrt(((Sp1-Sp2)/2).^2-(t-(Sp1+Sp2)/2).^2)) ; 

    z = [y1; y2; y3];

    hFig=figure('Position', [500 250 1000 500],'Color',[240/255,240/255,240/255],'MenuBar','none','Resize','off');

    mTextBox1 = uicontrol('style','text', 'Position', [10 50 980 15]);
    mTextBox2 = uicontrol('style','text', 'Position', [10 30 980 15]);
    mTextBox3 = uicontrol('style','text', 'Position', [10 10 980 15]);

    handles.Mohr=axes('units','normalized','position',[200/1000 150/500 600/1000 300/500]);

    handles.Mohr=plot(t*10^-6,z*10^-6,'-b');
    hold on

    tmpxmax=ceil(max(t));
    tmpxmin=floor(min(t));
    tmpymax=3*(Sp1-Sp3)/4;
    tmpymin=ceil(min(t));
    xlim([tmpxmin tmpxmax]*10^-6);
    ylim([0 tmpymax]*10^-6);
    xlabel('Normal Stress');
    ylabel('Shear Stress');
    daspect([1 1 1]);
    set(mTextBox1,'String', ['Stress at   r = ' num2str(rget) 'm    θ = ' num2str(thget*360/(2*pi)) 'degree']);
    set(mTextBox2,'String', ['  Degree :    σrr = ' num2str(Sr/1000000) 'Mpa   σθθ = ' num2str(St/1000000) 'Mpa   σz =  ' num2str(Sz/1000000)]);
    colorOfFigureWindow = get(hFig, 'color');
    set(mTextBox1,'BackgroundColor',colorOfFigureWindow)
    set(mTextBox2,'BackgroundColor',colorOfFigureWindow)
    set(mTextBox3,'BackgroundColor',colorOfFigureWindow)
    if get(handles.RadSta,'value')==1
        Gucs=str2double(get(handles.edit1a, 'String'))*10^6;
        Gfri=str2double(get(handles.edit2a, 'String'))*2*pi/360;
        Gten=str2double(get(handles.edit3a, 'String'))*10^6;
        C0=Gucs/2 * (1-sin(Gfri))/cos(Gfri);
        reqC0=sqrt(1+(tan(Gfri))^2) *sqrt(((Sp3-Sp1)/2)^2) - (tan(Gfri))*(Sp1+Sp3)/2;
        y4 = tan(Gfri)*t+C0;
        y5 = tan(Gfri)*t+reqC0;
        handles.Mohr=plot(t*10^-6, y4*10^-6,'-r');
        hold on
        handles.Mohr=plot(t*10^-6,y5*10^-6,'--r');
        set(mTextBox3, 'String', ['Strength:    C0 = ' num2str(C0/1000000) '  intFric = ' num2str(tan(Gfri)) '  Required C0 = ' num2str(reqC0/1000000) '   (MC failure criterion)']);
    end
end


catch ex
    errmsg = ex.stack.line;
    msgbox([{'BSA.m' 'Error found in line ' num2str(errmsg)} {ex.message}]);
end

end
% set(h.pushrun, 'callback',{@pushrun,h})
% 
% function h=pushrun(hObject, eventdata, h)
% a=get(h.elatable, 'Data');
% a