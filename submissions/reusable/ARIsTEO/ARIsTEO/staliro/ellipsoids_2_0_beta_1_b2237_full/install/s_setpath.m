% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% rootPathList{2}=[rmlastnpathparts(fileparts(which(mfilename)),2),filesep,'Folder1'];
rootPathList{1}=rmlastnpathparts(fileparts(which(mfilename)),1);
pathPatternToExclude='\.svn';
pathList=genpathexclusive(rootPathList,pathPatternToExclude);
restoredefaultpath;
addpath(pathList{:});
savepath;


