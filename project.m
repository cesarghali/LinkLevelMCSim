function varargout = project(varargin)
% PROJECT M-file for project.fig
%      PROJECT, by itself, creates a new PROJECT or raises the existing
%      singleton*.
%
%      H = PROJECT returns the handle to a new PROJECT or the handle to
%      the existing singleton*.
%
%      PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT.M with the given input arguments.
%
%      PROJECT('Property','Value',...) creates a new PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before project_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to project_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help project

% Last Modified by GUIDE v2.5 14-Jan-2009 23:13:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_OpeningFcn, ...
                   'gui_OutputFcn',  @project_OutputFcn, ...
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


% --- Executes just before project is made visible.
function project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project (see VARARGIN)

% Choose default command line output for project
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes project wait for user response (see UIRESUME)
% uiwait(handles.frmSimulation);


% --- Outputs from this function are returned to the command line.
function varargout = project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in btnRunSimulation.
function btnRunSimulation_Callback(hObject, eventdata, handles)
% hObject    handle to btnRunSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global legendH

%Clear old variables
clear modType;
clear M;
clear hMod;
clear hDemod;
clear chanType;
clear ts;
clear fd;
clear memories;
clear msgLength;
clear minNumOfErrs;
clear targetBER;
clear error;
clear startTime;
clear results;
clear elapsedTime;
clear bestCode;


%Setting up the modulator and demodulator
modType = 'psk'; % 'dpsk' or 'psk'
M = 2;
if strcmp(modType, 'dpsk')
    hMod = modem.dpskmod('M', M);
    hDemod = modem.dpskdemod(hMod);
elseif strcmp(modType, 'psk')
    hMod = modem.pskmod('M', M);
    hDemod = modem.pskdemod(hMod);
end


%Reading Channel Properties from the GUI
if get(handles.cmbChannelType, 'Value') == 1
    chanType = 'nofading'; % 'fading' or 'nofading'
else
    chanType = 'fading'; % 'fading' or 'nofading'    
end
ts = 0;
fd = 0;
if strcmp(chanType, 'fading')
    ts = str2double(get(handles.txtTs, 'String'));
    if isnan(ts)
        errordlg('You must enter a numeric value as a ts', 'Bad Input', 'modal')
        return
    end

    fd = str2double(get(handles.lblFd, 'String'));
    if isnan(fd)
        errordlg('You must enter a numeric value as velocity', 'Bad Input', 'modal')
        return
    end
end
CSIType = get(handles.cmbCSIType, 'Value');


%Reading En/Decoder Properties from the GUI
codeRate = get(handles.cmbCodeRate, 'Value') + 1;
memories = get(handles.cmbMemories, 'Value') + 1;
if get(handles.cmbDecodingType, 'Value') == 1
    decodingType = 'hard';
else
    decodingType = 'soft';
end


%Reading System Properties from the GUI
msgLength = str2double(get(handles.txtMessageLength, 'String'));
if isnan(msgLength)
	errordlg('You must enter a numeric value as a message length', 'Bad Input', 'modal')
	return
end
minNumOfErrs = str2double(get(handles.txtMinNumOfErrs, 'String'));
if isnan(minNumOfErrs)
    errordlg('You must enter a numeric value as a minimum number of errors', 'Bad Input', 'modal')
	return
end
targetBER = str2double(get(handles.txtTargetBER, 'String'));
if isnan(targetBER)
	errordlg('You must enter a numeric value as a target BER', 'Bad Input', 'modal')
	return
end
interleaverMode = get(handles.cmbInterleaverMode, 'Value');
randomSeed = 0;
if interleaverMode == 3
    randomSeed = rand * 10000;
end


%Reading System Properties from the GUI
if get(handles.rdoHoldOff, 'Value') == 1
    holdOffOn = 'off';
else
    holdOffOn = 'on';
end
if get(handles.cmbCurveShape, 'Value') == 1
    curveShape = 'r*';
elseif get(handles.cmbCurveShape, 'Value') == 2
    curveShape = 'r+';
elseif get(handles.cmbCurveShape, 'Value') == 3
    curveShape = 'rx';
elseif get(handles.cmbCurveShape, 'Value') == 4
    curveShape = 'rs';
elseif get(handles.cmbCurveShape, 'Value') == 5
    curveShape = 'rd';
