% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION ProjOnPlane
% 
% DESCRIPTION: 
%   Compute the projection of the point x on the hyperplane a*x=b
%
% INTERFACE: 
%   x0 = ProjOnPlane(x,a,b)
%
% INPUTS:
%   - x: the point
%   - a,b: the vector and scalar of the hyperplane
%
% OUTPUTS:
%   - x0: the projection of the point x on the hyperplane
%
% See also: DistProjFromPlane, DistFromPlane, DistFromPolyhedra
%

% Georgios Fainekos - GRASP Lab - Last update 2006.08.07

function x0 = ProjOnPlane(x,a,b)
x0 = x+(b-a*x)*a'/norm(a)^2;
