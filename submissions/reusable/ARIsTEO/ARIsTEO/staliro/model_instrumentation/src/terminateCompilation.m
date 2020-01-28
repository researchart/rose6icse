% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ errStatus ] = terminateCompilation( modelName )
%terminateCompilation Terminate compilation of the given model.

errStatus = 0;
try
    eval([modelName,'([],[],[],''term'');']);
catch
    fprintf('!!! Could not terminate compilation of the model: ');
    fprintf('%s\n', modelName);
    errStatus = 1;
end

end