elseif get(handles.cmbCurveShape, 'Value') == 6
    curveShape = 'rp';
elseif get(handles.cmbCurveShape, 'Value') == 7
    curveShape = 'rh';
end


%Run the simulation but first check if it is demonstration mode or
%automation mode to call the appropriate simulation function.
error = 0;
if (get(handles.chkDemonstration, 'Value') == get(handles.chkDemonstration, 'Max'))
    %Clear outs variables
    clear out1;
    clear out2;
    clear out3;

    out1 = str2double(get(handles.txtOut1, 'String'));
    if isnan(out1)
        errordlg('You must enter a numeric value as an Out 1', 'Bad Input', 'modal')
        return
    end
    out2 = str2double(get(handles.txtOut2, 'String'));
    if isnan(out2)
        errordlg('You must enter a numeric value as an Out 2', 'Bad Input', 'modal')
        return
    end
    if get(handles.cmbCodeRate, 'Value') == 2
        out3 = str2double(get(handles.txtOut3, 'String'));
        if isnan(out3)
            errordlg('You must enter a numeric value as an Out 3', 'Bad Input', 'modal')
            return
        end    
    end
    
    if get(handles.cmbCodeRate, 'Value') == 1
        outs = [out1 out2];
    elseif get(handles.cmbCodeRate, 'Value') == 2
        outs = [out1 out2 out3];
    end

    EnDisableProperties(handles, 'off');
    drawnow;
    
    %Start the simulation in Demonstration mode
    startTime = clock;
    [results, error] = demonstration(handles, 1, 1, hMod, hDemod, chanType, ts, fd, CSIType, codeRate, memories, decodingType, msgLength, ...
        minNumOfErrs, targetBER, interleaverMode, randomSeed, outs);
    elapsedTime = etime(clock, startTime);
    
    EnDisableProperties(handles, 'on');
    
    %Show appropriate message in case there was a simulation error
    if error == 1
        errordlg('Generator describes code of less than specified constraint length.', 'Bad Trellis', 'modal')
        return
    elseif error == 2
        errordlg('The used trellis corresponds to a convolutional code that causes catastrophic error propagation.', 'Catastrophic Trellis', 'modal')
        return
    elseif error == 3
        set(handles.btnRunSimulation, 'Visible', 'on');
        set(handles.btnStopSimulation, 'Visible', 'off');

        return
    end
else
    EnDisableProperties(handles, 'off');
    drawnow;

    %Start the simulation in the Automation mode
    startTime = clock;
    [results, error] = automation(handles, hMod, hDemod, chanType, ts, fd, CSIType, codeRate, memories, decodingType, msgLength, ...
        minNumOfErrs, targetBER, interleaverMode, randomSeed); 
    elapsedTime = etime(clock, startTime);
    
    EnDisableProperties(handles, 'on');
    
    if error == 3
        set(handles.btnRunSimulation, 'Visible', 'on');
        set(handles.btnStopSimulation, 'Visible', 'off');
        return
    end
end


%Get the best Encoder among all of the encoders
bestCode = results(1);
for i = 2:length(results)
    if results(i).EbNoValue < bestCode.EbNoValue
        bestCode = results(i);
    end
end


% Calculate theoratical BER
if strcmp(chanType, 'nofading')
    BERtheory = berawgn(bestCode.SNR, modType, M, 'nondiff');
elseif strcmp(chanType, 'fading')
    BERtheory = berfading(bestCode.SNR, modType, M, 1);
end


% Plot BER results.
if strcmp(holdOffOn, 'off')
    hold off;
elseif strcmp(holdOffOn, 'on')
    hold on;
end
semilogy(handles.axResults, bestCode.SNR, BERtheory, 'bo-', bestCode.SNR, bestCode.BER, curveShape);
hold on;
try
    berfit(bestCode.SNR, bestCode.BER);
catch
    semilogy(handles.axResults, bestCode.SNR, bestCode.BER, curveShape);    
end
hold off;

% Set Labels and Title
lebals = 'Theoretical BER (uncoded)';
strTemp = 'Empirical BER (coded';
if get(handles.cmbChannelType, 'Value') == 1
    strTemp = strcat(strTemp, ', AWGN');
elseif get(handles.cmbChannelType, 'Value') == 2
    strTemp = strcat(strTemp, ', Fading');    
