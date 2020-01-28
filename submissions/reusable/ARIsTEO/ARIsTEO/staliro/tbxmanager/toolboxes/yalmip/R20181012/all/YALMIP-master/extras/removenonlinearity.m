% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  p = removenonlinearity(p)
p.variabletype = 0*p.variabletype;
p.evalMap = [];