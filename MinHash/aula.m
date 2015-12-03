clear, clc
% Adapted from PL07 MPEI 2015-2016
%% Parse data
udata = load('u.data');                 % Load movies' data
u = udata(1:100, 1:2); clear udata;         % Keep only first two rows
users = unique(u(:, 1));                % Set of users
Nu = length(users);                     % No. of users
Set = cell(Nu, 1);                      % List of movies for each user
for n = 1:Nu,                           % for-each user
    ind = find(u(:, 1) == users(n));    % Get his movies
    Set{n} = u(ind, 2);                 % Save them
end
%% Compute theoretical Jaccard's similarity
J = zeros(Nu);                          % Array to store similarities
h = waitbar(0, 'Computing (theoretical)...');
for n1 = 1:Nu,
    waitbar(n1/Nu, h);
    m1 = Set{n1}(:);
    for n2 = n1+1:Nu,
        m2 = Set{n2}(:);
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
%% Compute observed (using Min-Hashing) Jaccard's similarity
expectedError = 0.05;                   % Expected error of MinHash module
debug = 0;                              % Debug of MinHash module off
minHash = MinHash(expectedError, debug);
J = zeros(Nu);                          % Array to store similarities
h = waitbar(0, 'Computing (using Min-Hashing)...');
for n1 = 1:Nu,
    waitbar(n1/Nu, h);
    m1 = cellstr(num2str(Set{n1}));
    for n2 = n1+1:Nu,
        m2 = cellstr(num2str(Set{n2}));
        J(n1, n2) = minHash.similarity(m1, m2);
    end
end
delete(h)
%% Choose which pairs are above epsilon (using Min-Hashing)
threshold = 1 - 0.4;                    % chosen epsilon
SimilarUsers_o = zeros(1, 3);             % Store similar pairs [u1 u2 J]
k = 1;
for n1 = 1:Nu,
    for n2 = n1+1:Nu,
        if J(n1, n2) > threshold
            SimilarUsers_o(k, :) = [users(n1) users(n2) J(n1, n2)];
            k = k+1;
        end
    end
end
