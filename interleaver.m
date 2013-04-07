%This function implements a Block interleater
%Input:
%             data: the input data vector to be interleaved
%Output:
%        interData: returns the interleaved data
function interData = interleaver(data)

%Calculate the size of the (n x n) matrix that will be used in teh block
%interleaver, there might be some extra bits in the matrix and they will be
%all zeros
n = ceil(sqrt(length(data)));

%Initialize the (n x n) matrix by zeros
temp = zeros(n);

%Fill the data vector in the matrix row by row
for r = 1:n
    for c = 1:n
        if (((r - 1) * n) + c) <= length(data)
            temp(r, c) = data(((r - 1) * n) + c);
        end
    end
end

%Read the data from the (n x n) matrix column by column and store it in the
%interData vector which will be the return value of this function.
interData = zeros(n * n, 1);
for r = 1:n
    for c = 1:n
        interData(((r - 1) * n) + c) = temp(c, r);
    end
end