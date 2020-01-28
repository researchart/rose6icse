% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function p = problemclass(F,h)

p = problemclass(lmi(F),h);
