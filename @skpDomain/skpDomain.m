classdef skpDomain
%skpDomain is the SKPrime domain class.
%
% The skpDomain is defined by the vectors `dv` and `qv`, which represent
% respectively the centers and radii of the circles containted in the unit
% disk.

% Everett Kropf, 2015
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
    dv                          % vector of centers
    qv                          % vector of radii
    m                           % number of circles

    alpha                       % domain parameter point
end

properties(Dependent)
    centers                     % alias for dv
    radii                       % alias for qv
end

properties(Access=private)
    datCell
    datCellB
end

methods
    function D = skpDomain(dv, qv, alpha)
        if ~nargin
            return
        end

        if nargin < 3
            alpha = [];
        end
        if isa(dv, 'skpDomain')
            if nargin > 1
                error('SKPrime:invalidArgument', 'Too many arguments given.')
            end
            alpha = dv.alpha;
            qv = dv.qv;
            dv = dv.dv;
        elseif isa(dv, 'circleRegion')
            if nargin > 2
                error('SKPrime:invalidArgument', 'Too many arguments given.')
            end
            if nargin == 2
                alpha = qv;
            end
            qv = dv.radii(2:end);
            dv = dv.centers(2:end);
        end
        
        if numel(dv) ~= numel(qv)
            error('SKPrime:invalidArgument', ...
                'Number of elements in dv and qv are not the same.')
        end
        if any(imag(qv(:)) ~= 0)
            error('SKPrime:invalidArgument', 'Vector qv is not real.')
        end
        dv = dv(:);
        D.dv = dv;
        qv = qv(:);
        D.qv = qv;
        D.m = numel(dv);

        di = dv./(abs(dv).^2 - qv.^2);
        di(isinf(di)) = nan;
        qi = qv.*abs(di./dv);
        qi(isnan(qi)) = 1./qv(isnan(qi));
        
        D.datCell = {dv, qv, D.m, di, qi};
        D.datCellB = {[0; dv], [1; qv], D.m, di, qi};
        
        if ~isempty(alpha)
            if ~isnumeric(alpha) || numel(alpha) > 1
                error('SKPrime:invalidArgument', ...
                    'The parameter alpha must be a scalar value.')
            end
            D.alpha = skpDomain.normalizeParameter(alpha);
        end
    end
    
    function [zb, tb] = boundaryPts(D, np)
        % Give np evenly spaced points on each boundary.
        %
        % [zb, tb] = boundaryPts(D, np)
        %   np default is 200.
        %   zb is the (np, 2*m+1) array of boundary points.
        %   tb is the size np vector of angles to construct zb.
        
        if nargin < 2
            np = 200;
        end
        
        tb = 2*pi*(0:np-1)/np;
        eit = exp(1i*tb);
        [d, q, ~, di, qi] = domainDataB(D);
        zb = bsxfun(@plus, [d; di], bsxfun(@times, [q; qi], eit)).';
    end
    
    function D = circleRegion(D)
        % Convert to circleRegion if possible.
        
        [d, q, mu] = domainData(D);
        circs = cell(mu+1, 1);
        try
            circs{1} = circle(0, 1);
            for j = 2:mu+1
                circs{j} = circle(d(j-1), q(j-1));
            end
            D = circleRegion(circs{:});
        catch me
            if strcmp(me.identifier, 'MATLAB:UndefinedFunction')
                skpDomain.cmtError('circle or circleRegion')
            else
                rethrow(me)
            end
        end
    end
    
    function [dv, qv, m, di, qi] = domainData(D)
        [dv, qv, m, di, qi] = deal(D.datCell{:});
    end
    
    function [dv, qv, m, di, qi] = domainDataB(D)
        [dv, qv, m, di, qi] = deal(D.datCellB{:});
    end
    
    function je = isclose(D, alpha)
        %isclose gives inner boundary indices for a close parameter.
        
        [d, q] = domainData(D);
        if abs(alpha) < 1
            je = abs(alpha - d);
        elseif abs(alpha) > 1
            je = abs(1/conj(alpha) - d);
        end
        je = find(q + eps(2) < je & je < q + 0.15);
        je = je(:)';
    end
    
    function tf = isin(D, z)
        tf = true(size(z));
        tf(abs(z) >= 1) = false;
        
        [d, q, mu] = domainData(D);
        for j = 1:mu
            tf(abs(z - d(j)) <= q(j)) = false;
        end
    end
    
    function out = plot(D, varargin)
        D = circleRegion(D);
        if nargout
            out = plot(D, varargin{:});
        else
            plot(D, varargin{:})
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function d = get.centers(D)
        d = D.dv;
    end
    
    function q = get.radii(D)
        q = D.qv;
    end    
end

methods(Static)
    function param = normalizeParameter(param)
        if 0 < abs(param) && abs(param) < eps
            param = 0;
            warning('SKPrime:normalising', ...
                'Treating "small" alpha as zero.')
        elseif ~isinf(param) && 1/eps < abs(param)
            param = inf;
            warning('SKPrime:normalising', ...
                'Treating "large" alpha as infinity.')
        end
    end
end

methods(Access=private, Static)
    function cmtError(objstr)
        error('SKPrime:runtimeError', ['Unable to construct %s. ' ...
            'Install the CMT for this functionality.'], objstr)
    end
end

end