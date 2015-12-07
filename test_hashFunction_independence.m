clear, clc
%% Independence test
stringSize = 50;
k = 10;
n = 5;	% Hard coding n's value since otherwise n^k will get too close to zero
strSet = unique(generateStrings(k*2, stringSize, 1));       % Generate a unique set of Strings
set = zeros(k, k);





%% Independence test
%%%%%
% > Theoretical intro
% A family of hash functions is k-independent if for any k-distinct keys
% (here x set) and k hash codes not necessarily distinct (here z
% collection) we have:
%   P(h1(x1) = zi AND h2(x2) = z2 AND ... AND hk(xk) = zk) = 1 / n^k
% For more information see: https://en.wikipedia.org/wiki/K-independent_hashing
%%%%%
numTests = 1e7;
stringSize = 50;
k = 10;
n = 5;	% Hard coding n's value since otherwise n^k will get too close to zero

counter = 0;
h = waitbar(0, 'Computing...');
for i = 1:numTests
    waitbar(i/numTests, h);
    strSet = unique(generateStrings(k*2, stringSize, 1));       % Generate a unique set of Strings
    X = zeros(1, k);                                            % Actual values for each hi(xi)
    Y = floor(rand(1, k) * k) + 1;                              % Random hash values for this family of k hash-functions
    seed = ceil(rand * k);
    for j = 1:k
        X(j) = mod(MurmurHash3(strSet{j}, seed), n) + 1;        % y(i) = hi(xi)
        Y(j) = mod(MurmurHash3(strSet{j}, Y(j)), n) + 1;        % z(i) = random hashCode
    end
    
    if sum(abs(X - Y) < eps) == k                               % Admint an error of eps when evaluating equality
       counter = counter + 1;                                   % Mark all hi(xi) = z(i)
    end
end
delete(h)
counter
n^k
p = counter * n^k / numTests                                   % The closest this value is to 1, the better
if abs(1 - p) < 50                                              % Accepting error
    fprintf('The k - hash functions considered are independent.\n');
else
    fprintf('The k - hash functions considered are not independent.\n');
end