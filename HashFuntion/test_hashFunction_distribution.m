clear, clc
%% Distribution test
setSize = 1e6;
stringSize = 50;
randomStringSize = 0; % False = 0 / True = else
% Allow only different strings 
X = unique(generateStrings(setSize, stringSize, randomStringSize));
setSize = length(X);
if randomStringSize == 0
    fprintf('Generated strings with fixed length: %d\n', stringSize);
else
    fprintf('Generated strings with maximum random length: %d\n', stringSize);
end

%% Get hash values using FarmHash
k = [1:5; 6:10];    % Seed values, in order to assume "the use of different
                    % hashfunctions". Build the matrix following this
                    % pattern so that later the plots work nicely
hashedStrings = zeros(1, setSize);
for seed = k(:)'
    hashedStrings = mod(FarmHash(X, seed), setSize);
    subplot(size(k, 1), size(k, 2), seed);
    histogram(hashedStrings);
    title(sprintf('k = %d', seed));
end