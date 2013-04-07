%This function draws the coding scheme of the best convolutional code.
%Notice that the function is capable of drawing any obtained convoltional
%code for R = 1/2 and R = 1/3 and M = 2, 3 and 4
function ShowCodingScheme(handles)

if get(handles.cmbCodeRate, 'Value') == 1
    set(handles.lblXORMiddleBorder, 'Visible', 'off');
    set(handles.lblXORMiddleBack, 'Visible', 'off');
    set(handles.lblXORMiddle, 'Visible', 'off');
    set(handles.lblOutput3Line1, 'Visible', 'off');
    set(handles.lblOutput3Line2, 'Visible', 'off');
	set(handles.lblOutput3, 'Visible', 'off');
    
    set(handles.lblBit1_1_3, 'Visible', 'off');
	set(handles.lblBit1_2_3, 'Visible', 'off');
    set(handles.lblBit2_1_3, 'Visible', 'off');
	set(handles.lblBit2_2_3, 'Visible', 'off');
    set(handles.lblBit3_1_3, 'Visible', 'off');
	set(handles.lblBit3_2_3, 'Visible', 'off');
    set(handles.lblBit3_3_3, 'Visible', 'off');
    set(handles.lblBit4_1_3, 'Visible', 'off');
	set(handles.lblBit4_2_3, 'Visible', 'off');
    set(handles.lblBit5_1_3, 'Visible', 'off');
	set(handles.lblBit5_2_3, 'Visible', 'off');
elseif get(handles.cmbCodeRate, 'Value') == 2
    set(handles.lblXORMiddleBorder, 'Visible', 'on');
    set(handles.lblXORMiddleBack, 'Visible', 'on');
    set(handles.lblXORMiddle, 'Visible', 'on');
    set(handles.lblOutput3Line1, 'Visible', 'on');
    set(handles.lblOutput3Line2, 'Visible', 'on');
	set(handles.lblOutput3, 'Visible', 'on');
end

memories = get(handles.cmbMemories, 'Value') + 1;

if memories == 2
    set(handles.lblM3Border, 'Visible', 'off');
    set(handles.lblM3Back, 'Visible', 'off');
    set(handles.lblM3, 'Visible', 'off');
    set(handles.lblM4Border, 'Visible', 'off');
    set(handles.lblM4Back, 'Visible', 'off');
    set(handles.lblM4, 'Visible', 'off');
    
    set(handles.lblM3Line, 'Visible', 'off');
	set(handles.lblM3M4Line1, 'Visible', 'off');
 	set(handles.lblM3M4Line2, 'Visible', 'off');
    set(handles.lblM4Line, 'Visible', 'off');
    
    set(handles.lblBit4_1_1, 'Visible', 'off');
    set(handles.lblBit4_2_1, 'Visible', 'off');
    set(handles.lblBit4_1_2, 'Visible', 'off');
    set(handles.lblBit4_2_2, 'Visible', 'off');
    set(handles.lblBit5_1_1, 'Visible', 'off');
    set(handles.lblBit5_2_1, 'Visible', 'off');
    set(handles.lblBit5_1_2, 'Visible', 'off');
    set(handles.lblBit5_2_2, 'Visible', 'off');

    if get(handles.cmbCodeRate, 'Value') == 2
        set(handles.lblBit4_1_3, 'Visible', 'off');
        set(handles.lblBit4_2_3, 'Visible', 'off');
        set(handles.lblBit5_1_3, 'Visible', 'off');
        set(handles.lblBit5_2_3, 'Visible', 'off');
    end
elseif memories == 3
    set(handles.lblM3Border, 'Visible', 'on');
    set(handles.lblM3Back, 'Visible', 'on');
    set(handles.lblM3, 'Visible', 'on');
    set(handles.lblM4Border, 'Visible', 'off');
    set(handles.lblM4Back, 'Visible', 'off');
    set(handles.lblM4, 'Visible', 'off');
    
    set(handles.lblM3Line, 'Visible', 'on');
	set(handles.lblM3M4Line1, 'Visible', 'on');
 	set(handles.lblM3M4Line2, 'Visible', 'off');
    set(handles.lblM4Line, 'Visible', 'off');
    
    set(handles.lblBit5_1_1, 'Visible', 'off');
    set(handles.lblBit5_2_1, 'Visible', 'off');
    set(handles.lblBit5_1_2, 'Visible', 'off');
    set(handles.lblBit5_2_2, 'Visible', 'off');
    
    if get(handles.cmbCodeRate, 'Value') == 2
        set(handles.lblBit5_1_3, 'Visible', 'off');
        set(handles.lblBit5_2_3, 'Visible', 'off');
    end
elseif memories == 4
    set(handles.lblM3Border, 'Visible', 'on');
    set(handles.lblM3Back, 'Visible', 'on');
    set(handles.lblM3, 'Visible', 'on');
    set(handles.lblM4Border, 'Visible', 'on');
    set(handles.lblM4Back, 'Visible', 'on');
    set(handles.lblM4, 'Visible', 'on');
    
    set(handles.lblM3Line, 'Visible', 'on');
	set(handles.lblM3M4Line1, 'Visible', 'on');
 	set(handles.lblM3M4Line2, 'Visible', 'on');
    set(handles.lblM4Line, 'Visible', 'on');
end


%Convert the three best generator polynomials from octadecimal to binary in
out1Bin = dec2bin(base2dec(get(handles.lblOut1, 'String'), 8), memories + 1);
out2Bin = dec2bin(base2dec(get(handles.lblOut2, 'String'), 8), memories + 1);
if get(handles.cmbCodeRate, 'Value') == 2
    out3Bin = dec2bin(base2dec(get(handles.lblOut3, 'String'), 8), memories + 1);
