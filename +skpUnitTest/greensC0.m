classdef greensC0 < matlab.unittest.TestCase
%greensC0 is the test class for G0.

% E. Kropf, 2016
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

properties
    dv = [-0.2517+0.3129i; 0.2307-0.4667i]
    qv = [0.2377; 0.1557]
    m = 2

    domain
    innerBdryPoints
    innerPoint
    outerBdryPoints
    outerPoint
    
    prodLevel = 6
    wprod
    g0prod
    g0hatProd
end

methods(TestClassSetup)
    function simpleDomain(test)
        wp = skprod(test.dv, test.qv, test.prodLevel);
        test.wprod = wp;
        test.g0prod = @(z,a) ...
            log(wp(z, a)./wp(z, 1/conj(a))/abs(a))/2i/pi;
        test.g0hatProd = @(z,a) test.g0prod(z, a) ...
            - log((z - a)./(z - 1/conj(a)))/2i/pi;
        
        test.domain = skpDomain(test.dv, test.qv);
        test.innerBdryPoints = boundaryPts(test.domain, 5);
        test.innerPoint = 0.66822-0.11895i;
        test.outerBdryPoints = 1./conj(test.innerBdryPoints(:,2:end));
        test.outerPoint = 1/conj(test.innerPoint);
    end
end

methods(Test)
    function alphaSmallOffBoundary(test)
        alpha = -0.4863-0.37784i;
        g0 = greensC0(alpha, test.domain);
        
        test.compareAllPoints(@(z) test.g0prod(z, alpha), g0, 1e-5)
    end
    
    function alphaSmallOffBoundaryHat(test)
        alpha = -0.4863-0.37784i;
        g0 = greensC0(alpha, test.domain);
        
        test.compareAllPoints(@(z) test.g0hatProd(z, alpha), @g0.hat, 1e-5)
    end
    
    function alphaLargeOffBoundary(test)
        alpha = 1/conj(-0.4863-0.37784i);
        g0 = greensC0(alpha, test.domain);
        
        test.compareAllPoints(@(z) test.g0prod(z, alpha), g0, 1e-5)
    end
    
    function alphaLargeOffBoundaryHat(test)
        alpha = 1/conj(-0.4863-0.37784i);
        g0 = greensC0(alpha, test.domain);
        
        test.compareAllPoints(@(z) test.g0hatProd(z, alpha), @g0.hat, 1e-5)
    end
end

methods
    function compareAllPoints(test, ref, fun, tol)
        testPointCell = {
            test.innerBdryPoints, 'inner boundary'
            test.innerPoint, 'inner point'
            test.outerBdryPoints, 'outer boundary'
            test.outerPoint, 'outer point'
            };
        
        for i = 1:size(testPointCell, 1)
            [z, str] = testPointCell{i,:};
            err = ref(z) - fun(z);
            test.verifyLessThan(max(abs(err(:))), tol, ...
                sprintf('Absolute error > %.1e on %s check.', tol, str))
        end
    end
end

end

























