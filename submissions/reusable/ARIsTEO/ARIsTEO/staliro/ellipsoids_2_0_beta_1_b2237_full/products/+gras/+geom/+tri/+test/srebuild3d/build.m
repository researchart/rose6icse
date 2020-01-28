% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
curPath=fileparts(mfilename('fullpath'));
mex('ammeral.cpp','triangle.cpp','main.cpp','-output',...
    [curPath,filesep,'../srebuild3d']);