% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editconf(confName)

confRepoMgr=gras.test.configuration.AdaptiveConfRepoManager();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);

end
