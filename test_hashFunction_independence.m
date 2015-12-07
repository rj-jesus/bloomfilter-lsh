clear, clc
%% Correlation test
numTests = 1e6;
stringSize = 50;
k = 10;
n = 5;	% Hard coding n's value since otherwise n^k will get too close to zero
strSet = generateStrings(numTests, stringSize, 1);       % Generate a unique set of Strings
%set = zeros(k, k);
set = zeros(k, numTests);

h = waitbar(0, 'Computing...');
for j = 1:numTests
    waitbar(j/numTests, h);
    for i = 1:k
        set(i, j) = FarmHash(strSet{j}, i);
    end
end
delete(h)

res = zeros(k);
for i = 1:k
    X = set(i, :);
    for j = i+1:k
        Y = set(j, :);
        mX = mean(X);
        mY = mean(Y);
        meanXY = (X - mX) * (Y - mY)';
        vX = sum((X - mX).^2);
        vY = sum((Y - mY).^2);
        res(i, j) = meanXY / sqrt(vX * vY);
    end 
end
res = res + res';
surf(res);