end
if get(handles.cmbChannelType, 'Value') == 2
    if get(handles.cmbCSIType, 'Value') == 1
        strTemp = strcat(strTemp, ', no CSI');
    elseif get(handles.cmbCSIType, 'Value') == 2
        strTemp = strcat(strTemp, ', CSI');    
    end
end
if get(handles.cmbInterleaverMode, 'Value') == 1
    strTemp = strcat(strTemp, ', no Inter.');
elseif get(handles.cmbInterleaverMode, 'Value') == 2
    strTemp = strcat(strTemp, ', Block Inter');
elseif get(handles.cmbInterleaverMode, 'Value') == 3
    strTemp = strcat(strTemp, ', Ps-Rnd Inter.');
end
strTemp = strcat(strTemp, ')');
%legend(handles.axResults, 'Theoretical BER (uncoded)', 'Empirical BER (coded)', 'Location', 'Southwest');
if strcmp(holdOffOn, 'off')
    legendH = legend(handles.axResults, [lebals; {strTemp}], 'Location', 'Southwest');
elseif strcmp(holdOffOn, 'on')
    %legendH = get(handles.lblLegendHandle, 'String');
    try
        previousLegend = get(legendH, 'String');
        legendH = legend(handles.axResults, [previousLegend; {strTemp}], 'Location', 'Southwest');
    catch
        legendH = legend(handles.axResults, [lebals; {strTemp}], 'Location', 'Southwest');
    end
end
xlabel(handles.axResults, 'SNR (dB)');
ylabel(handles.axResults, 'BER');
if strcmp(modType, 'dpsk') && strcmp(chanType, 'nofading')
    title(handles.axResults, 'Binary DPSK over AWGN Channel');
elseif strcmp(modType, 'dpsk') && strcmp(chanType, 'fading')
    title(handles.axResults, 'Binary DPSK over Rayleigh Fading Channel');
elseif strcmp(modType, 'psk') && strcmp(chanType, 'nofading')
    title(handles.axResults, 'Binary PSK over AWGN Channel');
elseif strcmp(modType, 'psk') && strcmp(chanType, 'fading')
    title(handles.axResults, 'Binary PSK over Rayleigh Fading Channel');
end
set(handles.axResults, 'XGrid', 'on');
set(handles.axResults, 'YGrid', 'on');


%Write the results on the GUI
set(handles.lblOut1, 'String', bestCode.out1);
set(handles.lblOut2, 'String', bestCode.out2);
if codeRate == 3
    set(handles.lblOut3, 'String', bestCode.out3);
end
set(handles.lblBestSNR, 'String', bestCode.EbNoValue);
set(handles.lblTime, 'String', elapsedTime);
return



%This function disable all teh options when the simulation is running and
%re-enable then after the it finishes
function EnDisableProperties(handles, value)
set(handles.lblChannelType, 'Enable', value);
set(handles.cmbChannelType, 'Enable', value);
if (strcmp(value, 'on')) && (get(handles.cmbChannelType, 'Value') == 2)
    set(handles.lblTs, 'Enable', 'on');
    set(handles.txtTs, 'Enable', 'on');
    set(handles.lblV, 'Enable', 'on');
    set(handles.txtV, 'Enable', 'on');
    set(handles.lblFdLabel, 'Enable', 'on');
    set(handles.lblFd, 'Enable', 'on');
    set(handles.lblCSIType, 'Enable', 'on');
    set(handles.cmbCSIType, 'Enable', 'on');
else
    set(handles.lblTs, 'Enable', 'off');
    set(handles.txtTs, 'Enable', 'off');
    set(handles.lblV, 'Enable', 'off');
    set(handles.txtV, 'Enable', 'off');
    set(handles.lblFdLabel, 'Enable', 'off');
    set(handles.lblFd, 'Enable', 'off');
    set(handles.lblCSIType, 'Enable', 'off');
    set(handles.cmbCSIType, 'Enable', 'off');
