clear, clc, close all
%% Variables
setSize = 1e5;
stringSize = 50;
randomStringSize = 1; % False = 0 / True = else
% "Save" only different strings 
set = unique(generateStrings(setSize, stringSize, randomStringSize));
% Save only different strings and that were not in the original set
notSet = unique(setdiff(generateStrings(setSize * 10, stringSize, 1), set));
setSize = length(set);
notSetSize = length(notSet);
if randomStringSize == 0
    fprintf('Generated strings with fixed length: %d\n', stringSize);
else
    fprintf('Generated strings with maximum random length: %d\n', stringSize);
end

arraySize = 8 * setSize;	% arraySize -> n
falsePositiveProbability = 1;   % set by hand later, not important
obj = BloomFilter(falsePositiveProbability, setSize, 1);
obj.setArraySize(arraySize);	% make n eight times the amount of strings to add
fprintf('Array size (n): %d\n', arraySize);
fprintf('Length of the set to add (m): %d\n\n', setSize);
kValues = 1:15;     % Test with different values of K
PfalsePositive_e = zeros(1, length(kValues));
PfalsePositive_t = zeros(1, length(kValues));	% p = (1 - e^(-k*m / n)) ^k

%% Test for k different values
for k = kValues
    fprintf('Testing for k = %d...\n', k);
    obj.setK(k);
    %% Add set to filter
    for idx = 1:setSize
        obj.add(set{idx});  
    end

    %% Verify if other elems that were not added may be in the set
    numExisting = 0;
    for idx = 1:notSetSize
        if obj.contains(notSet{idx})
            numExisting = numExisting + 1;
        end
    end
    PfalsePositive_e(k) = numExisting / notSetSize;
    PfalsePositive_t(k) = (1 - exp(-k * setSize / arraySize)) ^ k;
end

save('test_optimalK.mat', 'kValues', 'PfalsePositive_e', ...
    'PfalsePositive_t');

plot(kValues, PfalsePositive_e, '-ro', kValues, PfalsePositive_t, '-.b');
legend('Observed', 'Theoretical')
title('Probability of false positives for k hash functions');
xlabel('k');
ylabel('False positive probability');

fprintf('\nMinimal probability of false positives (observed): %f', min(PfalsePositive_e));
fprintf('\nOptimal K (observed): %d\n', find(PfalsePositive_e == min(PfalsePositive_e)));
fprintf('\n\nMinimal probability of false positives (thoeretical): %f', min(PfalsePositive_t));
fprintf('\nOptimal K (theoretical, that would have been used by default): %d\n', ceil(arraySize * log(2) / setSize));