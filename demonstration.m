%This function represents the demonstration mode of the simulation. It
%calculate the BER(SNR) curve for a spesific convolutional code.
%Inputs:
%               handles: a handle to the GUI controls
%          numOfTrellis: the total number of trellis (used to calculate the
%                        percentage processing indicator)
%        currentTrellis: the current trellis (used to calculate the
%                        percentage processing indicator)
%                  hMod: the modulator used in the simulation
%                hDemod: the demodulator used in the simulation
%              chanType: the channel type 'awgn' or 'fading'
%                    ts: the sampling rate of the rayleigh fading channel
%                    fd: the doppler shift of the rayleigh fading channel
%              codeRate: the code rate where 2 indicates to R = 1/2 and 3
%                        indicates to R = 1/3
%              memories: the number if memory elements in the convolutional
%                        encoder
%          decodingType: the decoding type used by the Viterbi decoder
%                        'hard' or 'soft'
%             msgLength: the number of bits in each message frame
%          minNumOfErrs: the minimum number of errors where the simulation
%                        should stop sending frames over the same SNR
%             targetBER: the target BER where the simulation must stop
%       interleaverMode: the interleaver mode used where 1 indicates to
%                        'none', 2 indicates to 'Block' and 3 indicates to
%                        'Pseudo-Random'
%            randomSeed: a random number that represents the seed of the
%                        Pseudo-Random interleaver
%                  outs: a vector contains the generator polynomials of the
%                        convolutional encoder.
%Inputs:
%               results: a structure that represents the results BER
%                 error: an integer number that represents the error in the
%                        simulation (if any) to be handled by the interface
%                        by displaying the appropriate MessageBox
function [results, error] = demonstration(handles, numOfTrellis, currentTrellis, hMod, hDemod, chanType, ts, fd, CSIType, codeRate, memories, ...
    decodingType, msgLength, minNumOfErrs, targetBER, interleaverMode, randomSeed, outs)

%Clearing old variables
clear BERnumOfSteps;
clear BERStep;
clear BERSteps;
clear error;
clear chan;
clear fading;
clear fadingEffect;
clear trellis;
clear currentBER;
clear n;
clear currentSNR;
clear incSNR;
clear currentBERStep;
clear numOfErrs;
clear i;
clear tMsg;
clear tCodedMsg;
clear tInterSig;
clear fadedSig;
clear noisySig;
clear rSig;
clear rInterSig;
clear rDecodedMsg;
clear rMsg;
clear nErrors;
clear kBER;
clear incStep;
clear results;

%Preparing some variables used in calculating the percentage indicator
BERnumOfSteps = 2 * (log10(1 / targetBER));
BERStep = 0.000045;
BERSteps = zeros(BERnumOfSteps, 1);
BERSteps(BERnumOfSteps) = targetBER;
for i = (BERnumOfSteps - 1):-1:1
    BERSteps(i) = BERSteps(i + 1) + BERStep;
    
    if mod(i, 2) == 0
        BERStep = BERStep * 10;
    end
end

error = 0;


%Initialize a Rayleigh channel if the chanType is 'fading'
if strcmp(chanType, 'fading')
    chan = rayleighchan(ts, fd);
    
    %Apply the channel effect on a message consists of a frame of ones
    if interleaverMode == 1
        fading = filter(chan, ones(msgLength * codeRate, 1));
    elseif interleaverMode == 2
        fading = filter(chan, ones(ceil(sqrt(msgLength * codeRate)) ^ 2, 1));
     elseif interleaverMode == 3
        fading = filter(chan, ones(msgLength * codeRate, 1));
    end
    
    %Calculate the fading effect by getting the amplitide of fading
    fadingEffect = sqrt((real(fading) .^ 2) + (imag(fading) .^ 2));
    
    if CSIType == 2
        [indexCSI, CSIEffect] = quantiz(fadingEffect(msgLength * 2), [1/3 2/3], [0.5 2 4]);
    end
end

%Initialize a trellis and return an error if the generator polynonials are
%bad
try
    trellis = poly2trellis(memories + 1, outs);
catch Err
    error = 1;
    results = 0;
    return;
end

%Check if the initialized trellis is catastrophic and return error if it is
if iscatastrophic(trellis)
    error = 2;
    results = 0;
    return;
end

%Initialized some variables
currentBER = 1;
n = 1;
currentSNR = 0;    
if strcmp(chanType, 'nofading')
    incSNR = 0.5;
elseif strcmp(chanType, 'fading')
    incSNR = 1;
end

clear SNR;
clear BER;

