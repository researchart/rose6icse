% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function listconf()
confRepoMgr=gras.ellapx.uncertcalc.conf.ConfRepoMgr();
disp(confRepoMgr.getConfNameList().');