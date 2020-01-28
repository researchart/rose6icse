% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.luÂ  
function monom = recovermonoms(newton_m,x);

% Author Johan Löfberg
% $Id: recovermonoms.m,v 1.1 2004-11-15 16:20:08 johanl Exp $

if isempty(newton_m)
    monom = 1;
else
    error('Report this bug (call to recovermonoms with double)');
end