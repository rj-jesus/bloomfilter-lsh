classdef BloomFilter < handle
    %BloomFilter Implementation of a simple Bloom-filter
    %   Detailed explanation goes here
    
    properties (Access = private)
        %%%%%
        %   Bloom-Filter related attributes
        %%%%%
        k;                  % k - Number of hash functions
        byteArray;          % Logical array of values
        arraySize;          % n - Size of bit array
        amountAdded;        % Number of elements added
        expectedMaxSize;    % m - Expected maximum size
        debug;              % debug - enable setters to use in tests
        %%%%%
        %   Hash function related attributes
        %       This was taken from http://www.mathworks.com/matlabcentral/fileexchange/45123-data-structures/content/Data%20Structures/Hash%20Tables/HashTable.m
        %%%%%
        % Hash function parameters
        p;                  % hash function parameter
        a;                  % hash function parameter
        b;                  % hash function parameter
        c;                  % hash function parameter
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
            % Initialize hash function
            self.InitHashFunction();
        end
        
        %% Add
        function add(self, str)
            for seed = 1:self.k
                res = self.hash(str, seed);
                self.byteArray(res) = 1;
            end
            self.amountAdded = self.amountAdded + 1;
        end
        
        %% Contains
        function c = contains(self, str)
            for seed = 1:self.k
                res = self.hash(str, seed);
                c = self.byteArray(res);
                if ~c
                    return
                end
            end
        end
        
        %% Hash
        function h = hash(self, str, seed)
            % The function below works but it's too slow
            % h = mod(self.HashCode([str num2str(1:seed, '%d')]), self.arraySize) + 1;
            h = mod(MurmurHash3(str, seed), self.arraySize) + 1;
        end
        
        %% Setters (if debug is on)
        function setArraySize(self, arraySize)
            if self.debug == 1
                self.arraySize = arraySize;
                self.byteArray = uint8(zeros(1, self.arraySize));
            end
        end
        
        function setK(self, k)
            if self.debug == 1
                self.k = k;
            end
        end
    end
    
    methods (Access = private)
        %
        % Initialize hash function
        % 
        % For HashCode() to be universal, the following criteria should be
        % met: 
        % 
        % - Criteria for this.p -
        %   1) this.p is prime
        %   2) this.p > this.m
        %   3) this.p > 75 = #{possible values (alphanumeric) for key(i)}
        %   3) this.p is large compared to ExpectedValue(length(key))
        %
        % - Criteria for randomized parameters -
        %   1) this.a is an integer in [1,...,this.p - 1]
        %   2) this.b is an integer in [0,...,this.p - 1]
        %   3) this.c is an integer in [1,...,this.p - 1]
        %
        function InitHashFunction(self)
            % Set prime parameter
            ff = 1000; % fudge factor
            pp = ff * max(self.arraySize + 1,76);
            pp = pp + ~mod(pp,2); % make odd
            while (isprime(pp) == false)
                pp = pp + 2;
            end
            self.p = pp; % sufficiently large prime number
            
            % Randomized parameters
            self.a = randi([1,(pp - 1)]);
            self.b = randi([0,(pp - 1)]);
            self.c = randi([1,(pp - 1)]);
        end
        
        %
        % Compute the hash code of a given key
        %
        % - Assumptions for key -
        %   1) key(i) is alphanumeric char: {0,...,9,a,...,z,A,...,Z}
        %
        function hk = HashCode(self,key)
            % Convert character array to integer array
            ll = length(key);
            if (ischar(key) == false)
                % Non-character key
                HashTable.KeySyntaxError();
            end
            key = double(key) - 47; % key(i) = [1,...,75]
            
            %
            % Compute hash of integer vector
            %
            % Reference: http://en.wikipedia.org/wiki/Universal_hashing
            %            Sections: Hashing integers
            %                      Hashing strings
            %
            hk = key(1);
            for i = 2:ll
                % Could be implemented more efficiently in practice via bit
                % shifts (see reference)
                hk = mod(self.c * hk + key(i),self.p);
            end
            hk = mod(mod(self.a * hk + self.b,self.p),self.arraySize) + 1;
        end
    end
end
