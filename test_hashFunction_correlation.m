clear, clc
%% Correlation test
numTests = 1e6;
stringSize = 50;
k = 100;
strSet = generateStrings(numTests, stringSize, 1);      % Vector of strings
H = zeros(k, numTests);

h = waitbar(0, 'Computing the hash functions...');
for i = 1:k
    waitbar(i/k, h);
    H(i, :) = FarmHash(strSet, i);
end
delete(h);

res = zeros(k);
h = waitbar(0, 'Calculating correlation coeficient...');
for i = 1:k
    waitbar(i/k, h);
    X = H(i, :);
    for j = i+1:k
        Y = H(j, :);
        r = corrcoef(X, Y);
        res(i, j) = r(1, 2);
        res(j, i) = r(2, 1);
    end
    res(i, i) = 0;      %   This should be 1 since Cor(A, A) = 1, but 0 was 
                        % used to make it easier to plot later on
end
delete(h);

save('test_hashFunction_cor.mat', 'res');
load('test_hashFunction_cor.mat', 'res');

surf(res);