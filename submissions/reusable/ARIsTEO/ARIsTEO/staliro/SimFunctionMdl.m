% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% SimFunctionMdl reproduces the input signals, state trajectory and output 
% signals of a model specified as a function handle or a state space (ss) 
% system given the initial conditions and input signal control points.
%
% [T,XT,YT,InpSignal] = 
%   SimFunctionMdl(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)
% 
% This function is a wrapper function for the SimulateModel function. It is
% maintained for backward compatibility. Please use SimulateModel.
%
% See also: staliro, staliro_options, SimulateModel

% (C) Georgios Fainekos 2012 - Arizona State University

function [T,XT,YT,InpSignal] = SimFunctionMdl(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)

if ~(isa(InputModel,'function_handle') || isa(InputModel,'ss'))
    error(' SimFunctionMdl : This function can be only used on a model which is specified as a function handle or a state space system. Use SimulateModel insetad.')
end

[T,XT,YT,InpSignal] = SimulateModel(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt);

end
