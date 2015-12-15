% Adapted from PL07 MPEI 2015-2016
%% Init
clear, clc
LSH = LSH(0.01);                        % Locality-sensitive hashing object
udata = load('u1m.data');               % Load movies' data
u = udata(:, 1:2); clear udata;         % Keep only first two rows
users = unique(u(:, 1));                % Set of users
Nu = length(users);                     % No. of users
save('u1m.mat', 'LSH', ...              % Save (the relevant) init values
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
save('u1m.mat', 'Shingles', ...         % Save matrix of shingles
    'Signatures', '-append');           % Save matrix of signatures
fprintf('Done.\n');

%% Compute candidate pairs + SimilarUsers_e (above epsilon)
fprintf('Computing candidates (experimental)... ');
load('u1m.mat', 'Signatures');          % Load matrix of signatures
threshold = 1 - 0.4;                    % chosen epsilon
C = LSH.candidates(Signatures, ...      % Compute candidates
    threshold);
save('u1m.mat', 'C', '-append');
fprintf('Done.\n');
%%% Choose which pairs are above epsilon (experimental result)
fprintf('Verifying candidates (experimental)... ');
SimilarUsers_e = LSH.similars(C, ...    % Verify which are actually similar
    Signatures, threshold);
save('u1m.mat', 'SimilarUsers_e', '-append');
fprintf('Done.\n');
