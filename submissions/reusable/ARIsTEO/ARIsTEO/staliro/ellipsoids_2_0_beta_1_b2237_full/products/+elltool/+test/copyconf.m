% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function copyconf(confName,toConfName)
confRepoMgr=elltool.test.configuration.AdaptiveConfRepoManager();
confRepoMgr.copyConf(confName,toConfName);