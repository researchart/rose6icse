% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function id = cleardual(F)

for i = 1:length(F.LMIid)
    yalmip('cleardual',F.LMIid(i));
end
