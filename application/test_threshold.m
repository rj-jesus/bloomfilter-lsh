clear, clc

x = linspace(0.1, 1, 10);
P = zeros(2, 10);

for i = 1:length(x)
    
    threshold = x(i);

    %% Obtain the SPAM testing set

    [Spam, n_files] = test_generic('enron_training.mat', ...
        'enron_spam_datasets/Preprocessed/spam/testing/', '*.txt', ...
        threshold);

    n_Spam = length(Spam);
    p_Spam = n_Spam / n_files;
    P(1, i) = p_Spam;

    %% Obtain the NOT SPAM testing set

    [not_Spam, n_files] = test_generic('enron_training.mat', ...
        'enron_spam_datasets/Preprocessed/ham/testing/',  '*.txt', ...
        threshold);

    n_not_Spam = length(not_Spam);
    p_not_Spam = n_not_Spam / n_files;
    P(2, i) = p_not_Spam;

end

save('test_threshold.mat', 'P')
