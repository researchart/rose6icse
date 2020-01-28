% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistFromPlane
% 
% DESCRIPTION: 
%   Compute the distance of the point x from the hyperplane a*x=b
%
% INTERFACE: 
%   dist = DistFromPlane(x,a,b)
%
% INPUTS:
%   - x: the point
%   - a,b: the vector and scalar of the hyperplane
%
% OUTPUTS:
%   - dist: the minimum distance of the point x from the hyperplane
%
% See also: DistProjFromPlane, ProjOnPlane, DistFromPolyhedra
%

% Georgios Fainekos - GRASP Lab - Last update 2006.08.07

function dist = DistFromPlane(x,a,b)
dist = abs(b-a*x)/norm(a); 
