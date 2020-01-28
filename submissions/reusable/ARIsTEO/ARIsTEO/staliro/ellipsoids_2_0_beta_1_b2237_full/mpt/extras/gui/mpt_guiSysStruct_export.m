% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout = mpt_guiSysStruct_export(varargin)
% MPT_GUISYSSTRUCT_EXPORT M-file for mpt_guiSysStruct_export.fig
%      MPT_GUISYSSTRUCT_EXPORT, by itself, creates a new MPT_GUISYSSTRUCT_EXPORT or raises the existing
%      singleton*.
%
%      H = MPT_GUISYSSTRUCT_EXPORT returns the handle to a new MPT_GUISYSSTRUCT_EXPORT or the handle to
%      the existing singleton*.
%
%      MPT_GUISYSSTRUCT_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MPT_GUISYSSTRUCT_EXPORT.M with the given input arguments.
%
%      MPT_GUISYSSTRUCT_EXPORT('Property','Value',...) creates a new MPT_GUISYSSTRUCT_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mpt_guiSysStruct_export_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mpt_guiSysStruct_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mpt_guiSysStruct_export

% Last Modified by GUIDE v2.5 15-Apr-2005 18:59:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mpt_guiSysStruct_export_OpeningFcn, ...
                   'gui_OutputFcn',  @mpt_guiSysStruct_export_OutputFcn, ...
                   'gui_LayoutFcn',  @mpt_guiSysStruct_export_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before mpt_guiSysStruct_export is made visible.
function mpt_guiSysStruct_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mpt_guiSysStruct_export (see VARARGIN)

mpt_guiCenter(hObject);

mpt___sysStruct = mpt_setSysStruct;

% Choose default command line output for mpt_guiSysStruct_export
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
SelectDynamics_Callback(handles.SelectDynamics, eventdata, handles);

if ~isempty(get(handles.Adyn, 'String')),
    set(handles.button_textlabels, 'Enable', 'on');
else
    set(handles.button_textlabels, 'Enable', 'off');
end

ispwa = 0;
if isstruct(mpt___sysStruct)
    sst = mpt___sysStruct;
    if isfield(sst, 'A')
        if iscell(sst.A),
            ispwa = 1;
        end
        set(handles.button_textlabels, 'Enable', 'on');
    elseif isfield(sst, 'B')
        if iscell(sst.B),
            ispwa = 1;
        end
    elseif isfield(sst, 'C')
        if iscell(sst.C),
            ispwa = 1;
        end
    elseif isfield(sst, 'guardX')
        ispwa = 1;
    end
end

if ispwa,
    set(handles.checkbox_pwasystem, 'Value', 1);
    sub_pwa_specific_fields('on', handles);
end

% if ~isempty(get(handles.Adyn, 'String')),
%     set(handles.button_textlabels, 'Enable', 'on');
% else
%     set(handles.button_textlabels, 'Enable', 'off');
% end

% UIWAIT makes mpt_guiSysStruct_export wait for user response (see UIRESUME)
uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = mpt_guiSysStruct_export_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles),
    varargout{1} = [];
else
    varargout{1} = handles.output;
    % The figure can be deleted now
    uiresume(handles.figure1);
    delete(handles.figure1);
end

% --- Executes during object creation, after setting all properties.
function Adyn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Adyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Adyn_Callback(hObject, eventdata, handles)
% hObject    handle to Adyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Adyn as text
%        str2double(get(hObject,'String')) returns contents of Adyn as a double

dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'A',get(hObject,'String'));
if ~isempty(get(hObject, 'String'))
    set(handles.button_textlabels, 'Enable', 'On');
else
    set(handles.button_textlabels, 'Enable', 'Off');
end


% --- Executes during object creation, after setting all properties.
function Bdyn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Bdyn_Callback(hObject, eventdata, handles)
% hObject    handle to Bdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bdyn as text
%        str2double(get(hObject,'String')) returns contents of Bdyn as a double


dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'B',get(hObject,'String'));

if ~isempty(get(hObject, 'String'))
    set(handles.button_inputs, 'Enable', 'On');
else
    set(handles.button_inputs, 'Enable', 'Off');
end


% --- Executes during object creation, after setting all properties.
function Cdyn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Cdyn_Callback(hObject, eventdata, handles)
% hObject    handle to Cdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cdyn as text
%        str2double(get(hObject,'String')) returns contents of Cdyn as a double


dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'C',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function Ddyn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ddyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Ddyn_Callback(hObject, eventdata, handles)
% hObject    handle to Ddyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ddyn as text
%        str2double(get(hObject,'String')) returns contents of Ddyn as a double

dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'D',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function fdyn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function fdyn_Callback(hObject, eventdata, handles)
% hObject    handle to fdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fdyn as text
%        str2double(get(hObject,'String')) returns contents of fdyn as a double


dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'f',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function gdyn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function gdyn_Callback(hObject, eventdata, handles)
% hObject    handle to gdyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gdyn as text
%        str2double(get(hObject,'String')) returns contents of gdyn as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'g',get(hObject,'String'));


% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddDynamics.
function dynamics_add_Callback(hObject, eventdata, handles)
% hObject    handle to AddDynamics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dynstrings = get(handles.SelectDynamics,'String');

% get numbers in strings, determine if strings contain numerical hole, i.e.:
% Dynamics 1, Dynamics 2, Dynamics 4 - Dynamics 3 is not present
dynnumbers = str2num(dynstrings(:,end-1:end));
maxdynnumb = max(dynnumbers);
freenumbers = setdiff(1:maxdynnumb, dynnumbers);
if isempty(freenumbers),
    newindex = maxdynnumb+1;
else
    newindex = freenumbers(1);
end
newdynstring = sprintf('Dynamics %d', newindex);

dynstrings = strvcat(dynstrings, newdynstring);
dynnumbers = str2num(dynstrings(:,end-1:end));
[i,j] = sort(dynnumbers);
dynstrings = dynstrings(j,:);

set(handles.SelectDynamics, 'String', dynstrings);
curvalue = get(handles.SelectDynamics, 'Value');
set(handles.SelectDynamics, 'Value', newindex);
Adyn_Callback(handles.Adyn, eventdata, handles);
Bdyn_Callback(handles.Bdyn, eventdata, handles);
fdyn_Callback(handles.fdyn, eventdata, handles);
Cdyn_Callback(handles.Cdyn, eventdata, handles);
Ddyn_Callback(handles.Ddyn, eventdata, handles);
gdyn_Callback(handles.gdyn, eventdata, handles);
activeregion_Callback(handles.activeregion, eventdata, handles);

sub_clearDynamicsFields(handles);


% --- Executes on button press in Clear.
function Clear_Callback(hObject, eventdata, handles)
% hObject    handle to Clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_clearDynamicsFields(handles);


