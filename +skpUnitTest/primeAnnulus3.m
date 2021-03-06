classdef primeAnnulus3 < skpUnitTest.primeTestBase
%skpUnitTest.PrimeAnnulus3 gives prime function tests for annular domain.

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

properties(MethodSetupParameter)
    parameterAt = skpUnitTest.domainAnnulus3.parameterLocations()
end

properties
    domainData = skpUnitTest.domainAnnulus3
end

end
