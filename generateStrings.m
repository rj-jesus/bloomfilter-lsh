function [Y] = generateStrings(N, l)
%GenerateStrings Generate random Strings
%   Generate N random Strings with random length [1, l]

%% If nargin != 2, do nothing
if nargin ~= 2
    Y = [];
    return
end

%% Else
s = ['0':'9' 'A':'Z' 'a':'z'];              % Symbols available
nS = length(s);                             % Number of available symbols
L = randi(l, 1, N);                         % Length for each String
Y = cell(N, 1);                             % Y := Cell array of Strings
for i = 1:N
    Y{i} = s(ceil(rand(1, L(i)) * nS));
end

end