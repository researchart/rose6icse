% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function output = calllindo(interfacedata)

switch interfacedata.solver.tag

    case {'lindo-NLP'}
        output = calllindo_nlp(interfacedata);
    case {'lindo-MIQP'}
        output = calllindo_miqp(interfacedata);
    otherwise
        error;
end