clear, clc, close all
%% Variables
setSize = 1e5;
stringSize = 50;
randomStringSize = 1; % False = 0 / True = else
% Store only unique strings 
set = unique(generateStrings(setSize, stringSize, randomStringSize));
% Store only unique strings and that were not in the original set
notSet = unique(setdiff(generateStrings(setSize, stringSize, 1), set));
setSize = length(set);
notSetSize = length(notSet);
if randomStringSize == 0
    fprintf('Generated strings with fixed length: %d\n', stringSize);
else
    fprintf('Generated strings with maximum random length: %d\n', stringSize);
end
fprintf('Length of the set to add (m): %d\n\n', setSize);

f_k = @(n)(ceil(n * log(2) / setSize));     % useful to update k's value (since it depends on n)
nValues = setSize:setSize/2:10*setSize;
PfalsePositive_e = zeros(1, length(nValues));
PfalsePositive_t = zeros(1, length(nValues));
for i = 1:length(nValues)
    n = round(nValues(i));
    fprintf('Testing for n = %d... ', n);
    k = f_k(n);
    %% Create a new filter with size n to test
    obj = BloomFilter(1, setSize, 1);
    obj.setArraySize(n);
    obj.setK(k);
    %% Add set to filter
    for idx = 1:setSize
        obj.add(set{idx});  
    end
    %% Verify if other elems that were not added may be in the set (false positives)
    numExisting = 0;
    for idx = 1:notSetSize
        if obj.contains(notSet{idx}) == 1
            numExisting = numExisting + 1;
        end
    end
    PfalsePositive_e(i) = numExisting / notSetSize;
    PfalsePositive_t(i) = (1 - exp(-k * setSize / n)) ^ k;
    fprintf('Completed.\n');
end

save('test_optimalN.mat', 'nValues', 'PfalsePositive_e', 'PfalsePositive_t');

plot(nValues, PfalsePositive_e, '-ro', nValues, PfalsePositive_t, '-.b');
legend('Observed', 'Theoretical')
title('Probability of false positives for different values of n');
xlabel('n');
ylabel('False positive probability');

fprintf('\nMinimal probability of false positives (observed): %f', min(PfalsePositive_e));
fprintf('\nOptimal n (observed): %d\n', nValues(PfalsePositive_e == min(PfalsePositive_e)));
fprintf('\n\nMinimal probability of false positives (thoeretical): %f', min(PfalsePositive_t));
fprintf('\nOptimal n (theoretical, that would have been used by default): %d\n', ceil(setSize * log(1 / min(PfalsePositive_t)) / (log(2)) ^ 2));