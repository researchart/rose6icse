% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editsysconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);