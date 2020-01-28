% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
newEllTube = fromMatEllTube.getTuplesFilteredBy('sTime', 5);
newEllTube.getNTuples()
%
% ans =
% 
%      1
% 
newEllTube = fromMatEllTube.getTuplesFilteredBy('sTime', 2);
newEllTube.getNTuples()
%
% ans =
% 
%      0
% 