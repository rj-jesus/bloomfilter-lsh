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
setSize = 1e6;
set = unique(generateStrings(setSize, stringSize, 1));
setSize = length(set); 
k = 10;


for i = 1:setSize
    x = zeros(1, k);
    y = zeros(1, k);
    for seed = 1:10
        x(seed) = mod(MurmurHash3(set{i}, seed), setSize) + 1;
        y(seed) = mod(MurmurHash3(set{i}, floor(rand * setSize) + 1), setSize) + 1;
    end
    
    if x == y
       counter = counter + 1; 
    end
end

if counter / setSize <= epsilon * (1 / m)^k
    fprintf('HashFunctions are independent from each other\n');
else
    fprintf('HashFunctions are not independent from each other\n');
end

