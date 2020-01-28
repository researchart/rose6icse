% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.test.comp.conf.ConfRepoMgr();
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);