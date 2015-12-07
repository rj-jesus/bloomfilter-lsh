function [Y] = generateStrings(N, l, rnd)
%GenerateStrings Generate random Strings
%   Generate N random Strings with random length [1, l]
%   If rnd is 0, generate N random Strings with length l
%   Else String have random length [1, l]

%% If nargin != 2, do nothing
if nargin ~= 3
    Y = [];
    return
end

%% Else
s = ['0':'9' 'A':'Z' 'a':'z'];              % Symbols available
nS = length(s);                             % Number of available symbols
if rnd == 0
    L = zeros(N, 1) + l;                    % Length for each String (random)
else
    L = randi(l, 1, N);                     % Length for each String (fixed == l)
end
Y = cell(N, 1);                             % Y := Cell array of Strings
for i = 1:N
    Y{i} = s(ceil(rand(1, L(i)) * nS));
end

end