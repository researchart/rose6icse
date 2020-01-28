% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function YESNO = factored(X)

YESNO = ~isempty(X.midfactors);
