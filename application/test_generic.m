function [Spam, nfiles] = test_generic(f_var, path, glob, threshold, f_out)

%% Load variables
load(f_var);

%% Set path
files = dir(sprintf('%s%s', path, glob));
nfiles = length(files);

%% Test it
k = 1;
Spam = cell(nfiles, 2);

h = waitbar(0, 'Crunching data...');
for i = 1:nfiles
    waitbar(i/nfiles, h);
    email = fopen(sprintf('%s%s', path, files(i).name));
    header = lower(fgetl(email));
    text = lower(deblank(char(fread(email)')));
    fclose(email);

    if Bf.count(header) > 2             % This is spam. Filter it
        fprintf('%s is a spam header. Filtered.\n', header);
        Spam(k, :) = {files(i).name, 0};
        k = k + 1;
        continue
    end

    shingles = Lsh.shingleWords(strsplit(text));
    if isempty(shingles)                % Filter 'empty' messages
        fprintf('No shingles could be made. Filtered.\n');
        Spam(k, :) = {files(i).name, NaN};
        k = k + 1;
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
            Spam(k, :) = {files(i).name, m};
            k = k + 1;
        else
            fprintf('This was considered NOT TO BE SPAM. Skipped.\n');
        end
    end
end
delete(h);

Spam = Spam(1:k-1, :);                    % keep only the relevant portion

if exist('output_file', 'var')
    save(f_out, 'Spam');
end

end