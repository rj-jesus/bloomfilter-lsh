function [Bf, Lsh, signatures] = create_generic(path, glob, output_file)

%% Obtain the traning set

files = dir(sprintf('%s%s', path, glob));
n_files = length(files);

%% Train the application

% Bloom-filter
bf_expectedMaxSize = 1e5;
bf_falsePositiveProbablity = 0.001;
Bf = BloomFilter(bf_falsePositiveProbablity, bf_expectedMaxSize);

% LSH
lsh_errorBoud = 0.05;
Lsh = LSH(lsh_errorBoud);               % Locality-sensitive hashing object
k = 2;                                  % keep a column of 0's
signatures = zeros(Lsh.getK(), ...      % signatures matrix
    n_files, 'uint64');

h = waitbar(0, 'Learning...');
for i = 1:n_files
    waitbar(i/n_files, h);
    email = fopen(sprintf('%s%s', path, files(i).name));
    header = lower(fgetl(email));
    text = lower(deblank(char(fread(email)')));
    fclose(email);

    Bf.add(header);                     % This is spam. Filter it next time

    shingles = Lsh.shingleWords(strsplit(text));
    fprintf('Learning set of %d shingles... ',...
        length(shingles));
    if isempty(shingles)
        fprintf('Skipped.\n');
        continue
    end
    fprintf('Done.\n');
    signature = Lsh.signature(shingles);
    signatures(:, k) = signature;
    k = k + 1;
end
delete(h);

% keep only the relevant portion
signatures = unique(signatures(:, 1:k-1)', 'rows')';

if exist('output_file', 'var')
    save(output_file, 'Bf', 'Lsh', 'signatures');
end

end