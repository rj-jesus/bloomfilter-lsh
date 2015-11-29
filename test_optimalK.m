clear, clc, close all
%% Variables
setSize = 1e5;
stringSize = 50;
randomStringSize = 1; % False = 0 / True = else
% "Save" only different strings 
set = unique(generateStrings(setSize, stringSize, randomStringSize));
% Save only different strings and that were not in the original set
notSet = unique(setdiff(generateStrings(setSize, stringSize, 1), set));
setSize = length(set);
notSetSize = length(notSet);
if randomStringSize == 0
    fprintf('Generated strings with fixed length: %d\n', stringSize);
else
    fprintf('Generated strings with maximum random length: %d\n', stringSize);
end

arraySize = 8 * setSize;                                    % arraySize -> n
falsePositiveProbability = 1;                               % not important since the values are going to be set by hand
obj = BloomFilter(falsePositiveProbability, setSize, 1);
obj.setArraySize(arraySize);                                % force n to be eight times the number of strings to add
fprintf('Array size (n): %d\n', arraySize);
fprintf('Length of the set to add (m): %d\n\n', setSize);
kValues = 1:15;                                             % Test with different values of K
PfalsePositive = zeros(1, length(kValues));
PfalsePositive_theoretical = zeros(1, length(kValues));     % p = (1 - e ^ (- k * m / n)) ^k

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
        if obj.contains(notSet{idx}) == 1
            numExisting = numExisting + 1;
        end
    end
    PfalsePositive(k) = numExisting / notSetSize;
    PfalsePositive_theoretical(k) = (1 - exp(-k * setSize / arraySize)) ^ k;
end

plot(kValues, PfalsePositive, '-ro', kValues, PfalsePositive_theoretical, '-.b');
legend('Observed', 'Theoretical')
title('Probability of false positives for k hash functions');
xlabel('k');
ylabel('False positive probability');

fprintf('\nMinimal probability of false positives (observed): %f', min(PfalsePositive));
fprintf('\nOptimal K (observed): %d\n', find(PfalsePositive == min(PfalsePositive)));
fprintf('\n\nMinimal probability of false positives (thoeretical): %f', min(PfalsePositive_theoretical));
fprintf('\nOptimal K (theoretical, that would have been used by default): %d\n', ceil(arraySize * log(2) / setSize));