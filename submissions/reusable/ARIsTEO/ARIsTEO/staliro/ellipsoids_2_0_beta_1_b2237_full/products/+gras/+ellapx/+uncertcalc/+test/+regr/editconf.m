% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function editconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
confRepoMgr.editConfTemplate(confName);
