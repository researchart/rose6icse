% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function within(x, lo, hi, line)
if x<lo | x>hi
	error(['bounds violated at line ', num2str(line), ' in the hysdel source']);
end
