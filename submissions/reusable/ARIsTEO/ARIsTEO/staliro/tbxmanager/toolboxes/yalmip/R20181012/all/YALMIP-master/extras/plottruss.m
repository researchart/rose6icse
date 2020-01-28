% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function plottruss(where,text,p,x)
try
    subplot(2,2,where)
    title(text)
    cla;
    pic(p.options.truss,x(union(p.integer_variables,p.binary_variables)));
    drawnow
catch
end