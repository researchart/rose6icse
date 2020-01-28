% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function shortName=shortcapstr(longName)
isTakenVec=isstrprop(longName,'upper');
isUscrVec=longName=='_';
isDigitVec=isstrprop(longName,'digit');
isTakenVec=isTakenVec|isDigitVec|[false,isDigitVec(1:end-1)]|isUscrVec|...
    [false,isUscrVec(1:end-1)];
isTakenVec(1)=true;
shortName=longName(isTakenVec);