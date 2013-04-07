%This function implements a Block interleater
%Input:
%             data: the input data vector to be interleaved
%          dataLen: the length of the original block before interleaving
%                   it. This is used to discart the extra zero bits added
%                   by the interleaver
%Output:
%        interData: returns the interleaved data
function deinterData = deinterleaver(data, dataLen)

%Call the interleaver function because it can perform deinterleaving on a
%pre-interleaved data
temp = interleaver(data);

%Return from the result previous vector a vector with the length of the
%original block before interleaving it.
deinterData = temp(1:dataLen);