classdef HashFunction < handle
%--------------------------------------------------------------------------
% Class:        HashFunction < handle
%               
% Constructor:  Hf = HashFunction([m]);
%               
% Properties:   (none)
%               
% Methods:      value  = Hf.HashCode(key);
%               
% Indexing:     (no indexing supported)
%               
% Description:  This class implements an universal hash function for 
%               alphanumeric character keys.
%               Adapted from
%                   http://www.mathworks.com/matlabcentral/fileexchange/45123-data-structures/content/Data%20Structures/Hash%20Tables/HashTable.m
%               
% Author:       Brian Moore         edited by   Ricardo Jesus
%               brimoor@umich.edu               ricardojesus at ua dot pt
%               
% Date:         January 16, 2014
%--------------------------------------------------------------------------

    %
    % Private properties
    %
    properties (Access = private)
        m;                  % Maximum hash value
        p;                  % hash function parameter
        a;                  % hash function parameter
        b;                  % hash function parameter
        c;                  % hash function parameter
    end
    
    methods
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
        %   1) this.a is an integer in [1, ..., this.p - 1]
        %   2) this.b is an integer in [0, ..., this.p - 1]
        %   3) this.c is an integer in [1, ..., this.p - 1]
        %
        function self = HashFunction(m)
            % Set m parameter
            if exist('m', 'var')
                self.m = m;
            else
                self.m = 2^64-1;
            end
            % Set prime parameter
            ff = 1000;  % fudge factor
            pp = ff * max(self.m + 1,76);
            pp = pp + ~mod(pp,2);  % make odd
            while (isprime(pp) == false)
                pp = pp + 2;
            end
            self.p = pp;  % sufficiently large prime number
            
            % Randomized parameters
            self.a = randi([1,(pp - 1)]);
            self.b = randi([0,(pp - 1)]);
            self.c = randi([1,(pp - 1)]);
        end
        
        %
        % Compute the hash code of a given key
        %
        % - Assumptions for key -
        %   1) key(i) is alphanumeric char: {[0...9], [a...z], [A...Z]}
        %
        function hk = HashCode(self, key)
            % Convert character array to integer array
            ll = length(key);
            if ~ischar(key)
                error('Keys must be nonempty alphanumeric strings');
            end
            key = double(key) - 47;  % key(i) = [1,...,75]
            
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
                hk = mod(self.c * hk + key(i), self.p);
            end
            hk = mod(mod(self.a * hk + self.b, self.p), self.m) + 1;
        end
    end
    
end

