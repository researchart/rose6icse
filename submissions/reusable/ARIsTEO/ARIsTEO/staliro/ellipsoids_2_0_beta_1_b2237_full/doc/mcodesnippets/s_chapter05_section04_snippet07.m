% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
externallEllMat = firstRsObj.get_ea()  % external approximating ellipsoids

% externallEllMat =
% Array of ellipsoids with dimensionality 2x100

% internal approximating ellipsoids
[internalEllMat, timeVec] = firstRsObj.get_ia();  