% --- Executes on button press in Help.
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'ymin',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'ymax',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function dymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dymin_Callback(hObject, eventdata, handles)
% hObject    handle to dymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dymin as text
%        str2double(get(hObject,'String')) returns contents of dymin as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'dymin',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function dymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dymax_Callback(hObject, eventdata, handles)
% hObject    handle to dymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dymax as text
%        str2double(get(hObject,'String')) returns contents of dymax as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'dymax',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function umin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to umin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function umin_Callback(hObject, eventdata, handles)
% hObject    handle to umin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of umin as text
%        str2double(get(hObject,'String')) returns contents of umin as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'umin',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function umax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to umax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function umax_Callback(hObject, eventdata, handles)
% hObject    handle to umax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of umax as text
%        str2double(get(hObject,'String')) returns contents of umax as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'umax',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function dumin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dumin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dumin_Callback(hObject, eventdata, handles)
% hObject    handle to dumin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dumin as text
%        str2double(get(hObject,'String')) returns contents of dumin as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'dumin',get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function dumax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dumax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dumax_Callback(hObject, eventdata, handles)
% hObject    handle to dumax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dumax as text
%        str2double(get(hObject,'String')) returns contents of dumax as a double



dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'dumax',get(hObject,'String'));


% --- Executes on button press in button_inputs.
function button_inputs_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mpt_guiInputs_export;

% --- Executes on button press in help_guards.
function help_guards_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg([sprintf('Define guardlines of a region in which a given PWA dynamics should be active. Example:\n\n'), ...
        sprintf('x(1) <= 1\nx(2) >= x(1)\nu(1) >= 1\nx(1) - u(2) <= 3')]);

% --- Executes on button press in help_guards.
function help_yeq_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg([sprintf('Defines output equation in the matrix form:\n\n'), ...
        sprintf('y(k) = C*x(k) + D*u(k) + g\n\nNote: The affine "g" term is available only for PWA systems.')]);

% --- Executes on button press in help_guards.
function help_xeq_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg([sprintf('Defines state-update equation in the matrix form:\n\n'), ...
        sprintf('x(k+1) = A*x(k) + B*u(k) + f\n\nNote: The affine "f" term is available only for PWA systems.')]);


% --- Executes on button press in help_guards.
function help_ubounds_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg([sprintf('Defines constraints on manipulated variable(s):\n\n'), ...
        sprintf('* Lower / upper bounds: u_min <= u(k) <= u_max\n\n* Slew rate constraints: du_min <= u(k) - u(k+1) <= du_max\n\n'), ...
        'Note: If rate constraints are non-empty, the state-space vector must be augmented in order to '...
        'guarantee fullfilment of such constraints. This can have a big impact on computational time and solution complexity!']);

% --- Executes on button press in help_guards.
function help_ybounds_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg([sprintf('Defines constraints on system outputs(s):\n\n'), ...
        sprintf('* Lower / upper bounds: y_min <= y(k) <= y_max\n\n* Slew rate constraints: dy_min <= y(k) - y(k+1) <= dy_max\n\n')]);

% --- Executes on button press in help_guards.
function help_xbounds_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg([sprintf('Defines constraints on system states(s):\n\n'), ...
        sprintf('x_min <= x(k) <= x_max')]);


% --- Executes on button press in help_guards.
function help_selectdyn_Callback(hObject, eventdata, handles)
% hObject    handle to button_inputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_helpdlg(['Allows to switch between different dynamics of a PWA system. '...
        'Use the "Dynamics" menu to add / remove single dynamics from the list.'...
        sprintf('\n\nNote: This option is not available if the system is not Piecewise-Affine!')]);


% --- Executes during object creation, after setting all properties.
function SelectDynamics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectDynamics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

global mpt___sysStruct

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%clear global mpt___sysStruct

if ~isstruct(mpt___sysStruct)
    try
        mpt___sysStruct = evalin('base', 'sysStruct');
    catch
        mpt___sysStruct = [];
    end
end
try,
    mpt_setSysStruct(mpt___sysStruct);
end

sysStruct = mpt_setSysStruct;

if ~isstruct(sysStruct),
    set(hObject, 'String', 'Dynamics 1');
    set(hObject, 'Value', 1);
    return
end

ispwa = 0;
ndyn = 1;
if isfield(sysStruct,'A'),
    if iscell(sysStruct.A),
        ndyn = length(sysStruct.A);
        ispwa = 1;
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'B'),
    if iscell(sysStruct.B),
        ndyn = length(sysStruct.B);
        ispwa = 1;
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'C'),
    if iscell(sysStruct.C),
        ndyn = length(sysStruct.C);
        ispwa = 1;
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'D'),
    if iscell(sysStruct.D),
        ndyn = length(sysStruct.D);
        ispwa = 1;
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'f'),
    if iscell(sysStruct.f),
        ndyn = length(sysStruct.f);
        ispwa = 1;
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'g'),
    if iscell(sysStruct.g),
        ndyn = length(sysStruct.g);
        ispwa = 1;
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'guardX'),
    if iscell(sysStruct.guardX),
        ispwa = 1;
        ndyn = length(sysStruct.guardX);
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'guardU'),
    if iscell(sysStruct.guardU),
        ispwa = 1;
        ndyn = length(sysStruct.guardU);
    else
        ndyn = 1;
    end
elseif isfield(sysStruct,'guardC'),
    if iscell(sysStruct.guardC),
        ispwa = 1;
        ndyn = length(sysStruct.guardC);
    else
        ndyn = 1;
    end
end    

dynstrings = '';
for ii=1:ndyn
    dynstrings = strvcat(dynstrings, sprintf('Dynamics %d',ii));
end
set(hObject, 'String', dynstrings);
set(hObject, 'Value', 1);
% if ispwa,
%     set(hObject, 'Enable', 'on');
% end

% --- Executes on selection change in SelectDynamics.
function SelectDynamics_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDynamics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectDynamics contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectDynamics

sysStruct = mpt_setSysStruct;

contents = get(hObject, 'String');
newdyn = str2num(contents(get(hObject,'Value'),end-1:end));

if ~isstruct(sysStruct),
    return
end

sub_clearDynamicsFields(handles);
sub_setDynamicsFields(sysStruct, newdyn, handles);
sub_setConstrFields(sysStruct, handles);
return


% --- Sets fields for constraints
function sub_setConstrFields(sysStruct, handles);
% sysStruct - system structure
% handles   - structure with handles and user data (see GUIDATA)

if isfield(sysStruct, 'ymax'),
    set(handles.ymax, 'String', sub_mat2str(sysStruct.ymax));
end
if isfield(sysStruct, 'ymin'),
    set(handles.ymin, 'String', sub_mat2str(sysStruct.ymin));
end
if isfield(sysStruct, 'xmax'),
    set(handles.xmax, 'String', sub_mat2str(sysStruct.xmax));
end
if isfield(sysStruct, 'xmin'),
    set(handles.xmin, 'String', sub_mat2str(sysStruct.xmin));
end
if isfield(sysStruct, 'dymax'),
    set(handles.dymax, 'String', sub_mat2str(sysStruct.dymax));
end
if isfield(sysStruct, 'dymin'),
    set(handles.dymin, 'String', sub_mat2str(sysStruct.dymin));
end
if isfield(sysStruct, 'umax'),
    set(handles.umax, 'String', sub_mat2str(sysStruct.umax));
end
if isfield(sysStruct, 'umin'),
    set(handles.umin, 'String', sub_mat2str(sysStruct.umin));
