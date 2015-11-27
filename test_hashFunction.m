clear, clc
%% Variables
setSize = 1e6;
stringSize = 50;
randomStringSize = 0; % False = 0 / True = else
% "Save" only different strings 
set = unique(generateStrings(setSize, stringSize, 1));
setSize = length(set);

if randomStringSize == 0
    fprintf('Length of the randomly generated strings: %d\n', stringSize);
else
    fprintf('Max length of the randomly generated strings: %d\n', stringSize);
end

%% Get hash values using MurmurHash3
% If the result is a uniform distributed set, then it's guaranteed that the
% hash functions are independent and can fill a set equally distributed
seed = [1 2 3]; % Change seed, in order to assume "the use of different hashfunctions"
hashedStrings = zeros(1, setSize);

for i = 1:setSize
    for j = 1:length(seed)
        hashedStrings(i) = mod(MurmurHash3(set{i}, seed(j)), setSize) + 1;
    end
end

hist(hashedStrings);

%% Second test
epsilon = 10; % coeficiente de erro
counter = 0;
numTests = 1e3;
k = 10;
falsePositiveProbability = 0.01;


for i = 1:numTests
    set = unique(generateStrings(k, stringSize, 1));
    n = ceil(length(set) * log(1 / falsePositiveProbability) / (log(2)) ^ 2);
    x = zeros(1, k);
    y = zeros(1, k);
    for seed = 1:k
        x(seed) = mod(MurmurHash3(set{j}, seed), n) + 1;
        y(seed) = mod(MurmurHash3(set{j}, floor(rand * k) + 1), n) + 1;
    end
    setSize = n;
    
    if x == y
       counter = counter + 1; 
    end
end

p = counter * setSize^k / numTests;
if 1 - p < 0.05
    fprintf('HashFunctions are independent from each other\n');
else
    fprintf('HashFunctions are not independent from each other\n');
end

