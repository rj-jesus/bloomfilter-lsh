% Adapted from PL07 MPEI 2015-2016
%% Init
clear, clc
LSH = LSH(0.05);                        % Locality-sensitive hashing object
udata = load('u100k.data');             % Load movies' data
u = udata(:, 1:2); clear udata;         % Keep only first two rows
users = unique(u(:, 1));                % Set of users
Nu = length(users);                     % No. of users
save('u100k.mat', 'LSH', ...            % Save (the relevant) init values
    'u', 'users', 'Nu');

%% Parse data
fprintf('Building shingles + signatures... ');
Shingles = cell(1, Nu);                 % List of movies for each user
Signatures = zeros(LSH.getK(), ...      % Signatures' cell matrix
    Nu, 'uint64');
h = waitbar(0, 'Computing Shingles + Signatures...');
for n = 1:Nu,                           % for-each user
    waitbar(n/Nu, h);
    ind = find(u(:, 1) == users(n));    % Get his movies
    Shingles{n} = u(ind, 2);            % Save them
        Signatures(:, n) = ...          % Compute this user's signature
            LSH.signature(cellstr(num2str(Shingles{n})));
end
delete(h)
save('u100k.mat', 'Shingles', ...       % Save matrix of shingles
    'Signatures', '-append');           % Save matrix of signatures
fprintf('Done.\n');

%% Compute theoretical Jaccard's similarity
fprintf('Computing Jaccard''s similarities (theoretical)... ');
load('u100k.mat', 'Shingles', ...       % Load matrix of shingles
    'Signatures');                      % Load matrix of signatures
J = zeros(Nu);                          % Array to store similarities
h = waitbar(0, 'Computing (theoretical)...');
for n1 = 1:Nu,
    waitbar(n1/Nu, h);
    m1 = Shingles{n1}(:);
    for n2 = n1+1:Nu,
        m2 = Shingles{n2}(:);
        J(n1, n2) = length(intersect(m1, m2)) / length(union(m1, m2));
    end
end
delete(h)
save('u100k.mat', 'J', '-append');
fprintf('Done.\n');
%%% Choose which pairs are above epsilon (theoretical)
fprintf('Choosing pairs above given threshold (theoretical)... ');
threshold = 1 - 0.4;                    % chosen epsilon
SimilarUsers_t = zeros(1, 3);           % Store similar pairs [u1 u2 J]
k = 1;
for n1 = 1:Nu,
    for n2 = n1+1:Nu,
        if J(n1, n2) > threshold
            SimilarUsers_t(k, :) = [users(n1) users(n2) J(n1, n2)];
            k = k+1;
        end
    end
end
save('u100k.mat', 'SimilarUsers_t', '-append');
fprintf('Done.\n');

%% Compute candidate pairs + SimilarUsers_e (above epsilon)
fprintf('Computing candidates (experimental)... ');
load('u100k.mat', 'Signatures');        % Load matrix of signatures
threshold = 1 - 0.4;                    % chosen epsilon
C = LSH.candidates(Signatures, 0.6);    % Compute candidates
save('u100k.mat', 'C', '-append');
fprintf('Done.\n');
%%% Choose which pairs are above epsilon (experimental result)
fprintf('Verifying candidates (experimental)... ');
SimilarUsers_e = LSH.similars(C, ...    % Verify which are actually similar
    Signatures, 0.6);
save('u100k.mat', 'SimilarUsers_e', '-append');
fprintf('Done.\n');