end
if isfield(sysStruct, 'dumax'),
    set(handles.dumax, 'String', sub_mat2str(sysStruct.dumax));
end
if isfield(sysStruct, 'dumin'),
    set(handles.dumin, 'String', sub_mat2str(sysStruct.dumin));
end


% --- Sets dynamics fields
function sub_setDynamicsFields(sysStruct, newdyn, handles);
% sysStruct - system structure
% newdyn    - index of requested dynamics
% handles   - structure with handles and user data (see GUIDATA)

if isfield(sysStruct, 'Ts'),
    set(handles.textfield_Ts, 'String', sub_mat2str(sysStruct.Ts));
end

if isfield(sysStruct, 'A'),
    if iscell(sysStruct.A),
        if length(sysStruct.A) >= newdyn,
            set(handles.Adyn, 'String', sub_mat2str(sysStruct.A{newdyn}));
        end
    elseif newdyn==1,
        set(handles.Adyn, 'String', sub_mat2str(sysStruct.A));
    end
end
if isfield(sysStruct, 'B'),
    if iscell(sysStruct.B),
        if length(sysStruct.B) >= newdyn,
            set(handles.Bdyn, 'String', sub_mat2str(sysStruct.B{newdyn}));
        end
    elseif newdyn==1,
        set(handles.Bdyn, 'String', sub_mat2str(sysStruct.B));
    end
end
if isfield(sysStruct, 'C'),
    if iscell(sysStruct.C),
        if length(sysStruct.C) >= newdyn,
            set(handles.Cdyn, 'String', sub_mat2str(sysStruct.C{newdyn}));
        end
    elseif newdyn==1,
        set(handles.Cdyn, 'String', sub_mat2str(sysStruct.C));
    end
end
if isfield(sysStruct, 'D'),
    if iscell(sysStruct.D),
        if length(sysStruct.D) >= newdyn,
            set(handles.Ddyn, 'String', sub_mat2str(sysStruct.D{newdyn}));
        end
    elseif newdyn==1,
        set(handles.Ddyn, 'String', sub_mat2str(sysStruct.D));
    end
end
if isfield(sysStruct, 'f'),
    if iscell(sysStruct.f),
        if length(sysStruct.f) >= newdyn,
            set(handles.fdyn, 'String', sub_mat2str(sysStruct.f{newdyn}));
        end
    elseif newdyn==1,
        set(handles.fdyn, 'String', sub_mat2str(sysStruct.f));
    end
end
if isfield(sysStruct, 'g'),
    if iscell(sysStruct.g),
        if length(sysStruct.g) >= newdyn,
            set(handles.gdyn, 'String', sub_mat2str(sysStruct.g{newdyn}));
        end
    elseif newdyn==1,
        set(handles.gdyn, 'String', sub_mat2str(sysStruct.g));
    end
end

if isfield(sysStruct, 'guardX') & isfield(sysStruct, 'guardC'),
    if iscell(sysStruct.guardX),
        if length(sysStruct.guardX) >= newdyn & length(sysStruct.guardC) >= newdyn,
            if isfield(sysStruct, 'guardU') & length(sysStruct.guardU) >= newdyn,
                guards_str = sub_guards2string(sysStruct.guardX{newdyn}, sysStruct.guardU{newdyn}, sysStruct.guardC{newdyn});
            else
                guards_str = sub_guards2string(sysStruct.guardX{newdyn}, [], sysStruct.guardC{newdyn});
            end
            set(handles.activeregion, 'String', guards_str);
        end
    end
end


% --- Executes on button press in RemoveDynamics.
function RemoveDynamics_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveDynamics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function sub_clearDynamicsFields(handles)

% clear given fields
set(handles.Adyn,'String','');
set(handles.Bdyn,'String','');
set(handles.fdyn,'String','');
set(handles.Cdyn,'String','');
set(handles.Ddyn,'String','');
set(handles.gdyn,'String','');
set(handles.activeregion,'String','');
%set(handles.guardU,'String','');
%set(handles.guardC,'String','');


% --- Executes on button press in ClearAll.
function ClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to ClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function xmin_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double

dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'xmin',get(hObject,'String'));



% --- Executes during object creation, after setting all properties.
function textfield_Ts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textfield_Ts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function textfield_Ts_Callback(hObject, eventdata, handles)
% hObject    handle to textfield_Ts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textfield_Ts as text
%        str2double(get(hObject,'String')) returns contents of textfield_Ts as a double

mpt_setSysStruct(1,'Ts',get(hObject,'String'));


% --------------------------------------------------------------------
function import_Callback(hObject, eventdata, handles)
% hObject    handle to import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function import_workspace_Callback(hObject, eventdata, handles)
% hObject    handle to import_workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


sysStruct = mpt_guiLoadWorkSpace_export;

if ~isstruct(sysStruct) | isempty(sysStruct),
    return
end
newdyn = 1;
sub_clearDynamicsFields(handles);
sub_clearConstrFields(handles);

sub_setDynamicsFields(sysStruct, newdyn, handles);
sub_setConstrFields(sysStruct, handles);
set(handles.SelectDynamics, 'Value', 1);
ispwa = 0;
if isfield(sysStruct, 'A')
    if iscell(sysStruct.A),
        ispwa = 1;
    end
    set(handles.button_textlabels, 'Enable', 'on');
end
set(handles.checkbox_pwasystem, 'Value', ispwa);
if ispwa,
    sub_pwa_specific_fields('on', handles)
else
    sub_pwa_specific_fields('off', handles)
end

% --------------------------------------------------------------------
function import_file_Callback(hObject, eventdata, handles)
% hObject    handle to import_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, fpath] = uigetfile({'*.m', 'MATLAB files (*.m)'}, 'Pick an M-file');
if fname==0,
    % the dialog box was closed manually
    return
end

sysStruct = [];
if ~isempty(fname)
    sysStruct = execute_sysstructfile(fname, fpath);
end
if ~isstruct(sysStruct) | isempty(sysStruct),
    return
end
clear global mpt___sysStruct

mpt_setSysStruct(sysStruct);
newdyn = 1;
sub_clearDynamicsFields(handles);
sub_setDynamicsFields(sysStruct, newdyn, handles);
sub_setConstrFields(sysStruct, handles);
set(handles.SelectDynamics, 'String', 'Dynamics 1');
set(handles.SelectDynamics, 'Value', 1);

ispwa = 0;
if isfield(sysStruct, 'A')
    if iscell(sysStruct.A),
        ispwa = 1;
    end
    set(handles.button_textlabels, 'Enable', 'on');
end
set(handles.checkbox_pwasystem, 'Value', ispwa);
if ispwa,
    sub_pwa_specific_fields('on', handles)
    ndyn = mpt_setSysStruct('ndyn');
    selectdynstr = '';
    for ii = 1:ndyn,
        selectdynstr = strvcat(selectdynstr, sprintf('Dynamics %d', ii));
    end
    set(handles.SelectDynamics, 'String', selectdynstr);
    set(handles.SelectDynamics, 'Value', 1);
else
    sub_pwa_specific_fields('off', handles)
