classdef BloomFilter < handle
%--------------------------------------------------------------------------
% Class:        BloomFilter < handle
%               
% Constructor:  Bf = BloomFilter((falsePositiveProbability, ...
%   expectedMaxSize[, debug]);
%               
% Properties:   (none)
%               
% Methods:      void    Bf.add(str);
%               bool    Bf.contains(str);
%               ***** Not implemented / not tested *****
%               void    Bf.remove(str);
%                   > If Bf.minCount(str) == 0 || Bf.maxCount(str) == 255,
%                   then no action will be taken. The reason for 0 is
%                   obvious ('str' is not in the filter), the reason for
%                   255 is simply because in this implementation false
%                   negatives are not allowed
%               int     Bf.count(str);
%               int     Bf.maxCount(str)
%               int     Bf.minCount(str)
%               
% Indexing:     The following 'get' indexing is supported:
%               
%               count = Bf(str);
%               > this is commented out for performance issues
%               
% Description:  This class implements a counting Bloom filter table with
%               alphanumeric character keys. Uses MurmurHash3 interfaced
%               through a MEX file to generate hashes for the keys. It thus
%               needs a compiled (.mexa64) version of MurmurHash3. For this
%               please run
%               >> mex MurmurHash3.cpp
%               
% Authors:      Pedro Martins,  Ricardo Jesus
%                               ricardojesus@ua.pt
%               
% Date:         November 26, 2015
%--------------------------------------------------------------------------
    
    properties (Access = private)
        %%%%%
        %   Bloom filter related attributes
        %%%%%
        k;                  % k - Number of hash functions
        byteArray;          % count array - counts up to 2^8-1 = 255
        arraySize;          % n - Size of bit array
        amountAdded;        % Number of elements added
        expectedMaxSize;    % m - Expected maximum size
        debug;              % enable setters (used in tests)
%         %%%%%
%         %   Hash function related attributes - ***** No longer used! *****
%         %       This was taken from http://www.mathworks.com/matlabcentral/fileexchange/45123-data-structures/content/Data%20Structures/Hash%20Tables/HashTable.m
%         %%%%%
%         % Hash function parameters
%         p;                  % hash function parameter
%         a;                  % hash function parameter
%         b;                  % hash function parameter
%         c;                  % hash function parameter
    end
    
    methods
        %% Constructor
        function self = BloomFilter(falsePositiveProbability, expectedMaxSize, debug)
            self.expectedMaxSize = expectedMaxSize;
            self.amountAdded = 0;
            % n = m * ln(1 / p) / (ln(2)) ^ 2
            self.arraySize = ceil(expectedMaxSize * log(1 / falsePositiveProbability) / (log(2)) ^ 2);
            self.byteArray = uint8(zeros(1, self.arraySize));
            % k = n * ln(2) / m
            self.k = ceil(self.arraySize * log(2) / expectedMaxSize);
            if exist('debug', 'var')
                self.debug = debug;
            end
%             % Initialize hash function
%             self.InitHashFunction();
        end
        
        %% Add
        function add(self, str)
            idx = self.getIndexes(str);
            self.byteArray(idx) = self.byteArray(idx) + 1;
            self.amountAdded = self.amountAdded + 1;
%             for s = cellstr(str)
%                 idx = self.getIndexes(s{:});
%                 self.byteArray(idx) = self.byteArray(idx) + 1;
%                 self.amountAdded = self.amountAdded + 1;
%             end
        end
        
        %% Contains
        function c = contains(self, str)
            c = all(self.byteArray(self.getIndexes(str)));
        end
        
        %% Count
        function c = count(self, str)
            c = min(self.byteArray(self.getIndexes(str)));
        end
        
        %% Remove
        function remove(self, str)
            idx = self.getIndexes(str);
            if min(self.byteArray(idx)) > 0 && max(self.byteArray(idx)) < 255
                self.byteArray(idx) = self.byteArray(idx) - 1;
                self.amountAdded = self.amountAdded - 1;
            end
        end
        
        %% MaxCount
        function c = maxCount(self, str)
            c = max(self.byteArray(self.getIndexes(str)));
        end
        
        %% MinCount
        function c = minCount(self, str)
            c = min(self.byteArray(self.getIndexes(str)));
        end
        
%         %% Define () for ByteArray element referencing
%         
%         function varargout = subsref(self, S)
%             %------------------- ()-based reference -----------------------
%             % Syntax:       count = Bf(str);
%             %               
%             % Inputs:       str is an alphanumeric character array
%             %               
%             % Outputs:      count is the object associated with the
%             %               str as computed by Bf.count(str)
%             %               
%             % Description:  Returns the count of str as would Bf.count(str)
%             %--------------------------------------------------------------
%             
%             switch S(1).type
%                 case '()'
%                     % User is getting a ByteArray element
%                     str = S(1).subs{1};
%                     varargout{1} = self.count(str);
%                 case '{}'
%                     % {}-indexing is not supported
%                     error('{} not supported for Bloom filter indexing. Please use () instead.');
%                 case '.'
%                     % Call built-in reference method
%                     if (isprop(self, S(1).subs) || (nargout(['BloomFilter>BloomFilter.' S(1).subs]) > 0))
%                         % Doesn't assign output args >= 2, if they exist
%                         varargout{1} = builtin('subsref', self, S);
%                     else
%                         builtin('subsref', self, S);
%                     end
%             end
%         end
        
        %% Setters (if debug is on)
        function setArraySize(self, arraySize)
            if self.debug
                self.arraySize = arraySize;
                self.byteArray = uint8(zeros(1, self.arraySize));
            end
        end
        
        function setK(self, k)
            if self.debug
                self.k = k;
            end
        end
    end
    
    methods (Access = private)
%         %% Hash
%         function h = hash(self, str, seed)
%             % The function below works but it's too slow
%             % h = mod(self.HashCode([str num2str(1:seed, '%d')]), self.arraySize) + 1;
%             h = mod(MurmurHash3(str, seed), self.arraySize) + 1;
%         end
        
        %% Indexer
        function [h] = getIndexes(self, str)
            h = zeros(1, self.k);
            for seed = 1:self.k
                h(seed) = mod(MurmurHash3(str, seed), self.arraySize) + 1;
            end
        end
        
%         %%
%         % Initialize hash function - ***** No longer used! *****
%         % 
%         % For HashCode() to be universal, the following criteria should be
%         % met: 
%         % 
%         % - Criteria for this.p -
%         %   1) this.p is prime
%         %   2) this.p > this.m
%         %   3) this.p > 75 = #{possible values (alphanumeric) for key(i)}
%         %   3) this.p is large compared to ExpectedValue(length(key))
%         %
%         % - Criteria for randomized parameters -
%         %   1) this.a is an integer in [1,...,this.p - 1]
%         %   2) this.b is an integer in [0,...,this.p - 1]
%         %   3) this.c is an integer in [1,...,this.p - 1]
%         %
%         function InitHashFunction(self)
%             % Set prime parameter
%             ff = 1000; % fudge factor
%             pp = ff * max(self.arraySize + 1,76);
%             pp = pp + ~mod(pp,2); % make odd
%             while (isprime(pp) == false)
%                 pp = pp + 2;
%             end
%             self.p = pp; % sufficiently large prime number
%             
%             % Randomized parameters
%             self.a = randi([1,(pp - 1)]);
%             self.b = randi([0,(pp - 1)]);
%             self.c = randi([1,(pp - 1)]);
%         end
%         
%         %
%         % Compute the hash code of a given key
%         %
%         % - Assumptions for key -
%         %   1) key(i) is alphanumeric char: {0,...,9,a,...,z,A,...,Z}
%         %
%         function hk = HashCode(self,key)
%             % Convert character array to integer array
%             ll = length(key);
%             if (ischar(key) == false)
%                 % Non-character key
%                 HashTable.KeySyntaxError();
%             end
%             key = double(key) - 47; % key(i) = [1,...,75]
%             
%             %
%             % Compute hash of integer vector
%             %
%             % Reference: http://en.wikipedia.org/wiki/Universal_hashing
%             %            Sections: Hashing integers
%             %                      Hashing strings
%             %
%             hk = key(1);
%             for i = 2:ll
%                 % Could be implemented more efficiently in practice via bit
%                 % shifts (see reference)
%                 hk = mod(self.c * hk + key(i),self.p);
%             end
%             hk = mod(mod(self.a * hk + self.b,self.p),self.arraySize) + 1;
%         end
    end
end
