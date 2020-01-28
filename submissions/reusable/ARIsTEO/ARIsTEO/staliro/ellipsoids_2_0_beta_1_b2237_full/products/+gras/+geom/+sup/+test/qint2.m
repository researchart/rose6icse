% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function x=qint2(data_dir,data_sup)
x=transpose(mrdivide(data_sup,data_dir));