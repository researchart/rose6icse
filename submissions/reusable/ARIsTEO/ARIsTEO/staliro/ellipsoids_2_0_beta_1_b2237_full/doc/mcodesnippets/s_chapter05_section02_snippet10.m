% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% compute the intersections of ellipsoids in the second column of ellMat
% with hyperplane firstHypObj: 

intersectEllMat = ellMat(:, 2).hpintersection(firstHypObj)

% intersectEllMat =
% Array of ellipsoids with dimensionality 2x1

intersectEllMat.isdegenerate()  % resulting ellipsoids should lose rank

% ans =
% 
%      1
%      1