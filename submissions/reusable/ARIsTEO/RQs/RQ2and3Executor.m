% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
curPath=fileparts(which('RQ1.m'));
mainpath = strrep(curPath,'RQs','');
addpath(genpath(mainpath));

for i=[7 9 12 14 16 19]
    RQ2andRQ3('staliro',i);
end
for i=[5 7 9 11 13 15]
	RQ2andRQ3('aristeo',i);
end

