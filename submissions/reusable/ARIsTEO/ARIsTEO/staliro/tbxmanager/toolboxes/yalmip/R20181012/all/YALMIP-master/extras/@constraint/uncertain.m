% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function sys = uncertain(F)
%UNCERTAIN Declare all variables in a set of constraints as uncertain

sys = recover(depends(F));
sys = [F, uncertain(sys)];
