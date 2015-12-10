% Independance test by prof. António Teixeira (adapted)
%% Init
n = 1e5;        % No. strings
Nc = 20;        % No. characters / string
Test_set = generateStrings(n, Nc, 0);
 
%% Hash
N = 1e6;                % No. buckets
% Hf = HashFunction(N);
k = 4;                  % No. hash-functions
hcodes = zeros(n, k);   % Hash codes
for i = 1:n
    str = Test_set{i};
    for seed = 1:k
%         str = [str num2str(seed)];
%         hcodes(i, seed) = Hf.HashCode(str);
        hcodes(i, seed) = mod(FarmHash(str, seed), N);
    end
end
%% aprox joint pmf
clear pmf
% consider 10 x 10
divisions = 10;
x = linspace(0, N, divisions);
y = x;
col1 = 1;   % to control which hash functions to compare
col2 = 4; 
values1 = hcodes(:, col1);
values2 = hcodes(:, col2);
pmf = zeros(length(x)-1, length(x)-1);
for i = 1:length(x)-1
    for seed=1:length(x)-1
        aux = find((values1 >= x(i)) & (values1 < x(i+1))  &  (values2 >= y(i)) & (values2 < y(i+1)));
        pmf(i, seed) = length(aux);
    end
end
pmf = pmf/n;
figure(1)
subplot(231); bar3(pmf);
pmf1 = sum(pmf, 2);
pmf2 = sum(pmf, 1);
subplot(234); stem(pmf1);
subplot(235); stem(pmf2);
pmfindep = pmf1 * pmf2;
subplot(232); bar3(pmfindep);
subplot(233); surf(abs(pmfindep-pmf));