% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout = staliro_gui(varargin)
% STALIRO_GUI MATLAB code for staliro_gui.fig
%      STALIRO_GUI, by itself, creates a new STALIRO_GUI or raises the existing
%      singleton*.
%
%      H = STALIRO_GUI returns the handle to a new STALIRO_GUI or the handle to
%      the existing singleton*.
%
%      STALIRO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STALIRO_GUI.M with the given input arguments.
%
%      STALIRO_GUI('Property','Value',...) creates a new STALIRO_GUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before staliro_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to staliro_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help staliro_gui

% Last Modified by GUIDE v2.5 04-Jun-2014 13:45:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @staliro_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @staliro_gui_OutputFcn, ...
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

% --- Executes just before staliro_gui is made visible.
function staliro_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to staliro_gui (see VARARGIN)

% Choose default command line output for staliro_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

ha = axes('units','normalized', ...
            'position',[0 0 1 1]);
        
uistack(ha,'bottom');
I=imread('auxiliary\background.tif');
hi = imagesc(I);
colormap gray
% Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% Also, make the axes invisible
set(ha,'handlevisibility','off', ...
            'visible','off')
%set(handles.tblInputs,'Data',[]);
%set(handles.tblInitCond,'Data',[]);
% UIWAIT makes staliro_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = staliro_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density_Callback(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density as text
%        str2double(get(hObject,'String')) returns contents of density as a double
density = str2double(get(hObject, 'String'));
if isnan(density)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new density value
handles.metricdata.density = density;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function volume_Callback(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volume as text
%        str2double(get(hObject,'String')) returns contents of volume as a double
volume = str2double(get(hObject, 'String'));
if isnan(volume)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new volume value
handles.metricdata.volume = volume;
guidata(hObject,handles)


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mass = handles.metricdata.density * handles.metricdata.volume;
set(handles.mass, 'String', mass);

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initialize_gui(gcbf, handles, true);

% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.english)
    set(handles.text4, 'String', 'lb/cu.in');
    set(handles.text5, 'String', 'cu.in');
    set(handles.text6, 'String', 'lb');
else
    set(handles.text4, 'String', 'kg/cu.m');
    set(handles.text5, 'String', 'cu.m');
    set(handles.text6, 'String', 'kg');
end

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.


% Update handles structure
guidata(handles.figure1, handles);


function btnSelModelOne_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile;
addpath(pathname);
set(handles.txtModelOne, 'String', [filename]);

function txtModelOne_Callback(hObject, eventdata, handles)
% hObject    handle to txtModelOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtModelOne as text
%        str2double(get(hObject,'String')) returns contents of txtModelOne as a double


% --- Executes during object creation, after setting all properties.
function txtModelOne_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtModelOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSelModelTwo.
function btnSelModelTwo_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelModelTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile;
set(handles.txtModelTwo, 'String', [filename]);

function txtModelTwo_Callback(hObject, eventdata, handles)
% hObject    handle to txtModelTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtModelTwo as text
%        str2double(get(hObject,'String')) returns contents of txtModelTwo as a double


% --- Executes during object creation, after setting all properties.
function txtModelTwo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtModelTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnIncInputs.
function btnIncInputs_Callback(hObject, eventdata, handles)
% hObject    handle to btnIncInputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(handles.tblInputs,'Data');
sz = size(tableData,1);
tableData{sz+1,1} = '';
tableData{sz+1,2} = '';
tableData{sz+1,3} = '';
tableData{sz+1,4} = '';
set(handles.tblInputs,'Data',tableData)

% --- Executes on button press in btnDecInputs.
function btnDecInputs_Callback(hObject, eventdata, handles)
% hObject    handle to btnDecInputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user dtableData = get(handles.tblInputs,'Data');
tableData = get(handles.tblInputs,'Data');
sz = size(tableData,1);
tableData(sz,:) = [];
set(handles.tblInputs,'Data',tableData)


% --- Executes on button press in btnIncInitCond.
function btnIncInitCond_Callback(hObject, eventdata, handles)
% hObject    handle to btnIncInitCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(handles.tblInitCond,'Data');
sz = size(tableData,1);
tableData{sz+1,1} = [];
tableData{sz+1,2} = [];
set(handles.tblInitCond,'Data',tableData)

% --- Executes on button press in btnDecInitCond.
function btnDecInitCond_Callback(hObject, eventdata, handles)
% hObject    handle to btnDecInitCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(handles.tblInitCond,'Data');
sz = size(tableData,1);
tableData(sz,:) = [];
set(handles.tblInitCond,'Data',tableData)



function txtSpec_Callback(hObject, eventdata, handles)
% hObject    handle to txtSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSpec as text
%        str2double(get(hObject,'String')) returns contents of txtSpec as a double


% --- Executes during object creation, after setting all properties.
function txtSpec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSimTime_Callback(hObject, eventdata, handles)
% hObject    handle to txtSimTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSimTime as text
%        str2double(get(hObject,'String')) returns contents of txtSimTime as a double
    set(hObject,'BackgroundColor','white');
    


% --- Executes during object creation, after setting all properties.
function txtSimTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSimTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbStochOptimizer.
function cmbStochOptimizer_Callback(hObject, eventdata, handles)
% hObject    handle to cmbStochOptimizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cmbStochOptimizer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbStochOptimizer

cmbStochOptimizerIdx = get(handles.cmbStochOptimizer, 'value');
tempCmbStochOptimizerData = get(handles.cmbStochOptimizer, 'String');
val = strtrim(tempCmbStochOptimizerData{cmbStochOptimizerIdx});

switch val
    case 'SA_Taliro'
        set(handles.uip_CE,'Visible','off');
        set(handles.uip_SA,'Visible','on');
%     case 'CE_Taliro'
%         set(handles.uip_SA,'Visible','off');
%         
%         figposSA = get(handles.uip_SA,'Position');
%         figposCE = get(handles.uip_CE,'Position');
%         upos = [figposSA(1), 0.1, figposCE(3), figposCE(4)];
%         set(handles.uip_CE,'Position',upos);
%         
%         set(handles.uip_CE,'Visible','on'); 
        
end


% --- Executes during object creation, after setting all properties.
function cmbStochOptimizer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbStochOptimizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbOdeSolver.
function cmbOdeSolver_Callback(hObject, eventdata, handles)
% hObject    handle to cmbOdeSolver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cmbOdeSolver contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbOdeSolver


% --- Executes during object creation, after setting all properties.
function cmbOdeSolver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbOdeSolver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtRobScale_Callback(hObject, eventdata, handles)
% hObject    handle to txtRobScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRobScale as text
%        str2double(get(hObject,'String')) returns contents of txtRobScale as a double


% --- Executes during object creation, after setting all properties.
function txtRobScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRobScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtLocTrace_Callback(hObject, eventdata, handles)
% hObject    handle to txtLocTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtLocTrace as text
%        str2double(get(hObject,'String')) returns contents of txtLocTrace as a double


% --- Executes during object creation, after setting all properties.
function txtLocTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLocTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSeed_Callback(hObject, eventdata, handles)
% hObject    handle to txtSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSeed as text
%        str2double(get(hObject,'String')) returns contents of txtSeed as a double


% --- Executes during object creation, after setting all properties.
function txtSeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtDimProj_Callback(hObject, eventdata, handles)
% hObject    handle to txtDimProj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDimProj as text
%        str2double(get(hObject,'String')) returns contents of txtDimProj as a double


% --- Executes during object creation, after setting all properties.
function txtDimProj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDimProj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtUndersamplingFactor_Callback(hObject, eventdata, handles)
% hObject    handle to txtUndersamplingFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtUndersamplingFactor as text
%        str2double(get(hObject,'String')) returns contents of txtUndersamplingFactor as a double


% --- Executes during object creation, after setting all properties.
function txtUndersamplingFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtUndersamplingFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function savevarname_Callback(hObject, eventdata, handles)
% hObject    handle to savevarname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savevarname as text
%        str2double(get(hObject,'String')) returns contents of savevarname as a double


% --- Executes during object creation, after setting all properties.
function savevarname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savevarname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtRuns_Callback(hObject, eventdata, handles)
% hObject    handle to txtRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRuns as text
%        str2double(get(hObject,'String')) returns contents of txtRuns as a double


% --- Executes during object creation, after setting all properties.
function txtRuns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSampTime_Callback(hObject, eventdata, handles)
% hObject    handle to txtSampTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSampTime as text
%        str2double(get(hObject,'String')) returns contents of txtSampTime as a double


% --- Executes during object creation, after setting all properties.
function txtSampTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSampTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbTaliroMetric.
function cmbTaliroMetric_Callback(hObject, eventdata, handles)
% hObject    handle to cmbTaliroMetric (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cmbTaliroMetric contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbTaliroMetric


% --- Executes during object creation, after setting all properties.
function cmbTaliroMetric_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbTaliroMetric (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtRobOffset_Callback(hObject, eventdata, handles)
% hObject    handle to txtRobOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRobOffset as text
%        str2double(get(hObject,'String')) returns contents of txtRobOffset as a double


% --- Executes during object creation, after setting all properties.
function txtRobOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRobOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSAnTests_Callback(hObject, eventdata, handles)
% hObject    handle to txtSAnTests (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSAnTests as text
%        str2double(get(hObject,'String')) returns contents of txtSAnTests as a double


% --- Executes during object creation, after setting all properties.
function txtSAnTests_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSAnTests (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtCEnTests_Callback(hObject, eventdata, handles)
% hObject    handle to txtCEnTests (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCEnTests as text
%        str2double(get(hObject,'String')) returns contents of txtCEnTests as a double


% --- Executes during object creation, after setting all properties.
function txtCEnTests_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCEnTests (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtCENumSubdivs_Callback(hObject, eventdata, handles)
% hObject    handle to txtCENumSubdivs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCENumSubdivs as text
%        str2double(get(hObject,'String')) returns contents of txtCENumSubdivs as a double


% --- Executes during object creation, after setting all properties.
function txtCENumSubdivs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCENumSubdivs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtCENumIter_Callback(hObject, eventdata, handles)
% hObject    handle to txtCENumIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCENumIter as text
%        str2double(get(hObject,'String')) returns contents of txtCENumIter as a double


% --- Executes during object creation, after setting all properties.
function txtCENumIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCENumIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtCETilt_Callback(hObject, eventdata, handles)
% hObject    handle to txtCETilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCETilt as text
%        str2double(get(hObject,'String')) returns contents of txtCETilt as a double


% --- Executes during object creation, after setting all properties.
function txtCETilt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCETilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opt = staliro_options();

opt.runs = str2double(get(handles.txtRuns, 'string'));

cmbStochOptimizerIdx = get(handles.cmbStochOptimizer, 'value');
tempCmbStochOptimizerData = get(handles.cmbStochOptimizer, 'String');
if(cmbStochOptimizerIdx == 1)
    tempVar= tempCmbStochOptimizerData{cmbStochOptimizerIdx};
    opt.optimization_solver = tempVar(2:end);
else
    opt.optimization_solver = tempCmbStochOptimizerData{cmbStochOptimizerIdx};
end

switch get(get(handles.uiMainOption,'SelectedObject'),'Tag')
    case 'rdbFals',  
        opt.falsification = 1;
        opt.parameterEstimation = 0;
   % case 'rdbConfTest',  
    case 'rdbParamEst',  
        opt.falsification = 0;
        opt.parameterEstimation = 1;
end

switch get(get(handles.panBlackBox,'SelectedObject'),'Tag')
    case 'bbYes',  opt.black_box = 1;
   % case 'rdbConfTest',  
    case 'bbNo',  opt.black_box = 0;
end

switch get(get(handles.panVarCpTimes,'SelectedObject'),'Tag')
    case 'varcpYes',  opt.varying_cp_times = 1;
   % case 'rdbConfTest',  
    case 'varcpNo',  opt.varying_cp_times = 0;
end

switch get(get(handles.panSpecSpace,'SelectedObject'),'Tag')
    case 'specspaceY',  opt.spec_space = 'Y';
   % case 'rdbConfTest',  
    case 'specspaceX',  opt.spec_space = 'X';
end

switch get(get(handles.panSaveIntermediateResults,'SelectedObject'),'Tag')
    case 'saveinterresYes',  
        opt.save_intermediate_results = 1;
        if ~isempty(handles.savevarname)
            opt.save_intermediate_results_varname = get(handles.savevarname, 'String');
        end
   % case 'rdbConfTest',  
    case 'saveinterresNo',  opt.save_intermediate_results = 0;
end

switch get(get(handles.panMap2Line,'SelectedObject'),'Tag')
    case 'rdbm2lY',  opt.map2line = 1;
   % case 'rdbConfTest',  
    case 'rdbm2lN',  opt.map2line = 0;
end

%opt.taliro_metric = get(handles.cmbTaliroMetric, 'string');
cmbTaliroMetricIdx = get(handles.cmbTaliroMetric, 'value');
cmbTaliroMetricData = get(handles.cmbTaliroMetric, 'String');
opt.taliro_metric = cmbTaliroMetricData{cmbTaliroMetricIdx};

opt.SampTime = str2double(get(handles.txtSampTime, 'string'));
opt.RobustnessOffset = get(handles.txtRobOffset, 'string');
opt.rob_scale = str2double(get(handles.txtRobScale, 'string'));
opt.loc_traj = get(handles.txtLocTrace, 'string');
opt.seed = str2double(get(handles.txtSeed, 'string'));
opt.dim_proj = get(handles.txtDimProj, 'string');
opt.taliro_undersampling_factor = str2double(get(handles.txtUndersamplingFactor, 'string'));
opt.optim_params.n_tests = str2double(get(handles.txtSAnTests, 'string'));
% opt.optim_params.n_tests = str2double(get(handles.txtCEnTests, 'string'));
% opt.optim_params.num_subdivs = str2double(get(handles.txtCENumSubdivs, 'string'));
% opt.optim_params.num_iteration = str2double(get(handles.txtCENumIter, 'string'));
% opt.optim_params.tilt_divisor = str2double(get(handles.txtCETilt, 'string'));


init_cond_data = get(handles.tblInitCond,'Data');
if ~isempty(cell2mat(init_cond_data))
    init_cond = cellfun(@str2num,init_cond_data);
else
    init_cond = [];
end

input_range_data = get(handles.tblInputs,'Data');
tempInpRange = zeros(size(input_range_data,1),1);
for ii = 1:size(input_range_data,1)
    if isempty(cell2mat(input_range_data(ii,:)));
        tempInpRange(ii) = 0;
    else
        tempInpRange(ii) = 1;
    end
end

if any(tempInpRange)
    input_range = cellfun(@str2num,input_range_data(find(tempInpRange==1),1:2));
    opt.interpolationtype = transpose(input_range_data(find(tempInpRange==1),4));
    cp_array = cellfun(@str2num,input_range_data(find(tempInpRange==1),3));
else
    input_range = [];
end

preds_data = get(handles.tblPredSettings,'Data');
tempPredsData = zeros(size(preds_data,1),1);
for ii = 1:size(tempPredsData,1)
    if isempty(preds_data{ii});
        tempPredsData(ii) = 0;
    else
        tempPredsData(ii) = 1;
    end
end

if any(tempPredsData) 
    idx = find(tempPredsData==1);
    for ii = 1:size(idx,1)
        preds(idx(ii)).str = preds_data{idx(ii),1};
        
        if isa(preds_data{idx(ii),2},'numeric')
            preds(idx(ii)).A = preds_data{idx(ii),2};
        else
            preds(idx(ii)).A = str2num(preds_data{idx(ii),2});
        end
                
        if isa(preds_data{idx(ii),3},'numeric')
            preds(idx(ii)).b = preds_data{idx(ii),3};
        else
            preds(idx(ii)).b = str2num(preds_data{idx(ii),3});
        end
        
        if isa(preds_data{idx(ii),4},'numeric')
            preds(idx(ii)).loc = (preds_data{idx(ii),4});
        else
            preds(idx(ii)).loc = str2num(preds_data{idx(ii),4});
        end
        
    end
else

end

model_data = get(handles.txtModelOne, 'string');
idx = strfind(model_data,'.mdl');
model = model_data(1:idx-1);


time = str2double(get(handles.txtSimTime, 'string'));
if isnan(time)
    set(handles.txtSimTime, 'BackgroundColor','Red');
    error('S-TaLiRo: Simulation time cannot be NaN');
end

phi = get(handles.txtSpec, 'string');

set(handles.txtResults,'String',' ');
set(handles.txtResults,'String','Simulations Running...'); 
set(handles.txtResults,'Visible','on'); 

[results history] = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);

set(handles.txtResults,'String','Simulations Complete. See the results and history structures.'); 




% --- Executes on button press in mtlSpecButton.
function mtlSpecButton_Callback(hObject, eventdata, handles)
% hObject    handle to mtlSpecButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[stat cmdout] = system('"C:/Program Files (x86)/TemporalGUI/TemporalGUI.exe"');

pathToDesktop = winqueryreg('HKEY_CURRENT_USER', 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'Desktop');

fid = fopen([pathToDesktop '\tempFormulaFile.txt']);

phi = fgetl(fid);


fclose(fid);

delete([pathToDesktop '\tempFormulaFile.txt']);

[match,noMatch] = regexp(phi, '\s\w*(<|>)\w*\s','match','split');

trimedStr = strtrim(match);

[sign predAndVal] = regexp(trimedStr, '\w*','split', 'match');

tableData = get(handles.tblPredSettings,'Data');

for ii=1:size(sign,2)
    tableData{ii,1} = char(predAndVal{ii}(1));
    
    if strcmp(sign{ii}(2),'<')
        aMat = zeros(1,size(sign,2));
        aMat(1,ii) = 1;
        tableData{ii,2} = mat2str(aMat);
        tableData{ii,3} = cellfun(@(x)str2double(x), predAndVal{ii}(2));
    elseif strcmp(sign{ii}(2),'>')
        aMat = zeros(1,size(sign,2));
        aMat(1,ii) = -1;
        tableData{ii,2} = mat2str(aMat);
        tableData{ii,3} = cellfun(@(x)str2double(x), strcat('-',predAndVal{ii}(2)));
    end
    
end

set(handles.tblPredSettings,'Data',tableData);

[gd bd ] =regexp(phi,'(<|>)[0-9]+','split','match');

phi_tt = strtrim(gd);
phi = [phi_tt{:}];

phi_f = strrep(phi, 'F', '<>')
phi_g = strrep(phi_f, 'G', '[]')

set(handles.txtSpec,'String',phi_g);
 


% --- Executes on button press in btnIncPreds.
function btnIncPreds_Callback(hObject, eventdata, handles)
% hObject    handle to btnIncPreds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(handles.tblPredSettings,'Data');
sz = size(tableData,1);
tableData{sz+1,1} = [];
tableData{sz+1,2} = [];
set(handles.tblPredSettings,'Data',tableData)



% --- Executes on button press in btnDecPreds.
function btnDecPreds_Callback(hObject, eventdata, handles)
% hObject    handle to btnDecPreds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tableData = get(handles.tblPredSettings,'Data');
sz = size(tableData,1);
tableData(sz,:) = [];
set(handles.tblPredSettings,'Data',tableData)
