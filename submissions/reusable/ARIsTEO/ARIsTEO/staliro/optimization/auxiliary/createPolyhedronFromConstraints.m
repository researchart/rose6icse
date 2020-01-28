% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ P ] = createPolyhedronFromConstraints( lb, ub, A, b )
%CREATEPOLYHEDRONFROMCONSTRAINTS Creates a polyhedron from the inputs
%constraints. 
%   x | Ax <= b, lb <= x <= ub
%
% (C) 2015, C. Erkan Tuncali, Arizona State University

if nargin == 2
    P = Polyhedron('lb', lb, 'ub', ub);
elseif nargin == 4
    P = Polyhedron('A', A, 'b', b, 'lb', lb, 'ub', ub);
else
    error(' createPolyhedronFromConstraints : unexpected number of inputs !');
end

% GF: No need to check we have hypercube constraints anyway
% assert(P.isBounded, ' createPolyhedronFromConstraints : created polyhedron is unbounded !');
%if P.volume < 0.00001
%    warning(' createPolyhedronFromConstraints : created polyhedron volume is 0 !');
%end

end