%The follwoing while loop keep repeating until the simulation reachs BER
%less than targetBER
currentBERStep = 1;
while currentBER > targetBER && n <= 30
    SNR(n) = currentSNR;

    numOfErrs = 0;
    i = 1;
    
    %The follwoing while loop keep repeating until the simulation gets
    %number of errors less than minNumOfErrs
    while numOfErrs < minNumOfErrs
        %The transmitter side
        %Generate the message using a Bernolli source
        tMsg = bernoulliGenerator(msgLength, 0.5);
        %Apply convolutional code
        tCodedMsg = convenc(tMsg, trellis);
        %Apply the appropriate interleaver
        if interleaverMode == 1
            %no interleaver
            tInterMsg = tCodedMsg;            
        elseif interleaverMode == 2
            %block interleaver
            tInterMsg = interleaver(tCodedMsg);
        elseif interleaverMode == 3
            %pseudo-random interleaver
            tInterMsg = randintrlv(tCodedMsg, randomSeed);
        end
        %Apply modulation
        tSig = modulate(hMod, tInterMsg);

        %In the channel
        %Apply fading effect if the channel type is fading channel
        if strcmp(chanType, 'nofading')
            fadedSig = tSig;
        elseif strcmp(chanType, 'fading')
            fadedSig = tSig .* fadingEffect;
        end
        %Apply awgn noise at the curent SNR value
        noisySig = awgn(fadedSig, currentSNR);

        %The receiver side
        rSig = noisySig;
        %If it is hard
        if strcmp(decodingType, 'hard')
            %Apply demodulation
            rDemodMsg = demodulate(hDemod, rSig);
            %Apply the appropriate deinterleaver
            if interleaverMode == 1
                %no interleaver
                rDeinterMsg = rDemodMsg;
            elseif interleaverMode == 2
                %block interleaver
                rDeinterMsg = deinterleaver(rDemodMsg, msgLength * codeRate);
            elseif interleaverMode == 3
                %pseudo-random interleaver
                rDeinterMsg = randdeintrlv(rDemodMsg, randomSeed);
            end
            if CSIType == 1
                %Apply viterbi decoder where the third parameter is the delay
                %of the decoder and according to MATLAB help its typical value
                %is five times the constraint length (memories + inputs)
                rMsg = vitdec(rDeinterMsg, trellis, (memories + 1) * 5, 'trunc', 'hard');
            elseif CSIType == 2
                %Apply viterbi decoder taking into account the CSIEffect
                [temp, rDeinterMsg] = quantiz(((-2 * rDeinterMsg) + 1) .* CSIEffect, [-4 -2 -0.5 0 0.5 2 4], [7 6 5 4 3 2 1 0]);
                rMsg = vitdec(rDeinterMsg', trellis, (memories + 1) * 5, 'trunc', 'soft', 3);
            end
        %If it is soft
        else
            %Quantize the real part of the received signal to be used in
            %the soft Viterbi decoder
            if CSIType == 1
                [temp, rDemodMsg] = quantiz(real(rSig), [-0.75 -0.5 -0.25 0 0.25 0.5 0.75], [7 6 5 4 3 2 1 0]);                
            elseif CSIType == 2
                [temp, rDemodMsg] = quantiz(real(rSig) .* CSIEffect, [-1.5 -1.0 -0.5 0 0.5 1.0 1.5], [7 6 5 4 3 2 1 0]);
            end
            %Apply deinterleaver
            if interleaverMode == 1
                %no interleaver
                rDeinterMsg = rDemodMsg;
            elseif interleaverMode == 2
                %block interleaver
                rDeinterMsg = deinterleaver(rDemodMsg, msgLength * codeRate);
            elseif interleaverMode == 3
                %pseudo-random interleaver
                rDeinterMsg = randdeintrlv(rDemodMsg, randomSeed);
            end
            
            
            %Apply soft Viterbi decoding algorithm
            rMsg = vitdec(rDeinterMsg, trellis, (memories + 1) * 5, 'trunc', 'soft', 3);
        end

        %Calucalte the BER (for the current frame) between the original
        %message and the received message
        [nErrors, kBER(i)] = biterr(tMsg, rMsg);

        numOfErrs = numOfErrs + nErrors;
        i = i + 1;
        
        
        %Calculate and display the percentage indicator
        numOfSteps = 10;
        for t = 0:(numOfSteps - 1)
            if numOfErrs > ((minNumOfErrs * t) / numOfSteps) && numOfErrs <= ((minNumOfErrs * (t + 1)) / numOfSteps)
                incStep = floor(((100 * (currentBERStep / BERnumOfSteps) + (((t + 1) / numOfSteps) * BERnumOfSteps)) * (currentTrellis / numOfTrellis)));% - ((2 / BERnumOfSteps) * 100));
                if incStep > 0 && incStep < 100
                    set(handles.lblProgress, 'String', incStep);
                end
                
                break;
            end
        end
        drawnow;
        
        
        %Stop the simulation if the user click on the stop button
        if strcmp(get(handles.lblStopIndicator, 'String'), 'stop')
            set(handles.lblStopIndicator, 'String', '');
            results = 0;
            error = 3;
            return;
        end
    end

    %Calculate the average BER for all the frames
    BER(n) = sum(kBER) / length(kBER);
    currentBER = BER(n);

    n = n + 1;
    currentSNR = currentSNR + incSNR;
    
    
	%Calculate and display the percentage indicator
    currentBERStep = 0;
    if currentBER < BERSteps(1)
        for i = 1:(BERnumOfSteps - 1)
            currentBERStep = currentBERStep + 1;        
            if (currentBER < BERSteps(i)) && (currentBER >= BERSteps(i + 1))
                break;
            end
        end
    end
end

%Return the results
if codeRate == 2
    results = struct('SNR', SNR, 'BER', BER, 'EbNoValue', EbNoval(BER, SNR, 1e-3), 'out1', outs(1), 'out2', outs(2));
elseif codeRate ==3
    results = struct('SNR', SNR, 'BER', BER, 'EbNoValue', EbNoval(BER, SNR, 1e-3), 'out1', outs(1), 'out2', outs(2), 'out3', outs(3));
end
