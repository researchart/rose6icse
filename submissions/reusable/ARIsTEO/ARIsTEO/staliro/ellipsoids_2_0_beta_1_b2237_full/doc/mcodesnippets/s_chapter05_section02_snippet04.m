% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% define two hyperplanes passing through the origin
secHypObj = hyperplane([1 -1; 1 1]); 
firstHypObj.isparallel(secHypObj) 

% ans =
% 
%      1     0
