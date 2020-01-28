% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
 centVec = [1 2]';
 shMat = eye(2, 2);
 ellObj = ellipsoid(centVec, shMat);
 ellObj = ellipsoid(shMat) + centVec;
 ellObj = sqrtm(shMat)*ell_unitball(size(shMat, 1)) + centVec;