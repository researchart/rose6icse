% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function slexOpen(model)
% SLEX add help/toolbox/simulink/examples to the path, then open MODEL
%
% slexOpen MODEL
%   Open model residing in help/toolbox/simulink/examples.
%
% slexOpen
%   List available models (*.slx) in help/toolbox/simulink/examples
%   and prompt for selection.
%
% slexOpen GLOB_PATTERN
%   Open model in help/toolbox/simulink/examples which matches GLOB_PATTERN.
%   If there is more than one match, then all matching items are displayed
%   as a list and you are prompted to select one of the matches.
%   You use the following glob meta characters to specify a glob pattern:
%         \       Quote the next meta character
%         []      Character class
%         {}      Multiple pattern
%         *       Match any string of characters except the path separator
%         ?       Match any single character
%   For example,
%     slexOpen *Variant*
%   will list all models matching help/toolbox/simulink/examples/*Variant*.slx.
%   Notice the .slx is not required.
%
% slexOpen -rmpath
%   Remove help/toolbox/simulink/examples from path

%   Copyright 2016 The MathWorks, Inc.

    try
        narginchk(0,1);
        nargoutchk(0,0);

        relExamples = fullfile('help','toolbox','simulink','examples');
        examples = fullfile(matlabroot,relExamples);

        if nargin==0  % prompt for model
            modelFiles=dir(fullfile(examples,'*.slx'));
            allModels = strrep( {modelFiles.name}', '.slx', '');
            model=GetModelFromSelectionOrQuit(allModels);
        else
            if isequal(model,'-rmpath')
                % hide warning if examples isn't on path
                evalc('rmpath(examples)');
                evalc('rmpath(fullfile(examples,''internal''))');
                return
            end

            modelFile=[fullfile(examples,model),'.slx'];
            if exist(modelFile,'file')==0
                matches=ExpandGlobPattern(modelFile);
                if isempty(matches)
                    error(['Example model, ',modelFile,', doesn''t exist']);
                else
                    model=GetModelFromSelectionOrQuit(matches);
                end
            end

        end

        addpath(examples);
        disp(['opening ',fullfile(relExamples,[model,'.slx'])]);
        open_system(model);
    catch e
        throwAsCaller(e) % throw without showing error stack
    end
end % slexOpen


function matches=ExpandGlobPattern(modelFile)
% Expands modelFile returning the models (without the .slx) that
% match the pattern. modelFile is assumed to be a glob pattern of form:
%   /path/to/help/toolbox/simulink/examples/GLOB_PATTERN.slx

    me=mfilename('fullpath');
    globPerlProg=[me '.glob.pl'];

    % Note, can't use perl.m supplied with MATLAB because it doesn't escape glob
    % patterns (glob patterns are expanded by the shell on UNIX).
    perlCmd=['perl "' globPerlProg '" "' modelFile '"'];
    if ispc % Use the perl.exe we ship with MATLAB
        perlBin = fullfile(matlabroot, 'sys\perl\win32\bin\');
        perlCmd = ['set PATH=' perlBin ';%PATH%&' perlCmd];
    end
    [status,result]=system(perlCmd);
    if status ~= 0
        error(result);
    end
    matches='bad';
    eval(result);  % matches={'model_1',...'model_N'}
    if ischar(matches)
        error(['unexpected result from ',perlCmd,': ',result]);
    end
end


function model = GetModelFromSelectionOrQuit(models)
% Given a cell of models, display them, then prompt for selection (integer) or q
% to quit (abort). If there's only one model in models, return it without
% prompting.
    low=1;
    high=length(models);
    if high==1
        model=models{1};
        return
    end

    models=sort(models);
    for i=1:high
        fprintf(1,'%4d: %s\n',i,models{i});
    end
    fprintf(1, '  q: quit\n');
    while 1
        selection=input('  Selection: ','s');
        if strcmp(selection,'q')==1 || strcmp(selection,'quit')==1
            error('aborting');
        end
        if regexp(selection,'^\d+$')
            selection=str2double(selection);
            if ceil(selection) == floor(selection) && selection >= low && selection <= high
                model=models{selection};
                break;
            end
        end
    end

end % GetFlintAnsOrQuit
