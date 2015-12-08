clear, clc
%% Variables
set = {'Aveiro', 'Porto', 'Lisboa', 'Braga', 'Coimbra'};
notSet = {'Faro', 'Viseu', 'Viana do Castelo'};
falsePositiveProbability = 0.01;

obj = BloomFilter(falsePositiveProbability, length(set), 0);
fprintf('Probability of false positive: %f\n', falsePositiveProbability);
fprintf('Length of the set to add (m): %f\n\n', length(set));

%% Add set to filter
for idx = 1:length(set)
    obj.add(set{idx});
    fprintf('%s added to the filter.\n', set{idx});
end
fprintf('\n');

%% Verify if the set is in the filter
for idx = 1:length(set)
    if obj.contains(set{idx}) == 1
        fprintf('%s is probably in the filter.\n', set{idx});
    else
        fprintf('%s is not in the filter.\n', set{idx});
    end
end
fprintf('\n');

%% Verify if other elems that were not added may be in the set
numExisting = 0;
for idx = 1:length(notSet)
    if obj.contains(notSet{idx}) == 1
        numExisting = numExisting + 1;
        fprintf('%s is probably in the filter.\n', notSet{idx});
    else
        fprintf('%s is not in the filter.\n', notSet{idx});
    end
end

fprintf('Probability of false positives (observed): %f\n\n', numExisting / length(notSet));