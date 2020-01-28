% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function copysysconf(confName,toConfName)
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
confRepoMgr.copyConf(confName,toConfName);