end
set(handles.lblCodeRate, 'Enable', value);
set(handles.cmbCodeRate, 'Enable', value);
set(handles.lblMemories, 'Enable', value);
set(handles.cmbMemories, 'Enable', value);
set(handles.lblDecodingType, 'Enable', value);
set(handles.cmbDecodingType, 'Enable', value);
set(handles.lblMessageLength, 'Enable', value);
set(handles.txtMessageLength, 'Enable', value);
set(handles.lblMinNumOfErrs, 'Enable', value);
set(handles.txtMinNumOfErrs, 'Enable', value);
set(handles.lblTargetBER, 'Enable', value);
set(handles.txtTargetBER, 'Enable', value);
set(handles.lblInterleaverMode, 'Enable', value);
set(handles.cmbInterleaverMode, 'Enable', value);
set(handles.rdoHoldOff, 'Enable', value);
set(handles.rdoHoldOn, 'Enable', value);
set(handles.lblCurveShape, 'Enable', value);
set(handles.cmbCurveShape, 'Enable', value);
set(handles.btnShowCodingScheme, 'Enable', value);
set(handles.btnShowCurve, 'Enable', value);
set(handles.chkDemonstration, 'Enable', value);
if (strcmp(value, 'on')) && (get(handles.chkDemonstration, 'Value') == get(handles.chkDemonstration, 'Max'))
    set(handles.lblOut1lbl, 'Enable', 'on');
    set(handles.txtOut1, 'Enable', 'on');
    set(handles.lblOut2lbl, 'Enable', 'on');
    set(handles.txtOut2, 'Enable', 'on');
    if get(handles.cmbCodeRate, 'Value') == 2
        set(handles.lblOut3lbl, 'Enable', 'on');
        set(handles.txtOut3, 'Enable', 'on');
    end
else
    set(handles.lblOut1lbl, 'Enable', 'off');
    set(handles.txtOut1, 'Enable', 'off');
    set(handles.lblOut2lbl, 'Enable', 'off');
    set(handles.txtOut2, 'Enable', 'off');
    set(handles.lblOut3lbl, 'Enable', 'off');
    set(handles.txtOut3, 'Enable', 'off');
end
if strcmp(value, 'on')
    set(handles.btnRunSimulation, 'Visible', 'on');
    set(handles.btnStopSimulation, 'Visible', 'off');

    set(handles.btnShowCodingScheme, 'Enable', 'on');
    set(handles.btnShowCurve, 'Enable', 'on');
    
    set(handles.lblProgressLabel, 'Visible', 'off');
    set(handles.lblProgress, 'Visible', 'off');
end


if strcmp(value, 'off')
    set(handles.btnStopSimulation, 'Visible', 'on');
    set(handles.btnRunSimulation, 'Visible', 'off');

    set(handles.btnShowCodingScheme, 'Visible', 'on');
    set(handles.btnShowCurve, 'Visible', 'off');
    set(handles.axResults, 'Visible', 'on');
    set(handles.pnlCodingScheme, 'Visible', 'off');
    
    set(handles.lblProgressLabel, 'Visible', 'on');
    set(handles.lblProgress, 'Visible', 'on');

    set(handles.lblOut1, 'String', '');
    set(handles.lblOut2, 'String', '');
    set(handles.lblOut3, 'String', '');
    set(handles.lblBestSNR, 'String', '');
    set(handles.lblTime, 'String', '')
    
    set(handles.lblProgress, 'String', num2str(0.0));
    
    %Clear the old curves
    if get(handles.rdoHoldOff, 'Value') == 1
        cla(handles.axResults, 'reset');
    end
end
return;



% --- Executes on selection change in cmbChannelType.
function cmbChannelType_Callback(hObject, eventdata, handles)
% hObject    handle to cmbChannelType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbChannelType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        cmbChannelType
if get(handles.cmbChannelType, 'Value') == 1
    set(handles.lblTs, 'Enable', 'off');
    set(handles.txtTs, 'Enable', 'off');
    set(handles.lblV, 'Enable', 'off');
    set(handles.txtV, 'Enable', 'off');
    set(handles.lblFdLabel, 'Enable', 'off');
    set(handles.lblFd, 'Enable', 'off');
    set(handles.lblCSIType, 'Enable', 'off');
    set(handles.cmbCSIType, 'Enable', 'off');
else
    set(handles.lblTs, 'Enable', 'on');
    set(handles.txtTs, 'Enable', 'on');
    set(handles.lblV, 'Enable', 'on');
    set(handles.txtV, 'Enable', 'on');
    set(handles.lblFdLabel, 'Enable', 'on');
    set(handles.lblFd, 'Enable', 'on');
    set(handles.lblCSIType, 'Enable', 'on');
    set(handles.cmbCSIType, 'Enable', 'on');
    
    v = str2double(get(handles.txtV, 'String'));
    fd = ((v * 1000) / 3600) / ((3e8) / (900e6));
    set(handles.lblFd, 'String', fd);
