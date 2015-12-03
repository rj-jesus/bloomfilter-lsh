classdef MinHash < handle
%--------------------------------------------------------------------------
% Class:        MinHash < handle
%               
% Constructor:  MH = MinHash(expectedError[, debug]);
%               
% Properties:   (none)
%               
% Methods:      double  MH.Jaccard(A, B);
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
        function self = MinHash(expectedError, debug)
            % the result bellow for k is given by Chernoff Bounds. See
            % 	https://en.wikipedia.org/wiki/Chernoff_bound
            % or more specifically
            %   https://en.wikipedia.org/wiki/MinHash#Variant_with_a_single_hash_function
            % Result:
            %   k >= 1 / eps^2
            self.k = ceil(1 / expectedError^2);
            if exist('debug', 'var')
                self.debug = debug;
            end
        end
        
        %% Similarity
        function J = similarity(self, A, B)
            Sa = uint64(ones(self.k, 1)) * intmax('uint64');
            Sb = uint64(ones(self.k, 1)) * intmax('uint64');
            
            for i = 1:length(A)
                str = A{i};
                for seed = 1:self.k
                    Sa(seed) = min(MurmurHash3(str, seed), Sa(seed));
                end
            end
            
            for i = 1:length(B)
                str = B{i};
                for seed = 1:self.k
                    Sb(seed) = min(MurmurHash3(str, seed), Sb(seed));
                end
            end
%             for seed = 1:self.k
%                 min_h = intmax('uint64');
%                 for i = 1:length(A)
%                     h = MurmurHash3(A{i}, seed);
%                     if h < min_h
%                         min_h = h;
%                     end
%                 end
%                 Sa(seed) = min_h;
%                 min_h = intmax('uint64');
%                 for i = 1:length(B)
%                     h = MurmurHash3(B{i}, seed);
%                     if h < min_h
%                         min_h = h;
%                     end
%                 end
%                 Sb(seed) = min_h;
%             end
            y = length(intersect(Sa, Sb));
            J = y / self.k;
        end
        
        %% Jaccard
        function J = Jaccard(self, A, B)
            H = uint64(zeros(1, length(A)));
            for i = 1:length(A)
                H(i) = MurmurHash3(A{i}, 0);
            end
            H = unique(H);
            Sa = H(1:self.k);   % signature of A
            H = uint64(zeros(1, length(B)));
            for i = 1:length(B)
                H(i) = MurmurHash3(B{i}, 0);
            end
            H = unique(H);
            Sb = H(1:self.k);   % signature of B
            H = sort(union(Sa, Sb));
            Sx = H(1:self.k);   % signature of A UNION B
            y = length(intersect(Sx, intersect(Sa, Sb)));
            J = y / self.k;
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
end
