% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Q=getbasematrixwithoutcheck(X,ind)
%GETBASEMATRIXWITHOUTCHECK Internal function to extract basematrix for variable IND

Q=reshape(X.basis(:,ind+1),X.dim(1),X.dim(2));
  
  
      