% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  newModelName = promptAndSaveModel( modelName )
%promptAndSaveModel Prompt user and save model

newModelName = [];
prompt = sprintf('Do you want to save the model (will ask for new file name)?(Y/N) ');
wantToSave = input(prompt, 's');
if ((wantToSave == 'Y') || (wantToSave == 'y'))
    prompt = sprintf('Please give a new model name without file extension: ');
    newModelName = input(prompt, 's');
    if ~isempty(newModelName)
        save_system(modelName, sprintf('%s.slx', newModelName));
    end
end

end

