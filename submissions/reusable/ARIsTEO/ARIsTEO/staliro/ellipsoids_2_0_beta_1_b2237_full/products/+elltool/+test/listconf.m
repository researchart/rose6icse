% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function listconf()
confRepoMgr=elltool.test.configuration.AdaptiveConfRepoManager();
disp(confRepoMgr.getConfNameList().');