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
function audiometru_OpeningFcn(hObject, ~, handles, varargin)
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
addpath(fullfile(fileparts(mfilename('fullpath')), 'matlab'));
mydata.pss = configuratie_izofona;
mydata.lastAudition = [];
set(mydata.playPush,'String','T + R');
setappdata(groot, 'PSS_audiometru', hObject);

for i=1:5
    for j=1:9
        mydata.m(i,j)=-100;
    end
end
guidata(hObject, mydata);


% --- Outputs from this function are returned to the command line.
function varargout = audiometru_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in phoniPop.
function phoniPop_Callback(~, ~, handles)
% hObject    handle to phoniPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns phoniPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from phoniPop
phoniList = get(handles.phoniPop, 'String');
phoniVal = get(handles.phoniPop, 'Value');
set(handles.nivelSlider, 'Value', str2double(phoniList{phoniVal}));
set(handles.nivelValText, 'String', phoniList{phoniVal});
set(handles.frecvPop, 'Value', 5);

% --- Executes during object creation, after setting all properties.
function phoniPop_CreateFcn(hObject, ~, ~)
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
function frecvPop_Callback(~, ~, ~)
% hObject    handle to frecvPop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns frecvPop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from frecvPop


% --- Executes during object creation, after setting all properties.
function frecvPop_CreateFcn(hObject, ~, ~)
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
function nivelSlider_Callback(hObject, ~, handles)
% hObject    handle to nivelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

pos = get(hObject, 'Value');
set(handles.nivelValText, 'String', pos);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nivelSlider_CreateFcn(hObject, ~, ~)
% hObject    handle to nivelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
set(hObject,'BackgroundColor',[.9 .9 .9]);


% --- Executes on button press in playPush.
function playPush_Callback(hObject, ~, handles)
% hObject    handle to playPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Fs = 48000;
fList = get(handles.frecvPop, 'String');
f = str2double(fList{get(handles.frecvPop, 'Value')});
L = get(handles.nivelSlider, 'Value');
rList = get(handles.phoniPop, 'String');
ref = str2double(rList{get(handles.phoniPop, 'Value')});
test = ton_izofona(f,L,Fs,0.5);
reference = ton_izofona(1000,ref,Fs,0.5);
player = audioplayer([test; zeros(round(.2*Fs),1); reference],Fs,16);
playblocking(player);
handles.lastAudition = struct('frequenta',f,'nivel',L,'referinta',ref);
guidata(hObject, handles);


% --- Executes on button press in PlayRefPush.
function PlayRefPush_Callback(~, ~, handles)
% hObject    handle to PlayRefPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Fs = 48000;
Llist = get(handles.phoniPop, 'String');
L = str2double(Llist{get(handles.phoniPop, 'Value')});
y = ton_izofona(1000,L,Fs,0.5);
player = audioplayer(y,Fs,16);
playblocking(player);


% --- Executes on button press in MemPush.
function MemPush_Callback(hObject, ~, handles)
% hObject    handle to MemPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = guidata(hObject);
niv = get(handles.nivelSlider, 'Value');
phoniList = get(handles.phoniPop, 'String');
refLev = str2double(phoniList{get(handles.phoniPop, 'Value')});
frecList = get(handles.frecvPop, 'String');
f = str2double(frecList{get(handles.frecvPop, 'Value')});
a = mydata.lastAudition;
if isempty(a) || a.frequenta~=f || a.referinta~=refLev || abs(a.nivel-niv)>1e-8
    errordlg('Ascultati perechea la nivelul curent inainte de memorare.','Comparatie necesara');
    return;
end
row = struct('frecventa_Hz',f,'nivel_program_dB',niv, ...
    'referinta_program_dB',refLev,'moment',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
mydata.pss.masuratori(end+1) = row;
i = round(refLev/10)+1; j = round(1+log2(f/62.5));
if i>=1 && i<=5 && j>=1 && j<=9, mydata.m(i,j)=niv; end
mydata.lastAudition = [];
guidata(hObject,mydata);
exporta_izofona(hObject,false);
% Pornire diferita pentru urmatoarea ajustare, fara modificarea referintei.
n = sum([mydata.pss.masuratori.frecventa_Hz]==f & ...
    [mydata.pss.masuratori.referinta_program_dB]==refLev);
nextLevel = min(get(handles.nivelSlider,'Max'), ...
    max(get(handles.nivelSlider,'Min'),niv+4*(-1)^n));
set(handles.nivelSlider,'Value',nextLevel);
set(handles.nivelValText,'String',num2str(nextLevel));
fprintf('Memorat: %g Hz, %g dB pe scala programului; repetarea %d.\n',f,niv,n);
