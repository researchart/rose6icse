% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function showprogress(thetext,doit)
%SHOWPROGRESS Internal function for printing messages

if doit>0
	fprintf('+ %s\n',thetext);
end
