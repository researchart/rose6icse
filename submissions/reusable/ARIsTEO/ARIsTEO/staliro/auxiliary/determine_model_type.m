% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% determine_model_type : Determines what type of input system model is being used. 
% It errors out if not a supported type is used - thus it can also be used 
% to simply check if a valid type (regardless of which one) is being used 
% or not.
%
% Interface:
%    modeltype = determine_model_type(staliro_InputModel)
%

% Yashwanth Annapureddy, Arizona State University, 2010
% Georgios Fainekos, Arizona State University, 2010
% Rahul Thekkalore, Arizona State University, 2016
% Added additional condition to check for blackbox model type - line 20-21

function modeltype = determine_model_type(staliro_InputModel)

if isfield(staliro_InputModel, 'type')
    modeltype = staliro_InputModel.type;
elseif (isa(staliro_InputModel,'function_handle'))
    modeltype = 'function_handle';
elseif (isa(staliro_InputModel,'staliro_blackbox'))
    modeltype = 'blackbox_model';
elseif (isa(staliro_InputModel,'hautomaton'))
    modeltype = 'hautomaton';
elseif isa(staliro_InputModel,'ss')
    modeltype = 'ss';
elseif (ischar(staliro_InputModel))
    modeltype = 'simulink';
else
    error(['Unknown model type passed: ',staliro_InputModel,'.'])
end

end
