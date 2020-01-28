% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function updateallconf()
confRepoMgr=gras.ellapx.uncertcalc.conf.ConfRepoMgr();
confRepoMgr.updateAll();
gras.ellapx.uncertcalc.test.updateallconf();