end


% --------------------------------------------------------------------
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_workspace_Callback(hObject, eventdata, handles)
% hObject    handle to export_workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msg = mpt_setSysStruct('validate');
if ~isempty(msg),
    errordlg(sprintf('Validation error:\n%s', msg), 'Error', 'modal');
    return
end

sysStruct = mpt_setSysStruct;

varname = inputdlg({'Export to workspace as'}, 'Export to workspace', 1, {'sysStruct'});

if ~isempty(varname),
    try
        assignin('base', varname{1}, sysStruct);
    catch
        sub_errordlg(lasterr);
    end
end

% --------------------------------------------------------------------
function export_file_Callback(hObject, eventdata, handles)
% hObject    handle to export_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msg = mpt_setSysStruct('validate');
if ~isempty(msg),
    errordlg(sprintf('Validation error:\n%s', msg), 'Error', 'modal');
    return
end
sysStruct = mpt_setSysStruct;

[fname, fpath] = uiputfile('*.m', 'Save system as');

if ischar(fname),
    try
        sub_saveSysStruct(sysStruct, fname, fpath);
    catch
        sub_errordlg(lasterr);
    end
end
    

% --------------------------------------------------------------------
function export_hysdel_Callback(hObject, eventdata, handles)
% hObject    handle to export_hysdel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dynamics_Callback(hObject, eventdata, handles)
% hObject    handle to dynamics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % --------------------------------------------------------------------
% function dynamics_add_Callback(hObject, eventdata, handles)
% % hObject    handle to dynamics_add (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dynamics_remove_Callback(hObject, eventdata, handles)
% hObject    handle to dynamics_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dynstrings = get(handles.SelectDynamics,'String');

if size(dynstrings,1)<2,
    % cannot remove if only one dynamics is defined
    return
end

value = get(handles.SelectDynamics, 'Value');

% remove current dynamics string from the stack
dynstrings(value, :) = [];

if size(dynstrings,1)==1,
    newvalue = 1;
else
    if value==1,
        newvalue = 2;
    else
        newvalue = value - 1;
    end
end

set(handles.SelectDynamics, 'String', dynstrings);
set(handles.SelectDynamics, 'Value', newvalue);

sysStruct = mpt_setSysStruct;

if ~isstruct(sysStruct),
    return
end
%try
%    sysStruct = evalin('base', 'sysStruct');
    if isfield(sysStruct,'A') 
        if iscell(sysStruct.A),
            sysStruct.A{value} = [];
        end
    end
    if isfield(sysStruct,'B') 
        if iscell(sysStruct.B),
            sysStruct.B{value} = [];
        end
    end
    if isfield(sysStruct,'C') 
        if iscell(sysStruct.C),
            sysStruct.C{value} = [];
        end
    end
    if isfield(sysStruct,'D') 
        if iscell(sysStruct.D),
            sysStruct.D{value} = [];
        end
    end
    if isfield(sysStruct,'f') 
        if iscell(sysStruct.f),
            sysStruct.f{value} = [];
        end
    end
    if isfield(sysStruct,'g') 
        if iscell(sysStruct.g),
            sysStruct.g{value} = [];
        end
    end
    if isfield(sysStruct,'guardX') 
        if iscell(sysStruct.guardX),
            sysStruct.guardX{value} = [];
        end
    end
    if isfield(sysStruct,'guardU') 
        if iscell(sysStruct.guardU),
            sysStruct.guardU{value} = [];
        end
    end
    if isfield(sysStruct,'guardC') 
        if iscell(sysStruct.guardC),
            sysStruct.guardC{value} = [];
        end
    end
    %assignin('base','sysStruct',sysStruct);
    %end

% --------------------------------------------------------------------
function dynamics_clear_Callback(hObject, eventdata, handles)
% hObject    handle to dynamics_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sub_clearDynamicsFields(handles);

% --------------------------------------------------------------------
function dynamics_clearall_Callback(hObject, eventdata, handles)
% hObject    handle to dynamics_clearall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

res = questdlg('Clear all fields and start from scratch?', 'Confirm action', ...
    'Yes', 'No', 'No');

if strcmpi(res, 'yes')
    clear global mpt___sysStruct
    
    sub_clearDynamicsFields(handles);
    set(handles.SelectDynamics, 'String', 'Dynamics 1');
    set(handles.SelectDynamics, 'Value', 1);
    set(handles.checkbox_pwasystem, 'Value', 0);
    set(handles.xmax, 'String', '');
    set(handles.xmin, 'String', '');
    set(handles.umax, 'String', '');
    set(handles.umin, 'String', '');
    set(handles.dumax, 'String', '');
    set(handles.dumin, 'String', '');
    set(handles.ymax, 'String', '');
    set(handles.ymin, 'String', '');
    set(handles.dymax, 'String', '');
    set(handles.dymin, 'String', '');
    set(handles.activeregion, 'String', '');
    set(handles.button_textlabels, 'Enable', 'off');
    sub_pwa_specific_fields('off', handles);
end
    


% --------------------------------------------------------------------
function menu_main_Callback(hObject, eventdata, handles)
% hObject    handle to menu_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);
delete(handles.figure1);

% --- Executes on button press in checkbox_pwasystem.
function checkbox_pwasystem_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pwasystem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pwasystem

value = get(hObject, 'Value');
if value==1,
    sub_pwa_specific_fields('on', handles);
else
    sub_pwa_specific_fields('off', handles);
end


