clear, clc

%% Training set

fprintf('~ Started: TRAINING ~\n');

[Bf, Lsh, signatures] = create_generic('ours_dataset/spam/', '*.txt', ...
    'proof_of_concept.mat');

%% Default test

fprintf('~ Started: DEFAULT TESTING ~\n');

threshold = 0.3;
[Spam, n_files] = test_generic('proof_of_concept.mat', ...
    'ours_dataset/ham/', '*.eml', threshold, 'proof_of_concept.mat');

fprintf('Got %d SPAM emails on HAM folder.\n', length(Spam));

%% Loop test

fprintf('~ Started: LOOP TESTING ~\n');

while 1
    answer = inputdlg({'From: ', 'Body: '}, 'eMail', [1 100; 20 100]);
    
    if isempty(answer)
        break;
    end
    
    header = lower(['FROM: ' answer{1}]);
    text = strjoin(cellstr(lower(deblank(answer{2}))), '\n');

    if Bf.count(header) > 2             % This is spam. Filter it
        fprintf('%s is a spam header. Filtered.\n', header);
        continue
    end

    shingles = Lsh.shingleWords(strsplit(text));
    if isempty(shingles)                % Filter 'empty' messages
        fprintf('No shingles could be made. Filtered.\n');
        continue
    end
    signature = Lsh.signature(shingles);
    
    candidates = Lsh.candidates_to(signature, signatures, threshold);
    if ~isempty(candidates{1})
        fprintf('Got %d candidates. Analyzing... ', length(candidates{1}));
        candidates = candidates{1};
        similars = Lsh.similars_to(signature, candidates, signatures, ...
            threshold);
        fprintf('Done.\n');
        if ~isempty(similars)
            m = max(similars(:, 2));
            fprintf('Got a similarity of %f TO A SPAM email. Filtered.\n', m);
        else
            fprintf('This was considered NOT TO BE SPAM. Skipped.\n');
        end
    else
        fprintf('Nothing wrong with this email. Not filtered.\n');
    end
end
