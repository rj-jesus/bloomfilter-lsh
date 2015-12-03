% Adapted from PL07 MPEI 2015-2016
%% Parse data
udata = load('u.data');                 % Load movies' data
u = udata(:, 1:2); clear udata;         % Keep only first two rows
users = unique(u(:, 1));                % Set of users
Nu = length(users);                     % No. of users
Set = cell(Nu, 1);                      % List of movies for each user
for n = 1:Nu,                           % for-each user
    ind = find(u(:, 1) == users(n));    % Get his movies
    Set{n} = u(ind, 2);                 % Save them
end
%% Compute Jaccard's similarity
J = zeros(Nu);                          % Array to store similarities
h = waitbar(0, 'Computing...');
for n1 = 1:Nu,
    waitbar(n1/Nu, h);
    m1 = Set{n1}(:);
    for n2 = n1+1:Nu,
        m2 = Set{n2}(:);
        J(n1, n2) = length(intersect(m1, m2)) / length(union(m1, m2));
    end
end
delete(h)
%% Choose which pairs are above epsilon
threshold = 1 - 0.4;                    % chosen epsilon
SimilarUsers = zeros(1, 3);             % Store similar pairs [u1 u2 J]
k = 1;
for n1 = 1:Nu,
    for n2 = n1+1:Nu,
        if J(n1, n2) > threshold
            SimilarUsers(k, :) = [users(n1) users(n2) J(n1, n2)];
            k = k+1;
        end
    end
end
