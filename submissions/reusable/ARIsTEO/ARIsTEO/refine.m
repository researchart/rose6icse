% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [data, abstractedmodel]=refine(data, model, abstractedmodel, aristeo_options, idOptions)

    global absreftime;
    absreftimetic=tic;
    data = misdata(data);
    try
        if (isempty(idOptions))
            abstractedmodel=pem(iddata(data.y{size(data.y,2)},data.u{size(data.u,2)},aristeo_options.SampTime),abstractedmodel);
        else
            abstractedmodel=pem(iddata(data.y{size(data.y,2)},data.u{size(data.u,2)},aristeo_options.SampTime),abstractedmodel,idOptions);
        end
    catch e
        warning(e.message);
    end
    absreftime=toc(absreftimetic);
end

