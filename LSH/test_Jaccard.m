clear, clc
N = 1e7;                % number of strings
L = 5;                  % length of strings
rnd = 0;                % fixed length
expectedError = 0.05;   % expected error for Jaccard Similarity

fprintf('Generating %d strings for set A... ', N);
A = generateStrings(N, L, rnd);
fprintf('Completed.\n');
fprintf('Generating %d strings for set B... ', N);
B = generateStrings(N, L, rnd);
fprintf('Completed.\n');

fprintf('Creating a MinHash object for an error of %f... ', expectedError);
MH = MinHash(expectedError);
fprintf('Completed.\n');

fprintf('Computing real Jaccard Similarity... ');
J_t = length(intersect(A, B)) / length(union(A, B));
fprintf('Completed.\n');
fprintf('Computing experimental Jaccard Similarity... ');
J_e = MH.Jaccard(A, B);
fprintf('Completed.\n');

fprintf('Real result: %f\n', J_t);
fprintf('Experimental result: %f\n', J_e);
observed_error = abs(J_e - J_t);

fprintf('Admissible error was %f, we were off by %f and so... ', ...
    expectedError, observed_error);
if observed_error <= expectedError
    fprintf('We got it right!\n');
else
    fprint('We should improve our project.\n');
end