% --- Executes during object creation, after setting all properties.
function select_state_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_state (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in select_state.
function select_state_Callback(hObject, eventdata, handles)
% hObject    handle to select_state (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_state contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_state


% --- Executes during object creation, after setting all properties.
function edit_statename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_statename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_statename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_statename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_statename as text
%        str2double(get(hObject,'String')) returns contents of edit_statename as a double


% --- Executes during object creation, after setting all properties.
function select_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in select_input.
function select_input_Callback(hObject, eventdata, handles)
% hObject    handle to select_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_input contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_input


% --- Executes during object creation, after setting all properties.
function edit_inputname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inputname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_inputname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inputname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_inputname as text
%        str2double(get(hObject,'String')) returns contents of edit_inputname as a double


% --- Executes during object creation, after setting all properties.
function select_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in select_output.
function select_output_Callback(hObject, eventdata, handles)
% hObject    handle to select_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_output contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_output


% --- Executes during object creation, after setting all properties.
function edit_outputname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outputname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_outputname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outputname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_outputname as text
%        str2double(get(hObject,'String')) returns contents of edit_outputname as a double


% --- Executes on button press in button_return.
function button_return_Callback(hObject, eventdata, handles)
% hObject    handle to button_return (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sysStruct = mpt_setSysStruct;

if ~isstruct(sysStruct),
    uiresume(handles.figure1);
    delete(handles.figure1);
    return
end

if isempty(sysStruct),
    uiresume(handles.figure1);
    delete(handles.figure1);
    return
end

msg = mpt_setSysStruct('validate');
if ~isempty(msg),
    set(handles.text_status, 'String', 'Validation error!');
    set(handles.text_status, 'ForegroundColor', [1 0 0]);
    sub_errordlg(msg);
    return
end

sysStruct = mpt_setSysStruct;

handles.output = sysStruct;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
%delete(handles.figure1);

% --- Executes on button press in button_validate.
function button_validate_Callback(hObject, eventdata, handles)
% hObject    handle to button_validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msg = mpt_setSysStruct('validate');
if ~isempty(msg),
    set(handles.text_status, 'String', 'Validation error!');
    set(handles.text_status, 'ForegroundColor', [1 0 0]);
    sub_errordlg(msg);
else
    set(handles.text_status, 'String', 'The system has been successfully validated.');
    set(handles.text_status, 'ForegroundColor', [0 0.5 0]);
    set(handles.text_status, 'FontWeight', 'bold');
    %msgbox('The system has been successfully validated.');
end

% --- Executes on button press in button_textlabels.
function button_textlabels_Callback(hObject, eventdata, handles)
% hObject    handle to button_textlabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(get(handles.Adyn, 'String')) | ...
        isempty(get(handles.Bdyn, 'String')) | ...
        isempty(get(handles.Cdyn, 'String')),
    errordlg('Please define fields "A, B, C, D" first!', 'Error', 'modal');
    return
end
mpt_guiTextLabels_export;



%================================================================
function sub_pwa_specific_fields(status, handles)

set(handles.fdyn, 'Visible', status);
set(handles.text_fdyn, 'Visible', status);
set(handles.gdyn, 'Visible', status);
set(handles.text_gdyn, 'Visible', status);
set(handles.guard_header, 'Visible', status);
set(handles.frame_guard, 'Visible', status);
set(handles.activeregion, 'Visible', status);
set(handles.SelectDynamics, 'Enable', status);
set(handles.help_guards, 'Visible', status);


% --- Executes during object creation, after setting all properties.
function activeregion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to activeregion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function activeregion_Callback(hObject, eventdata, handles)
% hObject    handle to activeregion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of activeregion as text
%        str2double(get(hObject,'String')) returns contents of activeregion as a double

str_guards = get(hObject, 'String');
[gX, gU, gC] = sub_string2guards(str_guards, get(handles.Adyn, 'String'), get(handles.Bdyn, 'String'));
dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'guardX',gX);
mpt_setSysStruct(dyn,'guardU',gU);
mpt_setSysStruct(dyn,'guardC',gC);


%====================================================================
function res = sub_mat2str(mat)

res = mat2str(mat, 4);


%====================================================================
function guards_str = sub_guards2string(gX, gU, gC);

nc = size(gX, 1);
nx = size(gX, 2);
if isempty(gU)
    gU = zeros(nc, 1);
    nu = 1;
else
    nu = size(gU, 1);
end
guards_str = '';
for ii = 1:nc,
    guards_str = strvcat(guards_str, char(mptaffexpr(nx, nu, gX(ii, :), gU(ii, :), gC(ii, :))));
end

%====================================================================
function [guardX, guardU, guardC] = sub_string2guards(guards, A, B);

if ~ischar(guards)
    error('Guardlines must be a string!');
end
% if ischar(A),
%     A = str2num(A);
% end
% if ischar(B),
%     B = str2num(B);
% end
% 
% nx = size(A, 1);
% nu = size(B, 2);

nx = mpt_setSysStruct('nx');
if isempty(nx),
    if ischar(A),
        A = str2num(A);
    end
    nx = size(A, 1);
end

nu = mpt_setSysStruct('nu');
if isempty(nu),
    if ischar(B),
        B = str2num(B);
    end
    nu = size(B, 2);
end

x = mptvar('state', nx);
u = mptvar('input', nu);

guardX = [];
guardU = [];
guardC = [];
for ii = 1:size(guards, 1)
    oneguard = deblank(guards(ii, :));
    if isempty(findstr(oneguard, '<')) & isempty(findstr(oneguard, '>')),
        errordlg(sprintf('No inequality constraint defined at line:\n%s', oneguard), 'Error', 'modal');
        guardX = [];
        guardU = [];
        guardC = [];
        return
    end
    if length(findstr(oneguard, '<')) > 1 | length(findstr(oneguard, '>')) > 1,
        errordlg(sprintf('Only one iequality sign allowed at:\n%s', oneguard), 'Error', 'modal');
        guardX = [];
        guardU = [];
        guardC = [];
        return
    end
    if isempty(findstr(oneguard, '=')),
        errordlg(sprintf('Inequality must be non-strict (i.e. <= or >=) at:\n%s', oneguard), 'Error', 'modal');
        guardX = [];
        guardU = [];
        guardC = [];
        return
    end
    try
        eval(['mpt__guard = ' oneguard ';']);
    catch
        sub_errordlg(lasterr);
        guardX = [];
        guardU = [];
        guardC = [];
        return
    end
    [gX, gU, gC] = double(mpt__guard);
    if isempty(gX),
        gX = zeros(1, nx);
    end
    if isempty(gU),
        gU = zeros(1, nu);
    end
    if isempty(gC),
        gC = 0;
    end
    guardX = [guardX; gX];
    guardU = [guardU; gU];
    guardC = [guardC; gC];
end


% --------------------------------------------------------------------
function file_load_file_Callback(hObject, eventdata, handles)
% hObject    handle to file_load_hysdel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_load_hysdel_Callback(hObject, eventdata, handles)
% hObject    handle to file_load_hysdel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, fpath] = uigetfile({'*.hys', 'HYSDEL files (*.hys)'}, 'Pick an HYSDEL file');
if fname==0,
    % the dialog box was closed manually
    return
end

sysStruct = [];
if ~isempty(fname)
    sysStruct = execute_hysdelfile(fname, fpath, handles);
end
if ~isstruct(sysStruct) | isempty(sysStruct),
    return
end
clear global mpt___sysStruct

mpt_setSysStruct(sysStruct);
newdyn = 1;
sub_clearDynamicsFields(handles);
sub_setDynamicsFields(sysStruct, newdyn, handles);
sub_setConstrFields(sysStruct, handles);
set(handles.SelectDynamics, 'String', 'Dynamics 1');
set(handles.SelectDynamics, 'Value', 1);
sub_clearConstrFields(handles);


ispwa = 0;
if isfield(sysStruct, 'A')
    if iscell(sysStruct.A),
        ispwa = 1;
    end
end
set(handles.checkbox_pwasystem, 'Value', ispwa);
if ispwa,
    sub_pwa_specific_fields('on', handles)
    ndyn = mpt_setSysStruct('ndyn');
    selectdynstr = '';
    for ii = 1:ndyn,
        selectdynstr = strvcat(selectdynstr, sprintf('Dynamics %d', ii));
    end
    set(handles.SelectDynamics, 'String', selectdynstr);
    set(handles.SelectDynamics, 'Value', 1);
else
    sub_pwa_specific_fields('off', handles)
end


%============================================================
function sysStruct = execute_sysstructfile(fname, fpath)

origfname = fname;
dotpos = findstr(fname, '.');
if ~isempty(dotpos),
    try
        fname = fname(1:dotpos-1);
    catch
        errordlg(sprintf('Corrupted file name "%s"', origfname), 'Error', 'modal');
    end
end
sysStruct = [];
try
    curdir = pwd;
    cd(fpath);
    T = evalc(fname);
    if ~mpt_issysstruct(sysStruct),
        errordlg(sprintf('The file "%s" does not contain a valid system structure!', origfname), 'Error', 'modal');
    end
catch
    errordlg(sprintf('The file "%s" does not contain a valid system structure!', origfname), 'Error', 'modal');
end


%============================================================
function sysStruct = execute_hysdelfile(fname, fpath, handles)

cwd = pwd;
cd(fpath);
msg = '';

set(handles.text_status, 'String', 'Conversion from HYSDEL in progress...');
curcolor = get(handles.text_status, 'ForegroundColor');
%curweight = get(handles.text_status, 'FontWeight');
set(handles.text_status, 'ForegroundColor', [0 0 0])
%set(handles.text_status, 'FontWeight', 'bold');
try
    T=evalc(sprintf('[sysStruct, msg] = mpt_sys(''%s'');', fname));
    set(handles.text_status, 'ForegroundColor', [0 .5 0])
    set(handles.text_status, 'String', 'Conversion successfull.');
    if isempty(sysStruct),
        error('sysStruct is empty');
    end
catch
    set(handles.text_status, 'ForegroundColor', [1 0 0])
    %set(handles.text_status, 'FontWeight', 'bold');
    set(handles.text_status, 'String', 'Conversion failed!');
    cd(cwd);
    if isempty(msg),
        errordlg(sprintf('An error occured:\n%s', lasterr), 'Error', 'modal');
    else
        errordlg(sprintf('HYSDEL produced an error:\n%s', msg), 'Error', 'modal');
    end
    sysStruct = [];
end

cd(cwd);



%============================================================
function sub_clearConstrFields(handles)

set(handles.xmax, 'String', '');
set(handles.xmin, 'String', '');
set(handles.umax, 'String', '');
set(handles.umin, 'String', '');
set(handles.dumax, 'String', '');
set(handles.dumin, 'String', '');
set(handles.dymax, 'String', '');
set(handles.dymin, 'String', '');
set(handles.ymax, 'String', '');
set(handles.ymin, 'String', '');



%============================================================
function sub_saveSysStruct(sysStruct, fname, fpath)

if isempty(findstr(fname, '.m')),
    fname = [fname '.m'];
end
fullname = [fpath fname];
fid = fopen(fullname, 'w');
if fid<0,
    errordlg(sprintf('Error creating file "%s" !', fullname), 'Error', 'modal');
    return
end

allowedfields = {'A', 'B', 'C', 'D', 'f', 'g', 'guardX', ...
        'guardU', 'guardC', 'umax', 'umin', 'dumax', 'dumin', ...
        'ymax', 'ymin', 'dymax', 'dymin', 'xmax', 'xmin', ...
        'Uset', 'InputName', 'StateName', 'OutputName'};

ssFields = fields(sysStruct);

if isfield(sysStruct, 'data')
    % this sysStruct came from a HYSDEL file
    hysdelfile = sysStruct.data.hysdel.fromfile;
    str = ['''Importing from "' hysdelfile '"...'''];
    fprintf(fid, 'disp(%s);\n', str);
    fprintf(fid, 'sysStruct = mpt_sys(''%s'');\n', hysdelfile);
    allowedfields = {'umax', 'umin', 'dumax', 'dumin', ...
        'ymax', 'ymin', 'dymax', 'dymin', 'xmax', 'xmin', ...
        'InputName', 'StateName', 'OutputName'};
end

for ii = 1:length(ssFields),
    fieldname = ssFields{ii};
    if ~any(ismember(allowedfields, fieldname)),
        continue
    end
    value = getfield(sysStruct, fieldname);
    if iscell(value),
        for jj = 1:length(value),
            cval = value{jj};
            if isa(cval, 'polytope'),
                [H, K] = double(cval);
                fprintf(fid, 'sysStruct.%s{%d} = polytope(%s, %s);\n', fieldname, jj, mat2str(H), mat2str(K));
                
            elseif ischar(cval),
                cval = sprintf('''%s''', cval);

            elseif ~ischar(cval),
                cval = mat2str(cval);
            end
            
            if ~isa(cval, 'polytope'),
                fprintf(fid, 'sysStruct.%s{%d} = %s;\n', fieldname, jj, cval);
            end
        end
    else
        if isa(value, 'polytope'),
            [H, K] = double(value);
            fprintf(fid, 'sysStruct.%s = polytope(%s, %s);\n', fieldname, mat2str(H), mat2str(K));
            
        elseif ischar(value),
            value = sprintf('''%s''', value);

        elseif ~ischar(value),
            value = mat2str(value);
        end
        if ~isa(value, 'polytope') & ~isstruct(value),
            fprintf(fid, 'sysStruct.%s = %s;\n', fieldname, value);
        end
    end
end

fclose(fid);



%=============================================================
function sub_errordlg(msg)

origmsg = msg;

try
    newmsg = msg;
    errorpos = findstr(msg, 'Error using ==>');
    if ~isempty(errorpos),
        newmsg = msg(length('Error using ==>')+2:end);
        newlinepos = findstr(newmsg, 10);
        spacepos = findstr(newmsg, ' ');
        if ~isempty(newlinepos) & ~isempty(spacepos),
            breakpos = min(newlinepos(1), spacepos(1));
            newmsg = newmsg(breakpos+1:end);
        elseif isempty(newlinepos),
            newmsg = newmsg(spacepos(1)+1:end);
        elseif isempty(spacepos),
            newmsg = newmsg(newlinepos(1)+1:end);
        end
    end
    errordlg(newmsg, 'Error', 'modal');
catch
    errordlg(origmsg, 'Error', 'modal');
end

%============================================================
function sub_helpdlg(msg)

msgbox(msg, 'Help', 'modal');


% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function xmax_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


dyn = get(handles.SelectDynamics,'Value');
mpt_setSysStruct(dyn,'xmax',get(hObject,'String'));


% --- Creates and returns a handle to the GUI figure. 
function h1 = mpt_guiSysStruct_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

h1 = figure(...
'Units','characters',...
'Color',[0.847058823529412 0.847058823529412 0.847058823529412],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','Model setup',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[9.8 42.2307692307692 145.8 34.6923076923077],...
'Renderer',get(0,'defaultfigureRenderer'),...
'RendererMode','manual',...
'Resize','off',...
'HandleVisibility','callback',...
'Tag','figure1',...
'UserData',[]);

setappdata(h1, 'GUIDEOptions',struct(...
'active_h', [], ...
'taginfo', struct(...
'figure', 2, ...
'frame', 19, ...
'text', 32, ...
'edit', 31, ...
'pushbutton', 26, ...
'popupmenu', 6, ...
'slider', 2, ...
'togglebutton', 2, ...
'checkbox', 2), ...
'override', 0, ...
'release', 13, ...
'resize', 'none', ...
'accessibility', 'callback', ...
'mfile', 1, ...
'callbacks', 1, ...
'singleton', 1, ...
'syscolorfig', 1, ...
'blocking', 0, ...
'lastSavedFile', 'C:\MatlabFiles\mpt\mpt\extras\gui\mpt_guiSysStruct.m'));


h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[2.6 26.4615384615385 58.8 3.07692307692308],...
'String',{  '' },...
'Style','frame',...
'Tag','frame18',...
'UserData',[]);


