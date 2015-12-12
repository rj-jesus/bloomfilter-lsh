clear, clc

%% Obtain the knowledge base

load('create_16k_sig.Bf.mat', 'Bf');
load('create_16k_sig.LSH.mat', 'LSH');
load('create_16k_sig.signature.mat', 'signatures');

n_tests = 10;
x = linspace(0.01, 0.1, n_tests);

%% Obtain the SPAM testing set

% Path for testing directory

path_testing = 'emails_dataset/apart/spam/';
files = dir(sprintf('%s%s', path_testing, '*.eml'));
n_files = length(files);
n_files_to_consider = 100;
files_to_consider = randi(n_files, 1, n_files_to_consider);

%% Test it

spam_v = zeros(10, 1);

for t = 1:n_tests
    
    k = 1;
    threshold = x(t);

    h = waitbar(0, sprintf('Computing SPAM list... t = %d', t));
    for i = 1:n_files_to_consider
        waitbar(i/n_files_to_consider, h);
        
        file_name = files(files_to_consider(i)).name;
        email = fopen(sprintf('%s%s', path_testing, file_name));
        subject = fgetl(email);
        text = deblank(char(fread(email)'));
        fclose(email);

%         if Bf.count(subject)  > 2           % This is spam. Filter it
%             fprintf('%s is a spam subject. Filtered.\n', subject);
%             k = k + 1;
%             continue
%         end

        shingles = LSH.shingleWords(strsplit(text));
        if isempty(shingles)                % Filter 'empty' messages
            fprintf('No shingles could be made. Filtered.\n');
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
                k = k + 1;
            else
                fprintf('This was considered NOT TO BE SPAM. Skipped.\n');
            end
        end
    end
    delete(h);

    spam_v(t) = (k-1) / n_files_to_consider;
end

%% Obtain the NOT SPAM testing set

% Path for testing directory

path_testing = 'emails_dataset/apart/ham/';
files = dir(sprintf('%s%s', path_testing, '*.eml'));
n_files = length(files);
n_files_to_consider = 100;
files_to_consider = randi(n_files, 1, n_files_to_consider);

%% Test it

not_spam_v = zeros(10, 1);

for t = 1:n_tests
    
    k = 1;
    threshold = x(t);

    h = waitbar(0, sprintf('Computing NOT SPAM list... t = %d', t));
    for i = 1:n_files_to_consider
        waitbar(i/n_files_to_consider, h);
        
        file_name = files(files_to_consider(i)).name;
        email = fopen(sprintf('%s%s', path_testing, file_name));
        subject = fgetl(email);
        text = deblank(char(fread(email)'));
        fclose(email);

%         if Bf.count(subject)  > 2           % This is spam. Filter it
%             fprintf('%s is a spam subject. Filtered.\n', subject);
%             k = k + 1;
%             continue
%         end

        shingles = LSH.shingleWords(strsplit(text));
        if isempty(shingles)                % Filter 'empty' messages
            fprintf('No shingles could be made. Filtered.\n');
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
                k = k + 1;
            else
                fprintf('This was considered NOT TO BE SPAM. Skipped.\n');
            end
        end
    end
    delete(h);

    not_spam_v(t) = (k-1) / n_files_to_consider;
end