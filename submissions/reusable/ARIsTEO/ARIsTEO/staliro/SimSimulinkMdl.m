% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% SimSimulinkMdl reproduces the input signals, state trajectory and output 
% signals of a Simulink model given the initial conditions and input signal 
% control points.
%
% [T,XT,YT,InpSignal] = 
%   SimSimulinkMdl(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)
% 
% This function is a wrapper function for the SimulateModel function. It is
% maintained for backward compatibility. Please use SimulateModel.
%
% See also: staliro, staliro_options, SimulateModel

% (C) Georgios Fainekos 2012 - Arizona State University

function [T,XT,YT,InpSignal] = SimSimulinkMdl(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)

if ~ischar(InputModel)
    error(' SimSimulinkMdl : This function can only be used for Simulink models. Use SimulateModel insetad.')
end

[T,XT,YT,InpSignal] = SimulateModel(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt);

end


