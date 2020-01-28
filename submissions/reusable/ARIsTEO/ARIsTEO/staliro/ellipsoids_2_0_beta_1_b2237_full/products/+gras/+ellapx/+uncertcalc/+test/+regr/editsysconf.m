% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editsysconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
confRepoMgr.editConfTemplate(confName);
