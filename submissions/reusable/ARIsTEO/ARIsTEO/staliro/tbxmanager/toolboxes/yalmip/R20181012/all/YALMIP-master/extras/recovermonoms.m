% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function monom = recovermonoms(newton_m,x);

if isempty(newton_m)
    monom = 1;
else
    error('Report this bug (call to recovermonoms with double)');
end