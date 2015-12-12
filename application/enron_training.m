clear, clc

create_generic('enron_spam_datasets/Preprocessed/spam/training/', ...
    '*.txt', 'enron_training.mat');
