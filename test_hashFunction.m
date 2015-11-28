clear, clc
%% Distribution test
setSize = 1e6;
stringSize = 50;
randomStringSize = 0; % False = 0 / True = else
% Allow only different strings 
X = unique(generateStrings(setSize, stringSize, randomStringSize));
setSize = length(X);

if randomStringSize == 0
    fprintf('Length of the randomly generated strings: %d\n', stringSize);
else
    fprintf('Max length of the randomly generated strings: %d\n', stringSize);
end

%% Get hash values using MurmurHash3
% ***** Check the comments below, this is not true *****
k = [1:5; 6:10];    % Change seed, in order to assume "the use of different hashfunctions"
                    % build the matrix following this pattern so that later
                    % the plots work nicely
hashedStrings = zeros(1, setSize);
for seed = k(:)'
    for i = 1:setSize
        hashedStrings(i) = mod(MurmurHash3(X{i}, seed), setSize) + 1;
    end
    subplot(size(k, 1), size(k, 2), seed);
    histogram(hashedStrings);
    title(sprintf('k = %d', seed));
end

%% Independence test
%%%%%
% > Theoretical intro
% A family of hash functions is k-independent if for any k-distinct keys
% (here x set) and k hash codes not necessarily distinct (here z
% collection) we have:
%   P(h1(x1) = zi AND h2(x2) = z2 AND ... AND hk(xk) = zk) = 1 / n^k
% For more information see: https://en.wikipedia.org/wiki/K-independent_hashing
%%%%%
numTests = 1e6;
stringSize = 50;
k = 10;
n = 5;	% Hard coding n's value since otherwise n^k will get too close to zero

counter = 0;
for i = 1:numTests
    X = unique(generateStrings(k*2, stringSize, 1));    % Generate a unique set of Strings
    y = zeros(1, k);                                    % Actual values for each hi(xi)
    z = floor(rand(1, k) * k) + 1;                      % Random hash values for this family of k hash-functions
    for j = 1:k
        y(j) = mod(MurmurHash3(X{j}, j), n) + 1;        % y(i) = hi(xi)
        z(j) = mod(MurmurHash3(X{j}, z(j)), n) + 1;     % z(i) = random hashCode
    end
    
    if sum(abs(y - z) < eps) == k                       % Admint an error of eps when evaluating equality
       counter = counter + 1;                           % Mark all hi(xi) = z(i)
    end
end

p = counter * n^k / numTests;                           % The closest this value is to 1, the better
if abs(1 - p) < 50                                      % Accepting error
    fprintf('The k - hash functions considered are independent.\n');
else
    fprintf('The k - hash functions considered are not independent.\n');
end
