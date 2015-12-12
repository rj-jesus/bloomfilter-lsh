clear, clc

%% Obtain the traning set

threshold = 0.3;

%% Obtain the SPAM testing set

[Spam, n_files] = test_generic('enron_training.mat', ...
    'enron_spam_datasets/Preprocessed/spam/testing/', '*.txt', threshold);

n_Spam = length(Spam);
p_Spam = n_Spam / n_files;
fprintf('Got %d of %d SPAM messages. P = %f\n', n_Spam, n_files, p_Spam);

%% Obtain the NOT SPAM testing set

[not_Spam, n_files] = test_generic('enron_training.mat', ...
    'enron_spam_datasets/Preprocessed/ham/testing/',  '*.txt', threshold);

n_not_Spam = length(not_Spam);
p_not_Spam = n_not_Spam / n_files;
fprintf('Got %d of %d NOT SPAM messages. P = %f\n', n_not_Spam, ...
    n_files, p_not_Spam);

%% Save variables

save('test_3.mat', 'Spam', 'not_Spam');