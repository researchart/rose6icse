% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ limits ] = getLimitsOfPolyhedron( P )
%GETLIMITSOFPOLYHEDRON Returns the limits of polyhedron in every dimension.
%
% (C) 2015, C. Erkan Tuncali, Arizona State University

direction = zeros(P.Dim, 1);
limits = zeros(P.Dim, 2);
for i = 1:P.Dim
    direction(i) = -1;
    limits(i, 1) = -P.extreme(direction).supp;
    direction(i) = 1;
    limits(i, 2) = P.extreme(direction).supp;
    direction(i) = 0;
end

end

