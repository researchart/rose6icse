% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = clear_poly_dep(F,x,order)

F.clauses{1}.data = clear_poly_dep(F.clauses{1}.data,x,order);