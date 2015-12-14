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
%               ***** not well tested *****
%               void    Bf.remove(str);
%               int     Bf.count(str);
%               int     Bf.maxCount(str)
%               int     Bf.minCount(str)
%               
% Description:  This class implements a counting Bloom-filter with
%               alphanumeric character keys. Uses FarmHash interfaced
%               through a MEX file to generate hashes for the keys. It thus
%               needs a compiled (.mexa64 for Linux) version of FarmHash.
%               For this please run
%               >> mex FarmHash.cpp
%               
% Authors:      Pedro Martins               Ricardo Jesus
%               pbmartins (at) ua (dot) pt  ricardojesus (at) ua (dot) pt
%               
% Date:         November 26, 2015
%--------------------------------------------------------------------------
    
    properties (Access = private)
        k;                  % k - Number of hash functions
        byteArray;          % count array - counts up to 2^8-1 = 255
        arraySize;          % n - Size of bit array
        amountAdded;        % Number of elements added
        expectedMaxSize;    % m - Expected maximum size
        debug;              % enable setters (used in tests)
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
        end
        
        %% Add
        function add(self, str)
            idx = self.getIndexes(str);
            self.byteArray(idx) = self.byteArray(idx) + 1;
            self.amountAdded = self.amountAdded + 1;
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
        %% Indexer
        function [h] = getIndexes(self, str)
            h = zeros(1, self.k);
            for seed = 1:self.k
                h(seed) = mod(FarmHash(str, seed), self.arraySize) + 1;
            end
        end
    end
end
