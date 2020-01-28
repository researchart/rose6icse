% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistProjFromPlane
% 
% DESCRIPTION: 
%   Compute the distance and the projection of the point x 
%   on the hyperplane a*x=b
%
% INTERFACE: 
%   [dist,x0] = DistProjFromPlane(x,a,b)
%
% INPUTS:
%   - x: the point
%   - a,b: the vector and scalar of the hyperplane
%
% OUTPUTS:
%   - dist: the minimum distance of the point x from the hyperplane
%   - x0: the projection of the point x on the hyperplane
%
% See also: DistFromPlane, ProjOnPlane, DistFromPolyhedra
%

% Georgios Fainekos - GRASP Lab - Last update 2006.08.07

function [dist,x0] = DistProjFromPlane(x,a,b)
x0 = ProjOnPlane(x,a,b);
dist = norm(x-x0);