end


%The follwoing section of code show and hides the appropriate lines in the
%encoders based on the previous three binaries values in order to draw the
%correspinding encoder.

%Processing the first generator polynomail (output 1)
if strcmp(out1Bin(1), '0')
    set(handles.lblBit1_1_1, 'Visible', 'off');
    set(handles.lblBit1_2_1, 'Visible', 'off');
else
    set(handles.lblBit1_1_1, 'Visible', 'on');
    set(handles.lblBit1_2_1, 'Visible', 'on');
end
if strcmp(out1Bin(2), '0')
    set(handles.lblBit2_1_1, 'Visible', 'off');
    set(handles.lblBit2_2_1, 'Visible', 'off');
else
    set(handles.lblBit2_1_1, 'Visible', 'on');
    set(handles.lblBit2_2_1, 'Visible', 'on');
end
if strcmp(out1Bin(3), '0')
    set(handles.lblBit3_1_1, 'Visible', 'off');
else
    set(handles.lblBit3_1_1, 'Visible', 'on');
end
if memories == 3 ||  memories == 4
    if strcmp(out1Bin(4), '0')
        set(handles.lblBit4_1_1, 'Visible', 'off');
        set(handles.lblBit4_2_1, 'Visible', 'off');
    else
        set(handles.lblBit4_1_1, 'Visible', 'on');
        set(handles.lblBit4_2_1, 'Visible', 'on');
    end
end
if memories == 4
    if strcmp(out1Bin(5), '0')
        set(handles.lblBit5_1_1, 'Visible', 'off');
        set(handles.lblBit5_2_1, 'Visible', 'off');
    else
        set(handles.lblBit5_1_1, 'Visible', 'on');
        set(handles.lblBit5_2_1, 'Visible', 'on');
    end
end


%Processing the second generator polynomail (output 2)
if strcmp(out2Bin(1), '0')
    set(handles.lblBit1_1_2, 'Visible', 'off');
    set(handles.lblBit1_2_2, 'Visible', 'off');
else
    set(handles.lblBit1_1_2, 'Visible', 'on');
    set(handles.lblBit1_2_2, 'Visible', 'on');
end
if strcmp(out2Bin(2), '0')
    set(handles.lblBit2_1_2, 'Visible', 'off');
    set(handles.lblBit2_2_2, 'Visible', 'off');
else
    set(handles.lblBit2_1_2, 'Visible', 'on');
    set(handles.lblBit2_2_2, 'Visible', 'on');
end
if strcmp(out2Bin(3), '0')
    set(handles.lblBit3_1_2, 'Visible', 'off');
else
    set(handles.lblBit3_1_2, 'Visible', 'on');
end
if memories == 3 || memories == 4
    if strcmp(out2Bin(4), '0')
        set(handles.lblBit4_1_2, 'Visible', 'off');
        set(handles.lblBit4_2_2, 'Visible', 'off');
    else
        set(handles.lblBit4_1_2, 'Visible', 'on');
        set(handles.lblBit4_2_2, 'Visible', 'on');
    end
end
if memories == 4
    if strcmp(out2Bin(5), '0')
        set(handles.lblBit5_1_2, 'Visible', 'off');
        set(handles.lblBit5_2_2, 'Visible', 'off');
    else
        set(handles.lblBit5_1_2, 'Visible', 'on');
        set(handles.lblBit5_2_2, 'Visible', 'on');
    end
end


%Processing the third generator polynomail (output 3)
if get(handles.cmbCodeRate, 'Value') == 2
    if strcmp(out3Bin(1), '0')
        set(handles.lblBit1_1_3, 'Visible', 'off');
        set(handles.lblBit1_2_3, 'Visible', 'off');
    else
        set(handles.lblBit1_1_3, 'Visible', 'on');
        set(handles.lblBit1_2_3, 'Visible', 'on');
    end
    if strcmp(out3Bin(2), '0')
        set(handles.lblBit2_1_3, 'Visible', 'off');
        set(handles.lblBit2_2_3, 'Visible', 'off');
    else
        set(handles.lblBit2_1_3, 'Visible', 'on');
        set(handles.lblBit2_2_3, 'Visible', 'on');
    end
    if strcmp(out3Bin(3), '0')
        set(handles.lblBit3_1_3, 'Visible', 'off');
        set(handles.lblBit3_2_3, 'Visible', 'off');
        set(handles.lblBit3_3_3, 'Visible', 'off');
    else
        set(handles.lblBit3_1_3, 'Visible', 'on');
        set(handles.lblBit3_2_3, 'Visible', 'on');
        set(handles.lblBit3_3_3, 'Visible', 'on');
    end
    if memories == 3 || memories == 4
        if strcmp(out3Bin(4), '0')
            set(handles.lblBit4_1_3, 'Visible', 'off');
            set(handles.lblBit4_2_3, 'Visible', 'off');
        else
            set(handles.lblBit4_1_3, 'Visible', 'on');
            set(handles.lblBit4_2_3, 'Visible', 'on');
        end
    end
    if memories == 4
        if strcmp(out3Bin(5), '0')
            set(handles.lblBit5_1_3, 'Visible', 'off');
            set(handles.lblBit5_2_3, 'Visible', 'off');
        else
            set(handles.lblBit5_1_3, 'Visible', 'on');
            set(handles.lblBit5_2_3, 'Visible', 'on');
        end
    end
end


set(handles.pnlCodingScheme, 'Visible', 'on');
set(handles.axResults, 'Visible', 'off');

set(handles.btnShowCodingScheme, 'Visible', 'off');
set(handles.btnShowCurve, 'Visible', 'on');