%This function performs a Bernoulli source generator that generates a string
%of bits based on a specified ones occurrence probability
%Inputs:
%          n: the length of the generated bits string
%          p: the ones occurrence probability
%Inputs:
%       bits: returns the bits string
function bits = bernoulliGenerator(n, p)

%Generate n random number between 0 and 1
temp = rand(n,1);

%Loop over all the random number, if this number is less than the
%probability of ones it will be converted it to one otherwise it will be
%converted to zero
for i = 1:length(temp)
    if (temp(i) < p)
        temp(i) = 1;
    else
        temp(i) = 0;
    end
end

%Return the generated bits string
bits = temp;