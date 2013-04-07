%This function represents the automation mode of the simulation. It
%calculate the BER(SNR) curve for all the convolutional code.
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
%Inputs:
%               results: a structure that represents the results BER
%                 error: an integer number that represents the error in the
%                        simulation (if any) to be handled by the interface
%                        by displaying the appropriate MessageBox
function [results, error] = automation(handles, hMod, hDemod, chanType, ts, fd, CSIType, codeRate, memories, decodingType, msgLength, ...
        minNumOfErrs, targetBER, interleaverMode, randomSeed)

%Clear old variables
clear resultsIndex;
clear result;
clear error;
clear results;

error = 0;

%The follwoing loops try all the possibilities of the convolutional encoder
%for R = 1/2 and then call teh demonstration function for each one
resultsIndex = 1;
if codeRate == 2
    for out1 = 0:((2 ^ (memories + 1)) - 1)
        for out2 = out1:((2 ^ (memories + 1)) - 1)
            %Calling the demonstration function for the current possibility
            [result, error] = demonstration(handles, (codeRate * (2 ^ (memories + 1))), resultsIndex, hMod, hDemod, chanType, ts, fd, CSIType, ...
                    codeRate, memories, decodingType, msgLength, minNumOfErrs, targetBER, interleaverMode, randomSeed, ...
                    [str2double(dec2base(out1, 8)) str2double(dec2base(out2, 8))]);

            %Add the demonstration result to the results vector if there is
            %no error
            if error == 0
                results(resultsIndex) = result;
                resultsIndex = resultsIndex + 1;
            elseif error == 3
                results = 0;
                error = 3;
                return;
            end
        end
    end
%The follwoing loops try all the possibilities of the convolutional encoder
%for R = 1/3 and then call teh demonstration function for each one
elseif codeRate == 3
    for out1 = 0:((2 ^ (memories + 1)) - 1)
        for out2 = out1:((2 ^ (memories + 1)) - 1)
            for out3 = out2:((2 ^ (memories + 1)) - 1)
                %Calling the demonstration function for the current
                %possibility
                [result, error] = demonstration(handles, (codeRate * (2 ^ (memories + 1))), resultsIndex, hMod, hDemod, chanType, ts, fd, CSIType, ...
                    codeRate, memories, decodingType, msgLength, minNumOfErrs, targetBER, interleaverMode, randomSeed, ...
                    [str2double(dec2base(out1, 8)) str2double(dec2base(out2, 8)) str2double(dec2base(out3, 8))]);

                %Add the demonstration result to the results vector if
                %there is no error
                if error == 0
                    results(resultsIndex) = result;
                    resultsIndex = resultsIndex + 1;
                elseif error == 3
                    results = 0;
                    error = 3;
                    return;
                end
            end
        end
    end
end