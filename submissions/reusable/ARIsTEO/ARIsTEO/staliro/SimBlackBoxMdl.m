% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% SimBlackBoxMdl reproduces the input signals, state trajectory and output 
% signals of a black box system given the initial conditions and input 
% signal control points.
%
% [T,XT,YT,InpSignal,LT,CLG,Guards] = 
%    SimBlackBoxMdl(InputModel,InitCond,InputRange,CPArray,Sample,TotT,Opt)
% 
% This function is a wrapper function for the SimulateModel function. It is
% maintained for backward compatibility. Please use SimulateModel.
%
% See also: staliro, staliro_options, SimulateModel

% (C) Georgios Fainekos 2012 - Arizona State University

function [T,XT,YT,InpSignal,LT,CLG,GRD] = SimBlackBoxMdl(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)

if isa(InputModel, 'function_handle') 
    if opt.black_box == 1
        temp_model_ptr = InputModel;
        InputModel = staliro_blackbox();
        InputModel.model_fcnptr = temp_model_ptr;
    end
end

if ~isa(InputModel,'staliro_blackbox')
    error(' SimBlackBoxMdl : This function can only be used for S-Taliro Black Box objects. Use SimulateModel insetad.')
end

[T,XT,YT,InpSignal,LT,CLG,GRD] = SimulateModel(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt);

end