h3 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[71 7.76923076923077 67.8 3.07692307692308],...
'String',{  '' },...
'Style','frame',...
'Tag','frame16',...
'UserData',[]);


h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[2.8 10.3076923076923 58.6 7.15384615384615],...
'String',{  '' },...
'Style','frame',...
'Tag','frame14',...
'UserData',[]);


h5 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[2.8 18.7692307692308 58.8 6.61538461538462],...
'String',{  '' },...
'Style','frame',...
'Tag','frame3',...
'UserData',[]);


h6 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[71 19.5384615384615 67.4 8.76923076923077],...
'String',{  '' },...
'Style','frame',...
'Tag','frame5',...
'UserData',[]);


h7 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[71 12.3846153846154 67.6 5.92307692307692],...
'String',{  '' },...
'Style','frame',...
'Tag','frame6',...
'UserData',[]);


h8 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[2.8 0.538461538461539 58.6 8.53846153846154],...
'String',{  '' },...
'Style','frame',...
'Tag','frame_guard',...
'UserData',[],...
'Visible','off');


h9 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[5.4 22.8461538461538 4.2 1.53846153846154],...
'String','A',...
'Style','text',...
'Tag','text1');


h10 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[5.4 21 4 1.46153846153846],...
'String','B',...
'Style','text',...
'Tag','text2');


