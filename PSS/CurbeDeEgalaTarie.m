function varargout = guidetemplate0(varargin)
% GUIDETEMPLATE0 M-file for guidetemplate0.fig
%      GUIDETEMPLATE0, by itself, creates a new GUIDETEMPLATE0 or raises the existing
%      singleton*.
%
%      H = GUIDETEMPLATE0 returns the handle to a new GUIDETEMPLATE0 or the handle to
%      the existing singleton*.
%
%      GUIDETEMPLATE0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDETEMPLATE0.M with the given input arguments.
%
%      GUIDETEMPLATE0('Property','Value',...) creates a new GUIDETEMPLATE0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guidetemplate0_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guidetemplate0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help guidetemplate0

% Last Modified by GUIDE v2.5 14-Nov-2022 00:00:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guidetemplate0_OpeningFcn, ...
                   'gui_OutputFcn',  @guidetemplate0_OutputFcn, ...
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


% --- Executes just before guidetemplate0 is made visible.
function guidetemplate0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guidetemplate0 (see VARARGIN)

% Choose default command line output for guidetemplate0
handles.output = hObject;
handles.LdB = 0;
handles.LRef = -35; %nivelul in dBSPL pentru semnalul de referinta
                    %0 dB - corespunde amplitudinii 1 (cel mai mare nivel in dB)
                    %-Inf - corespunde amplitudinii 0 (cel mai mic nivel in dB) 
handles.fs = 48000; %frecventa de esantionare
handles.contor = 0; %contorizez numarul de trials la o anumita frecventa
handles.durata = 0.5; %[s] durata semnalelor de test


delete(handles.axes1)
handles.axes1 = axes('position',[0.4 0.43 0.5 0.55]);
plot([1 50],[-35 -35], '--r'),grid on, axis([1 50 -100 30]),zoom on;

% delete(handles.axes2)
% handles.axes2 = axes('position',[0.3 0.05 0.6 0.25]);
% semilogx([],[]),grid on, axis([1 16000 0 100]),zoom on;

% contents = get(hObject,'String');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guidetemplate0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guidetemplate0_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in plus8Btn.
function plus8Btn_Callback(hObject, eventdata, handles)
% hObject    handle to plus8Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%generare semnal de test
f0 = handles.FrecvTest;
L = handles.LdB+8;
printflag = 0;
x=tone(f0,handles.fs,L,handles.durata,printflag);

%generare semnal de referinta
f0 = 1000;
L = handles.LRef;
printflag = 0;
y=tone(f0,handles.fs,L,handles.durata,printflag);

%concatenarea semnale
pauza = 0.2;%[s]
Npauza = floor(pauza*handles.fs);
z=[x zeros(1,Npauza) y];

%Auditie semnale
sound(z,handles.fs);

% %Salvare semnale pe disc
nume = ['N' num2str(handles.contor+1) '_T_' num2str(handles.LdB+8) 'dB_R_' num2str(handles.LRef) 'dB.wav'];
audiowrite(nume, z,handles.fs)

%actualizare nivel&numar de trials
handles.LdB=handles.LdB+8;
handles.contor=handles.contor+1;

%Afisare pe grafic a nivelului audiat
axes(handles.axes1);
zoom on;
hold on
plot(handles.contor,handles.LdB,'xr'),grid on, axis([1 50 -100 30]),zoom on;
hold off

guidata(hObject, handles);

% --- Executes on button press in minus8Btn.
function minus8Btn_Callback(hObject, eventdata, handles)
% hObject    handle to minus8Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%generare semnal de test

f0 = handles.FrecvTest;
L = handles.LdB-8;
printflag = 0;
x=tone(f0,handles.fs,L,handles.durata,printflag);

%generare semnal de referinta
f0 = 1000;
L = handles.LRef;
printflag = 0;
y=tone(f0,handles.fs,L,handles.durata,printflag);

%concatenarea semnale
pauza = 0.2;%[s]
Npauza = floor(pauza*handles.fs);
z=[x zeros(1,Npauza) y];

%Auditie semnale
sound(z,handles.fs);

% %Salvare semnale pe disc
nume = ['N' num2str(handles.contor+1) '_T_' num2str(handles.LdB-8) 'dB_R_' num2str(handles.LRef) 'dB.wav'];
audiowrite(nume, z,handles.fs)

%actualizare nivel&numar de trials
handles.LdB=handles.LdB-8;
handles.contor=handles.contor+1;

%Afisare pe grafic a nivelului audiat
axes(handles.axes1);
zoom on;
hold on
plot(handles.contor,handles.LdB,'db'),grid on, axis([1 50 -100 30]),zoom on;
hold off

guidata(hObject, handles);



% --- Executes on button press in plus4Btn.
function plus4Btn_Callback(hObject, eventdata, handles)
% hObject    handle to plus4Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f0 = handles.FrecvTest;
L = handles.LdB+4;
printflag = 0;
x=tone(f0,handles.fs,L,handles.durata,printflag);

