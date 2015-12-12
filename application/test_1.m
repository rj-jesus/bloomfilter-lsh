clear, clc

%% Obtain the testing set

threshold = 0.3;
Spam = test_generic('csdmc_training.mat', 'emails_dataset/testing/', ...
    '*.eml', threshold, 'test_1.mat');

n_files_testing = 4292;
n_files_testing_spam = length(Spam);
n_files_training = 4327;
n_files_training_spam = 1378;

% We pretty much have no way to tell if the proportion bellow olds
(n_files_testing_spam / n_files_testing) / ...
    (n_files_training_spam / n_files_training)