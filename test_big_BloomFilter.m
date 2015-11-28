clear, clc
%% Variables
setSize = 1e6;
stringSize = 50;
randomStringSize = 1; % False = 0 / True = else
% "Save" only different strings 
set = unique(generateStrings(setSize, stringSize, 1));
% Save only different strings and that were not in the original set
notSet = unique(setdiff(generateStrings(setSize, stringSize, 1), set));
setSize = length(set);
notSetSize = length(notSet);
if randomStringSize == 0
    fprintf('Length of the randomly generated strings: %d\n', stringSize);
else
    fprintf('Max length of the randomly generated strings: %d\n', stringSize);
end

falsePositiveProbability = 0.0001;
obj = BloomFilter(falsePositiveProbability, setSize, 0);
fprintf('Probability of false positive: %f\n', falsePositiveProbability);
fprintf('Length of the set to add (m): %d\n\n', setSize);

%% Add set to filter
for idx = 1:setSize
    obj.add(set{idx});  
end
fprintf('%d randomly generated strings added to the filter.\n\n', setSize);

%% Verify if the set is in the filter
numExisting = 0;
for idx = 1:setSize
    if obj.contains(set{idx}) == 1
        numExisting = numExisting + 1;
    end
end
fprintf('%d strings that were previously added are probably in the set.\n', numExisting);
fprintf('%d strings that were previously added are not in the set.\n\n', setSize - numExisting);

%% Verify if other elems that were not added may be in the set
numExisting = 0;
for idx = 1:notSetSize
    if obj.contains(notSet{idx}) == 1
        numExisting = numExisting + 1;
    end
end
fprintf('%d strings that were not added are probably in the set.\n', numExisting);
fprintf('%d strings that were not added are not in the set.\n', notSetSize - numExisting);
fprintf('Probability of false positives (observed): %f\n\n', numExisting / notSetSize);