%generare semnal de referinta
f0 = 1000;
L = handles.LRef;
printflag = 0;
y=tone(f0,handles.fs,L,handles.durata,printflag);

%concatenarea semnale
pauza = 0.2;%[s]
Npauza = floor(pauza*handles.fs);
z=[x zeros(1,Npauza) y];

%Auditie semnale
sound(z,handles.fs);

% %Salvare semnale pe disc
nume = ['N' num2str(handles.contor+1) '_T_' num2str(handles.LdB+4) 'dB_R_' num2str(handles.LRef) 'dB.wav'];
audiowrite(nume,z,handles.fs)

%actualizare nivel&numar de trials
handles.LdB=handles.LdB+4;
handles.contor=handles.contor+1;

%Afisare pe grafic a nivelului audiat
axes(handles.axes1);
zoom on;
hold on
plot(handles.contor,handles.LdB,'xr'),grid on, axis([1 50 -100 30]),zoom on;
hold off

guidata(hObject, handles);

% --- Executes on button press in minus4Btn.
function minus4Btn_Callback(hObject, eventdata, handles)
% hObject    handle to minus4Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f0 = handles.FrecvTest;
L = handles.LdB-4;
printflag = 0;
x=tone(f0,handles.fs,L,handles.durata,printflag);

%generare semnal de referinta
f0 = 1000;
L = handles.LRef;
printflag = 0;
y=tone(f0,handles.fs,L,handles.durata,printflag);

%concatenarea semnale
pauza = 0.2;%[s]
Npauza = floor(pauza*handles.fs);
z=[x zeros(1,Npauza) y];

%Auditie semnale
sound(z,handles.fs);

% %Salvare semnale pe disc
nume = ['N' num2str(handles.contor+1) '_T_' num2str(handles.LdB-4) 'dB_R_' num2str(handles.LRef) 'dB.wav'];
audiowrite(nume,z,handles.fs)

%actualizare nivel&numar de trials
handles.LdB=handles.LdB-4;
handles.contor=handles.contor+1;

%Afisare pe grafic a nivelului audiat
axes(handles.axes1);
zoom on;
hold on
plot(handles.contor,handles.LdB,'db'),grid on, axis([1 50 -100 30]),zoom on;
hold off

guidata(hObject, handles);


% --- Executes on button press in plus2Btn.
function plus2Btn_Callback(hObject, eventdata, handles)
% hObject    handle to plus2Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f0 = handles.FrecvTest;
L = handles.LdB+2;
printflag = 0;
x=tone(f0,handles.fs,L,handles.durata,printflag);

%generare semnal de referinta
f0 = 1000;
L = handles.LRef;
printflag = 0;
y=tone(f0,handles.fs,L,handles.durata,printflag);

%concatenarea semnale
pauza = 0.2;%[s]
Npauza = floor(pauza*handles.fs);
z=[x zeros(1,Npauza) y];

%Auditie semnale
sound(z,handles.fs);

% %Salvare semnale pe disc
nume = ['N' num2str(handles.contor+1) '_T_' num2str(handles.LdB+2) 'dB_R_' num2str(handles.LRef) 'dB.wav'];
audiowrite(nume,z,handles.fs)

%actualizare nivel&numar de trials
handles.LdB=handles.LdB+2;
handles.contor=handles.contor+1;

%Afisare pe grafic a nivelului audiat
axes(handles.axes1);
zoom on;
hold on
plot(handles.contor,handles.LdB,'xr'),grid on, axis([1 50 -100 30]),zoom on;
hold off

guidata(hObject, handles);


% --- Executes on button press in minus2Btn.
function minus2Btn_Callback(hObject, eventdata, handles)
% hObject    handle to minus2Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f0 = handles.FrecvTest;
L = handles.LdB-2;
printflag = 0;
x=tone(f0,handles.fs,L,handles.durata,printflag);

%generare semnal de referinta
f0 = 1000;
L = handles.LRef;
printflag = 0;
y=tone(f0,handles.fs,L,handles.durata,printflag);

%concatenarea semnale
pauza = 0.2;%[s]
Npauza = floor(pauza*handles.fs);
z=[x zeros(1,Npauza) y];

%Auditie semnale
sound(z,handles.fs);

% %Salvare semnale pe disc
nume = ['N' num2str(handles.contor+1) '_T_' num2str(handles.LdB-2) 'dB_R_' num2str(handles.LRef) 'dB.wav'];
audiowrite(nume, z,handles.fs)

%actualizare nivel&numar de trials
handles.LdB=handles.LdB-2;
handles.contor=handles.contor+1;

%Afisare pe grafic a nivelului audiat
axes(handles.axes1);
zoom on;
hold on
plot(handles.contor,handles.LdB,'db'),grid on, axis([1 50 -100 30]),zoom on;
hold off