end
return;


% --- Executes during object creation, after setting all properties.
function cmbChannelType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbChannelType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtMinNumOfErrs_Callback(hObject, eventdata, handles)
% hObject    handle to txtMinNumOfErrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMinNumOfErrs as text
%        str2double(get(hObject,'String')) returns contents of txtMinNumOfErrs as a double



% --- Executes during object creation, after setting all properties.
function txtMinNumOfErrs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMinNumOfErrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over btnRunSimulation.
function btnRunSimulation_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to btnRunSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtMessageLength_Callback(hObject, eventdata, handles)
% hObject    handle to txtMessageLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMessageLength as text
%        str2double(get(hObject,'String')) returns contents of txtMessageLength as a double


% --- Executes during object creation, after setting all properties.
function txtMessageLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMessageLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTs_Callback(hObject, eventdata, handles)
% hObject    handle to txtTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTs as text
%        str2double(get(hObject,'String')) returns contents of txtTs as a double


% --- Executes during object creation, after setting all properties.
function txtTs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtV_Callback(hObject, eventdata, handles)
% hObject    handle to txtV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtV as text
%        str2double(get(hObject,'String')) returns contents of txtV as a double
v = str2double(get(handles.txtV, 'String'));
if isnan(v)
	errordlg('You must enter a numeric value as velocity', 'Bad Input', 'modal')
	return
end
fd = ((v * 1000) / 3600) / ((3e8) / (900e6));
set(handles.lblFd, 'String', fd);
return

% --- Executes during object creation, after setting all properties.
function txtV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnShowCodingScheme.
function btnShowCodingScheme_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowCodingScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
legend(handles.axResults, 'hide');
ShowCodingScheme(handles);
return

% --- Executes on button press in btnShowCurve.
function btnShowCurve_Callback(hObject, eventdata, handles)
% hObject    handle to btnShowCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.axResults, 'Visible', 'on');
legend(handles.axResults, 'show');
set(handles.pnlCodingScheme, 'Visible', 'off');

set(handles.btnShowCodingScheme, 'Visible', 'on');
set(handles.btnShowCurve, 'Visible', 'off');
return


% --- Executes on mouse press over figure background.
function frmSimulation_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to frmSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
return


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function frmSimulation_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to frmSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
return



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbCodeRate.
function cmbCodeRate_Callback(hObject, eventdata, handles)
% hObject    handle to cmbCodeRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbCodeRate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbCodeRate
if get(handles.cmbCodeRate, 'Value') == 1
    set(handles.lblOut3Label, 'Enable', 'off');
    set(handles.lblOut3, 'Enable', 'off');
    
    if (get(handles.chkDemonstration, 'Value') == get(handles.chkDemonstration, 'Max'))
        set(handles.lblOut3lbl, 'Enable', 'off');
        set(handles.txtOut3, 'Enable', 'off');
    end
elseif get(handles.cmbCodeRate, 'Value') == 2
    set(handles.lblOut3Label, 'Enable', 'on');
    set(handles.lblOut3, 'Enable', 'on');
    
    if (get(handles.chkDemonstration, 'Value') == get(handles.chkDemonstration, 'Max'))
        set(handles.lblOut3lbl, 'Enable', 'on');
        set(handles.txtOut3, 'Enable', 'on');
    end
end
return

% --- Executes during object creation, after setting all properties.
function cmbCodeRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbCodeRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTargetBER_Callback(hObject, eventdata, handles)
% hObject    handle to txtTargetBER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTargetBER as text
%        str2double(get(hObject,'String')) returns contents of txtTargetBER as a double


% --- Executes during object creation, after setting all properties.
function txtTargetBER_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTargetBER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbMemories.
function cmbMemories_Callback(hObject, eventdata, handles)
% hObject    handle to cmbMemories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbMemories contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbMemories


% --- Executes during object creation, after setting all properties.
function cmbMemories_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbMemories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtOut1_Callback(hObject, eventdata, handles)
% hObject    handle to txtOut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOut1 as text
%        str2double(get(hObject,'String')) returns contents of txtOut1 as a double