h11 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''SelectDynamics_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[3 30.6153846153846 35.2 1.69230769230769],...
'String','Dynamics 1',...
'Style','popupmenu',...
'Value',1,...
'CreateFcn','mpt_guiSysStruct_export(''SelectDynamics_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','SelectDynamics');


h12 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''checkbox_pwasystem_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[44.4 30.7692307692308 17.4 1.30769230769231],...
'String','PWA system',...
'Style','checkbox',...
'Tag','checkbox_pwasystem');


h13 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''textfield_Ts_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[10.8 27.1538461538462 47.2 1.69230769230769],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''textfield_Ts_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','textfield_Ts');


h14 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''Adyn_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[11 23 46.8 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''Adyn_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','Adyn');


h15 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''Bdyn_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[11 21.1538461538462 46.8 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''Bdyn_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','Bdyn');


h16 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''fdyn_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[11 19.3076923076923 46.8 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''fdyn_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','fdyn',...
'Visible','off');


h17 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''Cdyn_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[10.8 15 47 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''Cdyn_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','Cdyn');


h18 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''Ddyn_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[10.8 12.9230769230769 47 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''Ddyn_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','Ddyn');


h19 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''gdyn_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[10.8 10.8461538461538 47 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''gdyn_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','gdyn',...
'Visible','off');


h20 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',10,...
'FontWeight','bold',...
'ListboxTop',0,...
'Position',[17.2 32.6153846153846 27.8 1.53846153846154],...
'String','System Dynamics',...
'Style','text',...
'Tag','text5');


h21 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[17.2 24.6923076923077 30.2 1.38461538461538],...
'String','x(k+1) = A x(k) + B u(k) + f',...
'Style','text',...
'Tag','text6');


h22 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[5.4 19.0769230769231 3.6 1.53846153846154],...
'String','f',...
'Style','text',...
'Tag','text_fdyn',...
'Visible','off');


h23 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[100.6 16.0769230769231 9.8 1.15384615384615],...
'String','<= y(k) <=',...
'Style','text',...
'Tag','text10');


h24 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''activeregion_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Max',10,...
'Position',[4.8 1 54.8 7.30769230769231],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''activeregion_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','activeregion',...
'Visible','off');


h25 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''umin_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[72.6 25.9230769230769 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''umin_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','umin');


h26 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''umax_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[115.4 25.9230769230769 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''umax_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','umax');


h27 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''dumin_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[72.6 23.3846153846154 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''dumin_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','dumin');


h28 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''dumax_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[115.6 23.4615384615385 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''dumax_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','dumax');


h29 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''button_inputs_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[92.6 20.4615384615385 26.4 2.15384615384615],...
'String','Boolean / Integer Inputs',...
'Tag','button_inputs');


h30 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''ymin_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[72.6 15.9230769230769 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''ymin_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','ymin');


h31 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''ymax_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[115.4 16 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''ymax_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','ymax');


h32 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',10,...
'FontWeight','bold',...
'ListboxTop',0,...
'Position',[91.4 32.7692307692308 28.8 1.23076923076923],...
'String','System Constraints',...
'Style','text',...
'Tag','text11');


h33 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[92.8 17.6153846153846 24.4 1.23076923076923],...
'String','Output Constraints',...
'Style','text',...
'Tag','text12');


h34 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[93.6 27.6153846153846 22.4 1.23076923076923],...
'String','Input Constraints',...
'Style','text',...
'Tag','text13');


h35 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[96.2 13.5384615384615 18 1.15384615384615],...
'String','<= y(k) - y(k+1) <=',...
'Style','text',...
'Tag','text14');


h36 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''dymin_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[72.6 13.3846153846154 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''dymin_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','dymin');


h37 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''dymax_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[115.4 13.4615384615385 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''dymax_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','dymax');


h38 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[100.4 25.8461538461538 9.8 1.15384615384615],...
'String','<= u(k) <=',...
'Style','text',...
'Tag','text15');


h39 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''xmin_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[72.6 8.46153846153846 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''xmin_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','xmin');


h40 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback','mpt_guiSysStruct_export(''xmax_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[115.4 8.53846153846154 22 1.53846153846154],...
'String','',...
'Style','edit',...
'CreateFcn','mpt_guiSysStruct_export(''xmax_CreateFcn'',gcbo,[],guidata(gcbo))',...
'Tag','xmax');


h41 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''button_return_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[76 0.846153846153846 17.4 1.92307692307692],...
'String','Return',...
'Tag','button_return');


h42 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[96.6 23.6153846153846 18 1.15384615384615],...
'String','<= u(k) - u(k+1) <=',...
'Style','text',...
'Tag','text16');


h43 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[20.6 8.38461538461539 22.8 1.30769230769231],...
'String','Guardlines',...
'Style','text',...
'Tag','guard_header',...
'Visible','off');


h44 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[5.6 14.9230769230769 3.2 1.61538461538462],...
'String','C',...
'Style','text',...
'Tag','text3');


h45 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[5.8 12.8461538461538 3 1.38461538461538],...
'String','D',...
'Style','text',...
'Tag','text4');


h46 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[18.8 16.7692307692308 27.4 1.30769230769231],...
'String','y(k) = C x(k) + D u(k) + g',...
'Style','text',...
'Tag','text7');


h47 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[5.6 10.8461538461538 3.4 1.30769230769231],...
'String','g',...
'Style','text',...
'Tag','text_gdyn',...
'Visible','off');


h48 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''button_validate_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[96.8 0.846153846153846 17.4 1.92307692307692],...
'String','Validate',...
'Tag','button_validate');


