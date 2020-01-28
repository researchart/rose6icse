% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% FUNCTION DistFromHalfSpace
% 
% DESCRIPTION: 
%   Compute the distance and the projection of the point x 
%   on the halfspace a*x<=b
%
% INTERFACE: 
%   [dist,x0] = DistFromHalfSpace(x,a,b)
%
% INPUTS:
%   - x: the point
%   - a,b: the vector and scalar of the halfspace
%
% OUTPUTS:
%   - dist: the minimum distance of the point x from the halfplane
%   - x0: the projection of the point x on the halfplane
%

% Georgios Fainekos - GRASP Lab - Last update 2006.08.07

function [dist,x0] = DistFromHalfSpace(x,a,b)
if a*x>b
    [dist,x0] = DistProjFromPlane(x,a,b);
else
    dist = 0;
    x0 = x;
end