guidata(hObject, handles);


% --- Executes on button press in CalibBtn.
function CalibBtn_Callback(hObject, eventdata, handles)
% hObject    handle to CalibBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f0=1000;%[Hz]
durata = 4;%[s]
printFlag = 0;
x=tone(f0,handles.fs,handles.LRef,durata,printFlag);
handles.player = audioplayer(x, handles.fs);
play(handles.player)

set(handles.StopRef, 'Enable', 'on')
set(handles.FrecvTestPopUp, 'Enable', 'on')

guidata(hObject, handles);

% --- Executes on selection change in FrecvTestPopUp.
function FrecvTestPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to FrecvTestPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FrecvTestPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FrecvTestPopUp

handles.contor = 0; %resetez contorul care-mi da numarul de fiecare data cand selectez o noua frecventa
delete(handles.axes1)
handles.axes1 = axes('position',[0.4 0.43 0.5 0.55]);
plot([1 50],[-35 -35], '--r'),grid on, axis([1 50 -100 30]),zoom on;

contents = get(hObject,'String');

handles.FrecvTest = str2num(contents{get(hObject,'Value')});
if (handles.FrecvTest == 125)||(handles.FrecvTest == 160)||(handles.FrecvTest == 200)||...
   (handles.FrecvTest == 8000)||(handles.FrecvTest == 10000)||(handles.FrecvTest == 12500)
   
   handles.LdB=handles.LRef + 38;%[dBSPL] %nivelul de la care plec fata de referinta pt frecventa aleasa
end

if (handles.FrecvTest == 315)||(handles.FrecvTest == 400)||(handles.FrecvTest == 500)||...
   (handles.FrecvTest == 630)||(handles.FrecvTest == 800)||(handles.FrecvTest == 1000)||...
   (handles.FrecvTest == 1250)||(handles.FrecvTest == 1600)||(handles.FrecvTest == 6300)
   
%    handles.LdB=handles.LRef + 33;%[dBSPL] %nivelul de la care plec fata de referinta pt frecventa aleasa
  handles.LdB=handles.LRef + 38;%[dBSPL] %nivelul de la care plec fata de referinta pt frecventa aleasa
end

if (handles.FrecvTest == 2000)||(handles.FrecvTest == 2500)||(handles.FrecvTest == 3150)||...
   (handles.FrecvTest == 4000)||(handles.FrecvTest == 5000)
   
%    handles.LdB=handles.LRef + 28%[dBSPL] %nivelul de la care plec fata de referinta pt frecventa aleasa
  handles.LdB=handles.LRef + 38;%[dBSPL] %nivelul de la care plec fata de referinta pt frecventa aleasa
end

axes(handles.axes1)
xlabel(['Nr auditiei pentru frecventa de test curenta ' num2str(handles.FrecvTest) ' Hz'])
ylabel('Nivelul relativ in dB')

% handles.LdB 

set(handles.plus8Btn, 'Enable', 'on');
set(handles.plus4Btn, 'Enable', 'on');
set(handles.plus2Btn, 'Enable', 'on');
set(handles.minus8Btn, 'Enable', 'on');
set(handles.minus4Btn, 'Enable', 'on');
set(handles.minus2Btn, 'Enable', 'on');

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FrecvTestPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrecvTestPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in FoniPopUp.
function FoniPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to FoniPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FoniPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FoniPopUp
handles.ResetFlag = 0; %resetez flag-ul pentru stergerea graficului pentru curba izofona

set(handles.CalibBtn,'Enable','on');
contents = get(hObject,'String'); %cell array - contine lista de string-uri din PopUp list
handles.Lfoni = contents{get(hObject,'Value')}; %intoarce valoarea selectata de utilizator din lista pe care o are la dispozitie

% if handles.Lfoni == '30'
%     handles.LRef =0;
% end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FoniPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FoniPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in StopRef.
function StopRef_Callback(hObject, eventdata, handles)
% hObject    handle to StopRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stop(handles.player);

guidata(hObject, handles);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

%citesc frecventa curenta pentru care s-a determinat nivelul
f0 = handles.FrecvTest;

%citesc nivelul introdus de la tastura 
L = str2double(get(hObject,'String'));

%Afisare pe grafic a nivelului determinat
axes(handles.axes2);
zoom on;
hold on
semilogx(f0, L, 'dB'),grid on,zoom on; axis([1 16000 0 100]),
hold off

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in ResetGraph.
function ResetGraph_Callback(hObject, eventdata, handles)
% hObject    handle to ResetGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ResetFlag = 1;
delete(handles.axes2)
handles.axes2 = axes('position',[0.3 0.05 0.6 0.25])
semilogx([],[]),grid on, axis([1 16000 0 100]),zoom on;



% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
