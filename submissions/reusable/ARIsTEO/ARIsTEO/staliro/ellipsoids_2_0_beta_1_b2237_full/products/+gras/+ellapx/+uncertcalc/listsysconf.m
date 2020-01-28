% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function listsysconf()
confRepoMgr=gras.ellapx.uncertcalc.conf.sysdef.ConfRepoMgr();
disp(confRepoMgr.getConfNameList().');