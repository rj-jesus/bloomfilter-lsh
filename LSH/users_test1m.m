% Adapted from PL07 MPEI 2015-2016
%% Init (this could be saved...)
clear, clc
LSH = LSH(0.05);                        % Locality-sensitive hashing object
udata = load('u1m.data');               % Load movies' data
u = udata(:, 1:2); clear udata;         % Keep only first two rows
users = unique(u(:, 1));                % Set of users
Nu = length(users);                     % No. of users

%% Parse data
fprintf('Building shingles + signatures... ');
Shingles = cell(1, Nu);                 % List of movies for each user
Signatures = zeros(LSH.getK(), ...      % Signatures' cell matrix
    Nu, 'uint64');
for n = 1:Nu,                           % for-each user
    ind = find(u(:, 1) == users(n));    % Get his movies
    Shingles{n} = u(ind, 2);            % Save them
        Signatures(:, n) = ...          % Compute this user's signature
            LSH.signature(cellstr(num2str(Shingles{n})));
end
save('u.data.shingles1m.mat', ...       % Save matrix of shingles
    'Shingles');
clear Shingles;
save('u.data.sig1m.mat', 'Signatures'); % Save matrix of signatures
clear Signatures;
fprintf('Done.\n');

%% Compute candidate pairs + SimilarUsers_e (above epsilon)
fprintf('Computing candidates (experimental)... ');
load('u.data.sig1m.mat', 'Signatures'); % Load matrix of signatures
threshold = 1 - 0.4;                    % chosen epsilon
C = LSH.candidates(Signatures, ...      % Compute candidates
    threshold);
save('u.data.cand1m.mat', 'C');
fprintf('Done.\n');
%%% Choose which pairs are above epsilon (experimental result)
fprintf('Verifying candidates (experimental)... ');
SimilarUsers_e = LSH.similars(C, ...    % Verify which are actually similar
    Signatures, threshold);
save('u.data.sim_e1m.mat', 'SimilarUsers_e');
fprintf('Done.\n');
