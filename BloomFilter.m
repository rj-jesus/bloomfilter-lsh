classdef BloomFilter
    %BloomFilter Implementation of a simple Bloom-filter
    %   Detailed explanation goes here
    
    properties
        k;                  % k - Number of hash functions
        byteArray;          % Logical array of values
        arraySize;          % m - Size of bit array
        amountAdded;        % Number of elements added
        expectedMaxSize;    % n - Expected maximum size
    end
    
    methods
        %% Constructor
        function obj = BloomFilter(falsePositiveProbability, expectedMaxSize)
            obj.expectedMaxSize = expectedMaxSize;
            obj.amountAdded = 0;
            % m = n * ln(1 / p) / (ln(2)) ^ 2
            obj.arraySize = ceil(expectedMaxSize * log(1 / falsePositiveProbability) / (log(2)) ^ 2);
            obj.byteArray = uint8(zeros(1, obj.arraySize));
            % k = m * ln(2) / n
            obj.k = ceil(obj.arraySize * log(2) / expectedMaxSize);
        end
        
        %% Add
        function self = add(self, str)
            for seed = 1:self.k
                res = mod(self.hash(str, seed), self.arraySize) + 1;
                self.byteArray(res) = 1;
            end
            self.amountAdded = self.amountAdded + 1;
        end
        
        %% Contains
        function c = contains(self, str)
            for seed = 1:self.k
                res = mod(self.hash(str, seed), self.arraySize) + 1;
                c = self.byteArray(res);
                if ~c
                    return
                end
            end
        end

    end
    
    methods(Static)
        %% Hash
        function [h] = hash(str, seed)
            h = string2hash([str 1:seed]);
        end
    end
    
end
