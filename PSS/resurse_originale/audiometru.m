function varargout = audiometru(varargin)
% AUDIOMETRU M-file for audiometru.fig
%      AUDIOMETRU, by itself, creates a new AUDIOMETRU or raises the existing
%      singleton*.
%
%      H = AUDIOMETRU returns the handle to a new AUDIOMETRU or the handle to
%      the existing singleton*.
%
%      AUDIOMETRU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUDIOMETRU.M with the given input arguments.
%
%      AUDIOMETRU('Property','Value',...) creates a new AUDIOMETRU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before audiometru_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to audiometru_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help audiometru

% Last Modified by GUIDE v2.5 26-Mar-2008 00:49:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @audiometru_OpeningFcn, ...
                   'gui_OutputFcn',  @audiometru_OutputFcn, ...
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


% --- Executes just before audiometru is made visible.
function audiometru_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to audiometru (see VARARGIN)

% Choose default command line output for audiometru
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes audiometru wait for user response (see UIRESUME)
% uiwait(handles.figure1);
mydata = guidata(hObject);

for i=1:5
    for j=1:9
        mydata.m(i,j)=-100;
    end
end
guidata(hObject, mydata);


% --- Outputs from this function are returned to the command line.
function varargout = audiometru_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on selection change in phoniPop.
function phoniPop_Callback(hObject, eventdata, handles)
% hObject    handle to phoniPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns phoniPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phoniPop
phoniList = get(handles.phoniPop, 'String');
phoniVal = get(handles.phoniPop, 'Value');
set(handles.nivelSlider, 'Value', str2num(phoniList{phoniVal}));
set(handles.nivelValText, 'String', phoniList{phoniVal});
set(handles.frecvPop, 'Value', 5);

% --- Executes during object creation, after setting all properties.
function phoniPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phoniPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in frecvPop.
function frecvPop_Callback(hObject, eventdata, handles)
% hObject    handle to frecvPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns frecvPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from frecvPop


% --- Executes during object creation, after setting all properties.
function frecvPop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frecvPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function nivelSlider_Callback(hObject, eventdata, handles)
% hObject    handle to nivelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

pos = get(hObject, 'Value');
set(handles.nivelValText, 'String', pos);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nivelSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nivelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in playPush.
function playPush_Callback(hObject, eventdata, handles)
% hObject    handle to playPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Fs = 96000;
fList  = get(handles.frecvPop, 'String');
fVal = get(handles.frecvPop, 'Value');
f = str2num(fList{fVal});
L  = get(handles.nivelSlider, 'Value');
A  = amplgen(L);

y = singen(A, f, Fs, 1);
sound(y,Fs,16);

guidata(hObject, handles);





% --- Executes on button press in PlayRefPush.
function PlayRefPush_Callback(hObject, eventdata, handles)
% hObject    handle to PlayRefPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Fs = 96000;

Llist  = get(handles.phoniPop, 'String');
LVal = get(handles.phoniPop, 'Value');
L = str2num(Llist{LVal});

A  = amplgen(L);

y = singen(A, 1000, Fs, 1);
sound(y,Fs,16);

guidata(hObject, handles);


% --- Executes on button press in MemPush.
function MemPush_Callback(hObject, eventdata, handles)
% hObject    handle to MemPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);

niv = get(handles.nivelSlider, 'Value');

phoniList = get(handles.phoniPop, 'String');
phoniVal = get(handles.phoniPop, 'Value');
refLev = str2num(phoniList{phoniVal});

frecList = get(handles.frecvPop, 'String');
frecVal = get(handles.frecvPop, 'Value');
f = str2num(frecList{frecVal});

i=refLev/10 + 1;
j=1 + log2(f/62.5);

mydata.m(i,j)=niv;
guidata(hObject, mydata);


for i=1:length(mydata.m(:, 1))
    p=1;
    for k =1:length(mydata.m(1,:))
        if mydata.m(i,k) ~= -100;
            y(i,p) = mydata.m(i,k);
            x(i,p) = 62.5*(2^(k-1));
            p = p+1;
        end
    end
end


axes(handles.axes1);
semilogx(x',y','o-'),grid, axis([62.5 16000 -30 70]);

