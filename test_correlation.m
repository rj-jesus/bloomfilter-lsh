clear, clc
setSize = 1e6;
stringSize = 50;
randomStringSize = 0;
X = unique(generateStrings(setSize, stringSize, randomStringSize));
setSize = length(X);

h1 = zeros(1, setSize);
for i = 1:setSize
    h1(i) = MurmurHash3(X{i}, 1);
end

h2 = zeros(1, setSize);
for i = 1:setSize
    h1(i) = MurmurHash3(X{i}, 2);
end

r = corrcoef(h1, h2);