% --- Executes during object creation, after setting all properties.
function txtOut1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtOut2_Callback(hObject, eventdata, handles)
% hObject    handle to txtOut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOut2 as text
%        str2double(get(hObject,'String')) returns contents of txtOut2 as a double


% --- Executes during object creation, after setting all properties.
function txtOut2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkDemonstration.
function chkDemonstration_Callback(hObject, eventdata, handles)
% hObject    handle to chkDemonstration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDemonstration
if (get(handles.chkDemonstration, 'Value') == get(handles.chkDemonstration, 'Max'))
	set(handles.lblOut1lbl, 'Enable', 'on');
	set(handles.txtOut1, 'Enable', 'on');
	set(handles.lblOut2lbl, 'Enable', 'on');
	set(handles.txtOut2, 'Enable', 'on');
    
    if get(handles.cmbCodeRate, 'Value') == 2
        set(handles.lblOut3lbl, 'Enable', 'on');
        set(handles.txtOut3, 'Enable', 'on');
    end
else
	set(handles.lblOut1lbl, 'Enable', 'off');
	set(handles.txtOut1, 'Enable', 'off');
	set(handles.lblOut2lbl, 'Enable', 'off');
	set(handles.txtOut2, 'Enable', 'off');
	set(handles.lblOut3lbl, 'Enable', 'off');
	set(handles.txtOut3, 'Enable', 'off');
end



%function txtOut1_Callback(hObject, eventdata, handles)
% hObject    handle to txtOut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOut1 as text
%        str2double(get(hObject,'String')) returns contents of txtOut1 as a double


% --- Executes during object creation, after setting all properties.
%function txtOut1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%    set(hObject,'BackgroundColor','white');
%end



%function txtOut2_Callback(hObject, eventdata, handles)
% hObject    handle to txtOut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOut2 as text
%        str2double(get(hObject,'String')) returns contents of txtOut2 as a double


% --- Executes during object creation, after setting all properties.
%function txtOut2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%    set(hObject,'BackgroundColor','white');
%end



%function txtMessageLength_Callback(hObject, eventdata, handles)
% hObject    handle to txtMessageLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMessageLength as text
%        str2double(get(hObject,'String')) returns contents of txtMessageLength as a double


% --- Executes during object creation, after setting all properties.
%function txtMessageLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMessageLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%    set(hObject,'BackgroundColor','white');
%end



%function txtIterations_Callback(hObject, eventdata, handles)
% hObject    handle to txtMinNumOfErrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMinNumOfErrs as text
%        str2double(get(hObject,'String')) returns contents of txtMinNumOfErrs as a double


% --- Executes during object creation, after setting all properties.
%function txtIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMinNumOfErrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%    set(hObject,'BackgroundColor','white');
%end


% --- Executes during object creation, after setting all properties.
function frmSimulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frmSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in cmbDecodingType.
function cmbDecodingType_Callback(hObject, eventdata, handles)
% hObject    handle to cmbDecodingType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbDecodingType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbDecodingType


% --- Executes during object creation, after setting all properties.
function cmbDecodingType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbDecodingType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnStopSimulation.
function btnStopSimulation_Callback(hObject, eventdata, handles)
% hObject    handle to btnStopSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblStopIndicator, 'String', 'stop');



function txtOut3_Callback(hObject, eventdata, handles)
% hObject    handle to txtOut3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOut3 as text
%        str2double(get(hObject,'String')) returns contents of txtOut3 as a double


% --- Executes during object creation, after setting all properties.
function txtOut3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOut3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbInterleaverMode.
function cmbInterleaverMode_Callback(hObject, eventdata, handles)
% hObject    handle to cmbInterleaverMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbInterleaverMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbInterleaverMode


% --- Executes during object creation, after setting all properties.
function cmbInterleaverMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbInterleaverMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbCurveShape.
function cmbCurveShape_Callback(hObject, eventdata, handles)
% hObject    handle to cmbCurveShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbCurveShape contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbCurveShape


% --- Executes during object creation, after setting all properties.
function cmbCurveShape_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbCurveShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on selection change in popupmenu15.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu15


% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14


% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11


% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12


% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13


% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cmbCSIType.
function cmbCSIType_Callback(hObject, eventdata, handles)
% hObject    handle to cmbCSIType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cmbCSIType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmbCSIType


% --- Executes during object creation, after setting all properties.
function cmbCSIType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmbCSIType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function frmSimulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frmSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


