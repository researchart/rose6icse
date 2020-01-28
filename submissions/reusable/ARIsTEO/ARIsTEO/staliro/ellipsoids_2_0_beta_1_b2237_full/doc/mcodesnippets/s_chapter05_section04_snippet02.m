% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
atMat = {'0' '1 - cos(2*t)'; '-1/t' '0'};  
sys_t = elltool.linsys.LinSysFactory.create(atMat, bMat, SUBounds);