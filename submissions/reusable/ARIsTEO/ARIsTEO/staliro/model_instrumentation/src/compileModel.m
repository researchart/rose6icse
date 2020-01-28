% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ errStatus ] = compileModel( modelName, modelinitfile )
%compileModel Compile the given model.

errStatus = 0;
if nargin == 2
    if ~isempty(modelinitfile)
        modelfilecompile=strcat(modelinitfile,'.mat');
        load(modelfilecompile);
    end
end

try
    eval([modelName,'([],[],[],''compile'');']);
catch
    fprintf('!!! Could not compile model: ');
    fprintf('%s\n', modelName);
    errStatus = 1;
end

end

