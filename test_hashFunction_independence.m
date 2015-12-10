% Independance test by prof. Ant?nio Teixeira (adapted)
%% Init
n = 1e5;        % No. strings
Nc = 20;        % No. characters / string
Test_set = generateStrings(n, Nc, 0);
 
%% Hash
N = 1e6;                % No. buckets
k = 10;                  % No. hash-functions
hcodes = zeros(n, k);   % Hash codes
for i = 1:n
    str = Test_set{i};
    for seed = 1:k
        hcodes(i, seed) = mod(FarmHash(str, seed), N);
    end
end

%% aprox joint pmf
clear pmf
divisions = 10;
x = linspace(0, N, divisions);
y = x;
pmfArray = cell(k);
j = 1;

for col1 = 1:k
    values1 = hcodes(:, col1);
    for col2 = col1+1:k
        values2 = hcodes(:, col2);
        pmf = zeros(length(x) - 1, length(x) - 1);
        for i = 1:length(x)-1
            for seed = 1:length(x)-1
                aux = find((values1 >= x(i)) & (values1 < x(i+1))  &  (values2 >= y(i)) & (values2 < y(i+1)));
                pmf(i, seed) = length(aux);
            end
        end
        pmf = pmf/n;
        pmf1 = sum(pmf, 2);
        pmf2 = sum(pmf, 1);
        pmfindep = pmf1 * pmf2;
        pmfArray{col1, col2} = abs(pmfindep-pmf);
        subplot(k / 2, k - 1, j);
        j = j + 1;
        plot(pmfArray{col1, col2});
        title(sprintf('%d & %d', col1, col2));
    end
end

fig = gcf;
set(gcf,'numbertitle','off','name','Independence test between k = k1 & k = k2');