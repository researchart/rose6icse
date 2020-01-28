% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  x = settype(F)

% Author Johan L�fberg
% $Id: settype.m,v 1.1 2005-03-09 15:16:15 johanl Exp $

% Check if solution avaliable

nlmi = size(F.clauses,2);
if (nlmi == 0)
    x = 'empty';
else
    lmiinfo{1} = 'sdp';
    lmiinfo{2} = 'elementwise';
    lmiinfo{3} = 'equality';
    lmiinfo{4} = 'socc';
    lmiinfo{5} = 'rsocc';
    lmiinfo{7} = 'integer';
    lmiinfo{8} = 'binary';
    lmiinfo{9} = 'kyp';
    lmiinfo{10} = 'eig';
    lmiinfo{11} = 'sos';

    x = lmiinfo{F.clauses{1}.type};
end