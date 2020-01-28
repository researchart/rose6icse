% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [nnz,row, col, val] = pennlp_funhess(x)


H = datasaver(3,x);
H = reshape(H,sqrt(length(H)),sqrt(length(H)));
[row,col,val] = find(tril(H));
nnz = length(val);
row = row';
col = col';
val = val';