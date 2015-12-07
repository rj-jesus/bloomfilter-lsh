classdef LSH < handle
%--------------------------------------------------------------------------
% Class:        MinHash < handle
%               
% Constructor:  LSH = LSH(expectedError[, debug]);
%               
% Properties:   (none)
%               
% Methods:      double  MH.Jaccard(A, B);
%               (static)
%               cell    MinHash.shingleWords(Set)
%               
% Indexing:     No indexing supported
%               
% Description:  This class allows the estimation of the Jaccard
%               similarities through the means of Single Hash (case of
%               MinHash) for sets of alphanumeric character strings. Uses
%               MurmurHash3 interfaced through a MEX file to generate
%               hashes for the keys. It thus needs a compiled (.mexa64)
%               version of MurmurHash3. For this please run
%               >> mex MurmurHash3.cpp
%               
% Authors:      Pedro Martins,  Ricardo Jesus
%                               ricardojesus@ua.pt
%               
% Date:         November 29, 2015
%--------------------------------------------------------------------------
    
    properties (Access = private)
        k;                  % k - Number of hash functions
        debug;              % enable setters (used in tests)
    end
    
    methods
        %% Constructor
        function self = LSH(expectedError, debug)
            % the result bellow for k is given by Chernoff Bounds. See
            %   https://en.wikipedia.org/wiki/MinHash
            % or more specifically
            % 	https://en.wikipedia.org/wiki/Chernoff_bound
            % Result:
            %   k >= 1 / eps^2
            self.k = ceil(1 / expectedError^2);
            if exist('debug', 'var')
                self.debug = debug;
            end
        end
        
        %% Minhash Signatures
        function [S] = singnature(self, Shingles)
            S = uint64(ones(self.k, 1)) * intmax('uint64');
            for i = 1:length(Shingles)
                for seed = 1:self.k
                    %S(seed) = min(S(seed), MurmurHash3(Shingles{i}, seed));
                    S(seed) = min(S(seed), string2hash(Shingles{i}));
                end
            end
        end
        
        %% Banding
        function [Candidates] = candidates(self, Signatures, threshold)
            % #Rows
            r = 1;
            while (r / self.k) ^ (1 / r) < threshold
                r = r + 1;
            end
            % #Bands
            b = floor(self.k / r);
            % Candidates' structure is as follows
            % this --sim--> that
            % Doc1          { [DocA DocB DocC ...]
            % Doc2            [DocI DocJ DocK ...]
            % ...              ...
            % DocN            [DocX DocY DocZ ...] }
            Candidates = cell(length(Signatures)-1, 1);
            for i = 1:b
                % Strip this band from the Signatures' matrix
                Band = Signatures(1 + (i-1)*r:i*r, :);
                for j = 1:length(Signatures)-1
                    % Get Doc{Y...} which 'match' this Doc{X}
                    [~, cols] = find(ismember(Band(:, j+1:end), ...
                        Band(:, j)));
                    cols = j + unique(cols)';
                    Candidates{j} = unique([Candidates{j} cols]);
                end
            end
        end
        
        %% Setters (if debug is on)
        function setK(self, k)
            if self.debug
                self.k = k;
            end
        end
    end
    
    methods (Access = private)
        
    end
    
    methods (Static)
        %% Shingles built from words
        function [S] = shingleWords(Doc)
            % > Disclaimer: In case of a small Doc[ument] this shingling
            % might fail, but then it shouldn't be being used in first
            % place... Not considering such cases.
            
            % 100 Most Common Words from
            %   https://www.englishclub.com/vocabulary/common-words-100.htm
            stop_words = {'the', 'be', 'to', 'of', 'and', 'a', 'in', ...
                'that', 'have', 'I', 'it', 'for', 'not', 'on', 'with', ...
                'he', 'as', 'you', 'do', 'at', 'this', 'but', 'his', ...
                'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or', ...
                'an', 'will', 'my', 'one', 'all', 'would', 'there', ...
                'their', 'what', 'so', 'up', 'out', 'if', 'about', ...
                'who', 'get', 'which', 'go', 'me', 'when', 'make', ...
                'can', 'like', 'time', 'no', 'just', 'him', 'know', ...
                'take', 'person', 'into', 'year', 'your', 'good', ...
                'some', 'could', 'them', 'see', 'other', 'than', ...
                'then', 'now', 'look', 'only', 'come', 'its', 'over', ...
                'think', 'also', 'back', 'after', 'use', 'two', 'how', ...
                'our', 'work', 'first', 'well', 'way', 'even', 'new', ...
                'want', 'because', 'any', 'these', 'give', 'day', ...
                'most', 'us'};
            % Counter for S{k}
            k = 1;
            % Pre-allocate memory
            S = cell(length(Doc), 1);
            for i = 1:length(Doc)-2
                if any(strcmpi(stop_words, Doc{i}))
                    S{k} = strjoin(Doc(:, i:i+2));
                    k = k + 1;
                end
            end
            S = unique(S(1:k-1));
        end
        
    end
end
