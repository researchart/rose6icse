% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Y=simplify(X)
%SIMPLIFY  Reduce PWA complexity

% Author Johan L�fberg
% $Id: simplify.m,v 1.1 2006-06-08 15:35:19 joloef Exp $

variables = getvariables(X);
extstruct = yalmip('extstruct',variables(1));
if ~isempty(extstruct)
    if isequal(extstruct.fcn,'pwa_yalmip')
        extstruct.arg{1}{1}.Fi = extstruct.arg{1}{1}.Bi;
        extstruct.arg{1}{1}.Gi = extstruct.arg{1}{1}.Ci;
        simplified = mpt_simplify(extstruct.arg{1}{1});
        simplified.Bi = simplified.Fi;
        simplified.Ci = simplified.Gi;
        Y = pwf(simplified,extstruct.arg{2},extstruct.arg{3});
    end
end
