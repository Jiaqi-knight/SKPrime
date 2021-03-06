classdef skpindisk < skpfunction
%skpindisk is the SKPrime function for the parameter in a 1st level
%refelction of the domain.

% Everett Kropf, 2016
% 
% This file is part of SKPrime.
% 
% SKPrime is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% SKPrime is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with SKPrime.  If not, see <http://www.gnu.org/licenses/>.

properties(SetAccess=protected)
    diskParameter
    indisk
    
    hejhal
    rootHejhal
end

properties(Access=private)
    inunit
end

methods
    function skp = skpindisk(alpha, varargin)
        if nargin
            %  1) Process arguments.
            D = skpfunction.parseArguments(varargin{:});
            
            %  2) Use domain and parameter to determine disk and auxiliary
            %  parameter.
            alpha = skpParameter(alpha, D);
            ja = alpha.indisk;
            if alpha.state == paramState.innerDisk
                beta = D.theta(ja, 1/conj(alpha));
                isInUnit = true;
            elseif alpha.state == paramState.outerDisk
                beta = D.theta(ja, alpha);
                isInUnit = false;
            else
                error('SKPrime:invalidArgument', ...
                    'The parameter is not in an inner or outer disk.')
            end
            beta = 1/conj(beta);

        end
        
        %  3) Use auxiliary parameter to call superclass constructor.
        skp = skp@skpfunction(beta, varargin{:});
        if ~nargin
            return
        end
        
        skp.diskParameter = alpha;
        skp.indisk = ja;
        skp.inunit = isInUnit;
        
        vj = skp.vjFuns{ja};
        taujj = vj.taujj;
        dj = D.centers(ja);
        qj = D.radii(ja);
        skp.hejhal = @(z) exp(-4i*pi*(vj(beta) - vj(z) + taujj/2)) ...
            *qj^2/(1 - conj(dj)*beta)^2;
        skp.rootHejhal = @(z) -exp(-2i*pi*(vj(beta) - vj(z) + taujj/2)) ...
            *qj/(1 - conj(dj)*beta);
    end
    
    function v = feval(skp, z)
        %Evaluate prime function.
        
        if skp.inunit
            v = feval@skpfunction(skp, z).*skp.rootHejhal(z);
        else
            invz = 1./conj(z);
            v = -(z/conj(skp.domain.theta(skp.indisk, skp.parameter))) ...
                .*conj(feval@skpfunction(skp, invz).*skp.rootHejhal(invz));
        end
    end
    
    function v = hat(skp, z)
        %Prime "hat" function.
        
        v = feval(skp, z)./(z - skp.diskParameter);
    end
    
    function v = X(skp, z)
        %Square of the prime function.
        
        if skp.inunit
            v = X@skpfunction(skp, z).*skp.hejhal(z);
        else
            invz = 1./conj(z);
            v = (z/conj(skp.domain.theta(skp.indisk, skp.parameter))).^2 ...
                .*conj(X@skpfunction(skp, invz).*skp.hejhal(invz));
        end
    end
    
    function v = Xhat(skp, z)
        %Square of the prime hat function.
        
        v = X(skp, z)./(z - skp.diskParameter).^2;
    end
end

end
