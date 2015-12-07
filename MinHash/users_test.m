clear, clc
% Adapted from PL07 MPEI 2015-2016
%% Parse data
udata = load('u.data');                 % Load movies' data
u = udata(:, 1:2); clear udata;         % Keep only first two rows
users = unique(u(:, 1));                % Set of users
Nu = length(users);                     % No. of users
Shingles = cell(1, Nu);                 % List of movies for each user
LSH = LSH(0.05);                        % Locality-sensitive hashing object
Signatures = cell(1, Nu);               % Signatures' cell matrix
for n = 1:Nu,                           % for-each user
    ind = find(u(:, 1) == users(n));    % Get his movies
    Shingles{n} = u(ind, 2);            % Save them
    % Compute the signature of this user
    Signatures{n} = LSH.singnature(cellstr(num2str(Shingles{n})));
end
save('u.data.shingles.mat', ...         % Save matrix of shingles
    'Shingles');
save('u.data.sig.mat', 'Signatures');   % Save matrix of signatures

%% Compute theoretical Jaccard's similarity
load('u.data.shingles.mat', 'Set');     % Load matrix of shingles
load('u.data.sig.mat', 'Signatures');   % Load matrix of signatures
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
%% Choose which pairs are above epsilon (theoretical)
threshold = 1 - 0.4;                    % chosen epsilon
SimilarUsers_t = zeros(1, 3);             % Store similar pairs [u1 u2 J]
k = 1;
for n1 = 1:Nu,
    for n2 = n1+1:Nu,
        if J(n1, n2) > threshold
            SimilarUsers_t(k, :) = [users(n1) users(n2) J(n1, n2)];
            k = k+1;
        end
    end
end
