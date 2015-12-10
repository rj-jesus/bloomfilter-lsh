clear, clc

%% Obtain the traning set
% Path for training directory
path_training = 'emails_dataset/p_TRAINING/';
labels = textscan(fopen('emails_dataset/SPAMTrain.label'), '%s %s');
n_files = length(labels{1});

%% Train the application
% Bloom-filter
bf_expectedMaxSize = 1e4;
bf_falsePositiveProbablity = 0.001;
Bf = BloomFilter(bf_falsePositiveProbablity, bf_expectedMaxSize);
% LSH
lsh_errorBoud = 0.05;
LSH = LSH(lsh_errorBoud);               % Locality-sensitive hashing object
k = 2;                                  % to keep a column of 0's
signatures = zeros(LSH.getK(), ...      % signatures matrix
    n_files);

h = waitbar(0, 'Teaching the program...');
for i = 1:n_files
    waitbar(i/n_files, h);
    if labels{1}{i} == '0'
        email = fopen(sprintf('%s%s', path_training, labels{2}{i}));
        from = fgetl(email);
        to = fgetl(email);
        subject = fgetl(email);
        text = deblank(char(fread(email)'));
        fclose(email);
        
        [~, address] = strtok(from, '<>');
        Bf.add(address);                % This is spam. Filter it next time
        
        shingles = LSH.shingleWords(strsplit(text));
        fprintf('Learning set of %d shingles... ',...
            length(shingles));
        if isempty(shingles)
            fprintf('Skipped.\n');
            continue
        end
        fprintf('Done.\n');
        signature = LSH.signature(shingles);
        signatures(:, k) = signature;
        k = k + 1;
    end
end
delete(h);

signatures = signatures(:, 1:k-1);      % keep only the relevant portion
save('spam.signature.mat', 'signatures');
load('spam.signature.mat', 'signatures');

%% Obtain the testing set
% Path for testing directory
path_testing = 'emails_dataset/p_TESTING/';
files = dir(sprintf('%s%s', path_testing, '*.eml'));
n_files = length(files);

%% Test it
k = 1;
Spam = cell(n_files, 1);
threshold = 0.3;

h = waitbar(0, 'Generating testing candidates...');
for i = 1:n_files
    waitbar(i/n_files, h);
    email = fopen(sprintf('%s%s', path_testing, files(i).name));
    from = fgetl(email);
    to = fgetl(email);
    subject = fgetl(email);
    text = deblank(char(fread(email)'));
    fclose(email);

    [~, address] = strtok(from, '<>');
    if Bf.contains(address)             % This is spam. Filter it
        fprintf('%s is a spam address. Filtered.\n', address);
        Spam{k} = sprintf('%s - %d', files(i).name, NaN);
        k = k + 1;
        continue
    end

    shingles = LSH.shingleWords(strsplit(text));
    if isempty(shingles)                % Filter 'empty' messages
        fprintf('No shingles could be made. Filtered.\n');
        Spam{k} = sprintf('%s - %d', files(i).name, NaN);
        k = k + 1;
        continue
    end
    signature = LSH.signature(shingles);
    
    candidates = LSH.candidates_to(signature, signatures, threshold);
    if ~isempty(candidates{1})
        fprintf('Got %d candidates. Analyzing... ', length(candidates{1}));
        candidates = candidates{1};
        similars = LSH.similars_to(signature, candidates, signatures, ...
            threshold);
        fprintf('Done.\n');
        if ~isempty(similars)
            m = max(similars(:, 2));
            fprintf('Got a similarity of %f TO A SPAM email. Filtered.\n', m);
            Spam{k} = sprintf('%s - %d', files(i).name, m);
            k = k + 1;
        else
            fprintf('This was considered NOT TO BE SPAM. Skipped.\n');
        end
    end
end
delete(h);

Spam = Spam(1:k-1);                     % keep only the relevant portion
save('spam.spam.mat', 'Spam');
load('spam.spam.mat', 'Spam');