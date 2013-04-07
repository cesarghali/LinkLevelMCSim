%This function calculates the exact SNR value for a given BERValue.
%Inputs:
%            BER: bit error rate values vector
%           EbNo: SNR values vector that corresponds to BER
%       BERValue: the value of BER for which the function calculate its
%                 corresponding SNR
%Inputs:
%          Value: the SNR value that corresponds to BERValue
function value = EbNoval(BER, EbNo, BERValue)

%The follwoing section of the function use the binary search algorithm to
%find the two elements of the BER vector where the BERValue lies between
%them
low = 1;
high = length(BER);

while low <= high
    middleIndex = floor((low + high) / 2);
    
    if BERValue == BER(middleIndex)
        break;
    elseif BERValue > BER(middleIndex)
        high = middleIndex - 1;
	else
        low = middleIndex + 1;
    end
end

%Then the function finds the difference [BER(low) - BERValue] and 
%[BER(high) - BERValue] and finally calculates the exact BER by evaluating
%the two equations that are mentioned in the report in the
%"EbNoval function" section.
if low <= high
    value = EbNo(middleIndex);
else
    diffRight = abs(BER(low) - BERValue);
    diffLeft = abs(BER(high) - BERValue);
    diffTotal = abs(BER(high) - BER(low));
    diffEbNo = abs(EbNo(high) - EbNo(low));
    
    if diffRight == diffLeft
        value = (EbNo(low) + EbNo(high)) / 2;
    elseif diffRight < diffLeft
        diffRate = (diffRight / diffTotal);
        value = EbNo(low) - (diffEbNo * diffRate);
    else
        diffRate = (diffLeft / diffTotal);
        value = EbNo(high) + (diffEbNo * diffRate);        
    end
end