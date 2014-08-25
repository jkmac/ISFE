function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 19-Aug-2014 13:33:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
% Initialize GUI data, default values
handles.output = hObject;
handles.path = pwd;
handles.ffpath = strcat(handles.path,'/form_factors');
handles.qinit = 6;
handles.qfinal = 16;
handles.rmslow = 0;
handles.acu = -3;
handles.mean = 0.07;
handles.var = 0.03;
handles.sname = 'sample';
handles.chk = 1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in read_coord_file.
function read_coord_file_Callback(hObject, eventdata, handles)
% hObject    handle to read_coord_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = strcat(handles.path,'/*.txt');
[filename path] = uigetfile(tmp,'File Selector');
if path ~= 0
    fullpath = strcat(path,filename);
    handles.path = path;
    handles.path_coord=fullpath;
    set(hObject,'string','Loaded');
end
guidata(hObject, handles);

% --- Executes on button press in read_sq_file.
function read_sq_file_Callback(hObject, eventdata, handles)
% hObject    handle to read_sq_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = strcat(handles.path,'/*.dat');
[filename path] = uigetfile(tmp,'File Selector');
if path ~= 0
    fullpath = strcat(path,filename);
    handles.path = path;
    handles.path_sq=fullpath;
    set(hObject,'string','Loaded');
end
guidata(hObject, handles);


function q_init_Callback(hObject, eventdata, handles)
% hObject    handle to q_init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_init as text
%        str2double(get(hObject,'String')) returns contents of q_init as a double

user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
end
handles.qinit = user_entry;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function q_init_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_init (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end



function q_final_Callback(hObject, eventdata, handles)
% hObject    handle to q_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_final as text
%        str2double(get(hObject,'String')) returns contents of q_final as a double
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
end
handles.qfinal = user_entry;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function q_final_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_final (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end



function rms_low_Callback(hObject, eventdata, handles)
% hObject    handle to rms_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rms_low as text
%        str2double(get(hObject,'String')) returns contents of rms_low as a double
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
end
handles.rmslow = user_entry;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rms_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rms_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end



function accu_Callback(hObject, eventdata, handles)
% hObject    handle to accu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accu as text
%        str2double(get(hObject,'String')) returns contents of accu as a double
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
end
handles.acu = user_entry;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function accu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end



function mean_Callback(hObject, eventdata, handles)
% hObject    handle to mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean as text
%        str2double(get(hObject,'String')) returns contents of mean as a double
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
end
handles.mean = user_entry;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end



function variance_Callback(hObject, eventdata, handles)
% hObject    handle to variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variance as text
%        str2double(get(hObject,'String')) returns contents of variance as a double
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
	return
end
handles.var = user_entry;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function variance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end


function smp_name_Callback(hObject, eventdata, handles)
% hObject    handle to smp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smp_name as text
%        str2double(get(hObject,'String')) returns contents of smp_name as a double
user_entry = get(hObject, 'string');
handles.sname=user_entry;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function smp_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smp_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','green');
end

% --- Executes on button press in runfit.
function runfit_Callback(hObject, eventdata, handles)
% hObject    handle to runfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'string','Calculating...');
drawnow
[x,resnorm,residual,q,ffit,intra,x0,norm_sofq] = runfit(handles.qinit,.../
    handles.qfinal,handles.acu,handles.mean,handles.var, .../
    handles.path_coord,handles.path_sq,handles.ffpath, handles.sname, handles.chk);
set(hObject,'string','Finished');
drawnow
h = msgbox('Completed! Data saved in the working directory.', 'Success');
plot(handles.axes1,q,ffit,norm_sofq(:,1),norm_sofq(:,2),'-r')
title(handles.axes1,[' Fitting range, Q\in [', num2str(handles.qinit), ',', num2str(handles.qfinal), .../
    ']', ', TolFun = ', num2str(handles.acu), ', lb = ', num2str(handles.rmslow)])
legend(handles.axes1,'Fitted Intra-Struct-Factor F(Q)', 'Normalized Experimental SofQ')
axis(handles.axes1,[0 handles.qfinal -2.5 4]);

plot(handles.axes2,q, intra);
%title(['Mean = ', num2str(mean), ', Std = ', num2str(std)])
title(handles.axes2,'S(Q) - F(Q) Intermolecule structure factor')
axis(handles.axes2,[0 handles.qfinal -2.5 4]);

hist(handles.axes3,abs(x0(1:end-2)))
title(handles.axes3,['Gaussian initialization of RMS, ', 'Mean = ', .../
num2str(handles.mean), ', Std = ', num2str(handles.var)])

hist(handles.axes4,abs(x(1:end-2)))
title(handles.axes4,'Final distribution of RMS');


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
if (get(hObject,'Value') == get(hObject,'Max'))
	handles.chk=0;  %checked box, skip saving data to disk
else
	handles.chk=1;  %by default it's unchecked, save data to disk
end
guidata(hObject, handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
