% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.conf.ConfRepoMgr();
%confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);