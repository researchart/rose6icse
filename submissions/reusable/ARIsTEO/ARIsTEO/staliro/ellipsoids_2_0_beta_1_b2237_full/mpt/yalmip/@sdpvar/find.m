% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function indicies = find(x)
base = x.basis;
vars = x.lmi_variables;
indicies = find(any(base,2));