h49 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''button_textlabels_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[117.6 0.846153846153846 17.4 1.92307692307692],...
'String','Text Labels',...
'Tag','button_textlabels');


h50 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_selectdyn_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[38.8 30.5384615384615 2.8 1.76923076923077],...
'String','?',...
'Tag','help_selectdyn');


h51 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_xeq_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[62.8 20.9230769230769 2.8 1.76923076923077],...
'String','?',...
'Tag','help_xeq');


h52 = uimenu(...
'Parent',h1,...
'Callback','mpt_guiSysStruct_export(''import_Callback'',gcbo,[],guidata(gcbo))',...
'Label','File',...
'Tag','file');

h53 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''import_workspace_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Load from workspace...',...
'Tag','file_load_workspace');

h54 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''import_file_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Load from M-file...',...
'Tag','import_file');

h55 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''file_load_hysdel_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Load from HYSDEL file...',...
'Tag','file_load_hysdel');

h56 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''export_workspace_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Save to workspace...',...
'Separator','on',...
'Tag','file_save_workspace');

h57 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''export_file_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Save to M-file...',...
'Tag','file_save_file');

h58 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''dynamics_clearall_Callback'',gcbo,[],guidata(gcbo))',...
'Label','New...',...
'Separator','on',...
'Tag','dynamics_clearall');

h59 = uimenu(...
'Parent',h52,...
'Callback','mpt_guiSysStruct_export(''file_exit_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Exit',...
'Separator','on',...
'Tag','file_exit');

h60 = uimenu(...
'Parent',h1,...
'Callback','mpt_guiSysStruct_export(''dynamics_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Dynamics',...
'Tag','dynamics');

h61 = uimenu(...
'Parent',h60,...
'Callback','mpt_guiSysStruct_export(''dynamics_add_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Add dynamics',...
'Tag','dynamics_add');

h62 = uimenu(...
'Parent',h60,...
'Callback','mpt_guiSysStruct_export(''dynamics_remove_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Remove dynamics',...
'Tag','dynamics_remove');

h63 = uimenu(...
'Parent',h60,...
'Callback','mpt_guiSysStruct_export(''dynamics_clear_Callback'',gcbo,[],guidata(gcbo))',...
'Label','Clear current dynamics',...
'Tag','dynamics_clear');

h64 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_yeq_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[63 12.8461538461538 2.8 1.76923076923077],...
'String','?',...
'Tag','help_yeq');


h65 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_guards_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[63 3.92307692307692 2.8 1.76923076923077],...
'String','?',...
'Tag','help_guards',...
'Visible','off');


h66 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_ubounds_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[140.2 23 2.8 1.76923076923077],...
'String','?',...
'Tag','help_ubounds');


h67 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_ybounds_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[140.2 14.4615384615385 2.8 1.76923076923077],...
'String','?',...
'Tag','help_ybounds');


h68 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','mpt_guiSysStruct_export(''help_xbounds_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[140.2 8.38461538461539 2.8 1.76923076923077],...
'String','?',...
'Tag','help_xbounds');


h69 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[101 8.92307692307692 9.8 1.15384615384615],...
'String','<= x(k) <=',...
'Style','text',...
'Tag','text26');


h70 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ListboxTop',0,...
'Position',[89.2 10.1538461538462 32.2 1.30769230769231],...
'String','State Constraints (Optional)',...
'Style','text',...
'Tag','text27');


h71 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'FontSize',10,...
'ListboxTop',0,...
'Position',[72.6 4.69230769230769 66.2 1.23076923076923],...
'String','The system setup was not yet validated',...
'Style','text',...
'Tag','text_status');


h72 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'CData',[],...
'ListboxTop',0,...
'Position',[23 29 18.2 1.15384615384615],...
'String','Sampling time',...
'Style','text',...
'Tag','text30',...
'UserData',[]);


h73 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[6 27.4615384615385 3.4 1.15384615384615],...
'String','Ts',...
'Style','text',...
'Tag','text31');



hsingleton = h1;


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)


%   GUI_MAINFCN provides these command line APIs for dealing with GUIs
%
%      MPT_GUISYSSTRUCT_EXPORT, by itself, creates a new MPT_GUISYSSTRUCT_EXPORT or raises the existing
%      singleton*.
%
%      H = MPT_GUISYSSTRUCT_EXPORT returns the handle to a new MPT_GUISYSSTRUCT_EXPORT or the handle to
%      the existing singleton*.
%
%      MPT_GUISYSSTRUCT_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MPT_GUISYSSTRUCT_EXPORT.M with the given input arguments.
%
%      MPT_GUISYSSTRUCT_EXPORT('Property','Value',...) creates a new MPT_GUISYSSTRUCT_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2005/04/15 17:00:34 $

gui_StateFields =  {'gui_Name'
                    'gui_Singleton'
                    'gui_OpeningFcn'
                    'gui_OutputFcn'
                    'gui_LayoutFcn'
                    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);        
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [getfield(gui_State, gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % MPT_GUISYSSTRUCT_EXPORT
    % create the GUI
    gui_Create = 1;
elseif numargin > 3 & ischar(varargin{1}) & ishandle(varargin{2})
    % MPT_GUISYSSTRUCT_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = 0;
else
    % MPT_GUISYSSTRUCT_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = 1;
end

if gui_Create == 0
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.
    
    % Do feval on layout code in m-file if it exists
    if ~isempty(gui_State.gui_LayoutFcn)
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        end
    end
    
    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    
    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig 
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA
        guidata(gui_hFigure, guihandles(gui_hFigure));
    end
    
    % If user specified 'Visible','off' in p/v pairs, don't make the figure
    % visible.
    gui_MakeVisible = 1;
    for ind=1:2:length(varargin)
        if length(varargin) == ind
            break;
        end
        len1 = min(length('visible'),length(varargin{ind}));
        len2 = min(length('off'),length(varargin{ind+1}));
        if ischar(varargin{ind}) & ischar(varargin{ind+1}) & ...
                strncmpi(varargin{ind},'visible',len1) & len2 > 1
            if strncmpi(varargin{ind+1},'off',len2)
                gui_MakeVisible = 0;
            elseif strncmpi(varargin{ind+1},'on',len2)
                gui_MakeVisible = 1;
            end
        end
    end
    
    % Check for figure param value pairs
    for index=1:2:length(varargin)
        if length(varargin) == index
            break;
        end
        try, set(gui_hFigure, varargin{index}, varargin{index+1}), catch, break, end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end
    
    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
    
    if ishandle(gui_hFigure)
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
        
        % Make figure visible
        if gui_MakeVisible
            set(gui_hFigure, 'Visible', 'on')
            if gui_Options.singleton 
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        rmappdata(gui_hFigure,'InGUIInitialization');
    end
    
    % If handle visibility is set to 'callback', turn it on until finished with
    % OutputFcn
    if ishandle(gui_hFigure)
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end
    
    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end
    
    if ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end    

function gui_hFigure = local_openfig(name, singleton)
try
    gui_hFigure = openfig(name, singleton, 'auto');
catch
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
end

