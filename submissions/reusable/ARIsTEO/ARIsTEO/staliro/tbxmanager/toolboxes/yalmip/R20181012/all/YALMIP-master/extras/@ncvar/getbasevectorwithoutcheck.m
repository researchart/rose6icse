% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Q=getbasevectorwithoutcheck(X,ind)
%GETBASEVECTORWITHOUTCHECK Internal function to extract basematrix for variable ind

Q=X.basis(:,ind+1);
  
  
      