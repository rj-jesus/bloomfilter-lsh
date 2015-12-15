classdef LSH < handle
%--------------------------------------------------------------------------
% Class:        LSH < handle
%               
% Constructor:  Lsh = LSH(expectedError[, debug])
%               
% Properties:   (none)
%               
% Methods:      uint64[]	Lsh.signature(Shingles)
%               cell        Lsh.candidates(Signatures, threshold)
%               cell        Lsh.candidates_to(Sig_X, Signatures, threhsold)
%               double[]    Lsh.similars(Candidates, Signatures, threshold)
%               double[]	Lsh.similars_to(Sig_X, Cands, Sigs, threhold)
%               double      Lsh.getK()
%               (static)
%               cell        Lsh.shingleWords(Set)
%               
% Description:  This class allows nearest neighbor search and data
%               clustering (preferably of documents) by using word
%               shingling (with stopping words) to create workable
%               representations of documents, for which a signature can be
%               generated with the technique of Many Hash (case of
%               MinHash). Matrixes with this signatures can later be
%               processed for finding nearest neighbors and clustering by
%               similar items.
%               Uses FarmHash interfaced through a MEX file to generate
%               signatures for the shingles. It thus needs to be compiled
%               (generating a .mexa64 for Linux). For this please run
%               >> mex FarmHash.cpp
%               
% Authors:      Pedro Martins               Ricardo Jesus
%               pbmartins (at) ua (dot)     ricardojesus (at) ua (dot) pt
%               
% Date:         November 29, 2015
%--------------------------------------------------------------------------
    
    properties (Access = private)
        k;      % k - Number of hash functions
        debug;	% enable setters (used in tests)
    end
    
    methods
        %% Constructor
        function self = LSH(expectedError, debug)
            % The result bellow for k is given by the Chernoff Bounds. See
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
        function [S] = signature(self, Shingles)
            S = ones(self.k, 1, 'uint64') * intmax('uint64');
            for seed = 1:self.k
                S(seed) = min(FarmHash(Shingles, seed));
            end
        end
        
        %% Candidates
        function [Candidates] = candidates(self, Signatures, threshold)
            r = 1;                  % #Rows
            while (r / self.k) ^ (1 / r) < threshold
                r = r + 1;
            end
            b = floor(self.k / r);	% #Bands
            % Candidates' structure is as follows
            % this --sim--> that
            % Doc1          { [DocA DocB DocC ...]
            % Doc2            [DocI DocJ DocK ...]
            % ...              ...
            % DocN            [DocX DocY DocZ ...] }
            Candidates = cell(size(Signatures, 2), 1);
            for i = 1:b
                % Strip this band from the Signatures' matrix
                Band = Signatures(1 + (i-1)*r:i*r, :);
                for j = 1:size(Signatures, 2)-1
                    % Get Doc{Y...} which 'match' this Doc{X}
                    [~, cols] = find(sum(ismember(Band(:, j+1:end), ...
                        Band(:, j))) == r);
                    cols = j + unique(cols(:))';
                    Candidates{j} = unique([Candidates{j} cols]);
                end
            end
        end
        
        %% Candidates to Document
        function [Candidates] = candidates_to(self, Signature_A, ...
                Signatures, threshold)
            r = 1;  % #Rows
            while (r / self.k) ^ (1 / r) < threshold
                r = r + 1;
            end
            b = floor(self.k / r);   % #Bands
            % Candidates' structure is as follows
            % this --sim--> that
            % Doc1          { [DocA DocB DocC ...] }
            Candidates = cell(1);
            for i = 1:b
                % Strip this band from the Signatures' matrix
                Band_sig = Signature_A(1 + (i-1)*r:i*r);
                Band_sigs = Signatures(1 + (i-1)*r:i*r, :);
                % Get Doc{Y...} which 'match' this Doc{X}
                [~, cols] = find(sum(ismember(Band_sigs, ...
                    Band_sig)) == r);
                cols = unique(cols(:))';
                Candidates{1} = unique([Candidates{1} cols]);
            end
        end
        
        %% Similars
        function [Similars] = similars(self, Candidates, Signatures, ...
                threshold)
            % Similars' structure is as follows
            %   this --sim--> this --with--> this similatiry
            % [ Doc1          DocA           sim(Doc1, DocA)
            %   Doc1          DocB           sim(Doc1, DocB)
            %   ...           ...            ...
            %   Doc2          DocA           sim(Doc2, DocA)
            %   ...           ...            ...
            %   DocN          DocZ           sim(DocN, DocZ) ]
            % Forall sets in the candidates matrix for which
            %   sim(DocN, DocX) >= threshold
            Similars = zeros(length(Candidates), 3);
            idx = 1;
            for i = 1:length(Candidates)
                % Candidates to Doc{i}
                Candidates_i = Candidates{i};
                % Signature of Doc{i}
                Signature_A = Signatures(:, i);
                for j = 1:length(Candidates_i)
                    % Candidate Doc{j} to Doc{i}
                    Candidate = Candidates_i(j);
                    % Signature of Doc{j}
                    Signature_B = Signatures(:, Candidate);
                    % sim = sim(Sig{i}, Sig{j})
                    sim = length(intersect(Signature_A, Signature_B)) ...
                        / self.k;
                    if sim >= threshold
                        Similars(idx, :) = [i Candidate sim];
                        idx = idx + 1;
                    end
                end
            end
            Similars = Similars(1:idx-1, :);
        end
        
        %% Similars to Document
        function [Similars] = similars_to(self, Signature_X, ...
                 Candidates, Signatures, threshold)
            % Similars' structure is as follows
            %   this --sim--> this --with--> this similatiry
            %   DocX        [ Doc1           sim(DocX, Doc1)
            %   DocX          Doc2           sim(DocX, Doc2)
            %   ...           ...            ...
            %   DocX          DocN           sim(DocX, DocN) ]
            % Forall sets in the candidates matrix for which
            %   sim(DocX, DocN) >= threshold
            Similars = zeros(length(Candidates), 2);
            idx = 1;
            for j = 1:length(Candidates)
                % Candidate Doc{j} to DocX
                Candidate = Candidates(j);
                % Signature of Doc{j}
                Signature_B = Signatures(:, Candidate);
                % sim = sim(DocX, Doc{j})
                sim = length(intersect(Signature_X, Signature_B)) ...
                    / self.k;
                if sim >= threshold
                    Similars(idx, :) = [Candidate sim];
                    idx = idx + 1;
                end
            end
            Similars = Similars(1:idx-1, :);
        end
        
        %% Getters
        function k = getK(self)
            k = self.k;
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
            % might fail, but then it shouldn't be being used in the first
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
            % Counter for S{j}
            j = 1;
            % Pre-allocate memory
            S = cell(length(Doc), 1);
            for i = 1:length(Doc)-2
                if any(strcmpi(stop_words, Doc{i}))
                    S{j} = strjoin(Doc(:, i:i+2));
                    j = j + 1;
                end
            end
            S = unique(S(1:j-1));
        end
    end
end
