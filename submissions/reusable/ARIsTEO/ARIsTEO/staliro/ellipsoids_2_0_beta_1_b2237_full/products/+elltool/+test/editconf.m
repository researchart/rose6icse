% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editconf(confName)
confRepoMgr=elltool.test.configuration.AdaptiveConfRepoManager();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);