% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
gMat = [0; 1];  % matrix G
vEllObj = ellipsoid(1);  % disturbance bounds: unit ball in R
sys_d = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds,...
    gMat, vEllObj);