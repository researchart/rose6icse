% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% SimulateModel reproduces the input signals, state trajectory and output 
% signals of a model given the initial conditions and input signal control 
% points.
%
% [T,XT,YT,InpSignal,LT,CLG,GRD] = 
%   SimulateModel(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)
% 
% INPUTS
%
% The inputs are the same as in the staliro function. In brief,
%
%          - InputModel   :   the model object
%
%          - InitCond     :   the range of the initial conditions.
%
%          - InputRange   :   the range of the inputs.
%
%          - Sample       :   a sample point from the sets InitCond and 
%                             InputRange. The vector Sample is going to be
%                             used for the simulation of the system.
%                             
%                             If X0 in InitCond and U in InputRange, then
%                             Sample = [X0; U].
%                               
%                             Typicaly the vector Sample is returned by
%                             S-TaLiRo
%
%          - CPArray      :   contains the control points associated with
%                             each input signal. 
%
%          - TotT         :   Total simulation time
%       
%          - Opt          :   An staliro_options object
%
% OUTPUTS
%
%          - T            :   A vector with the timestamps
%
%          - XT           :   State trajectory
%
%          - YT           :   Output trajectory
%
%          - InpSignal    :   An array of the form [t u1 ... un] where 
%                             t is a column vector with the timestamp of 
%                             each input vector u1 ... un are the n input 
%                             signals to the system
%
%          - LT           :   Location trajectory
%
%          - CLG          :   The control location graph 
%
%          - Guards       :   The guard sets for the transitions between 
%                             locations
%
% See also: staliro, staliro_options 

% (C) Georgios Fainekos 2012 - Arizona State University

function [T,XT,YT,InpSignal,LT,CLG,GRD] = SimulateModel(InputModel,InitCond,InputRange,CPArray,Sample,TotT,opt)

if ~isempty(InitCond)
    % Detect fixed initial conditions
    if ~opt.X0Fixed.fixed
        for i_ic = 1:size(InitCond,1)
            if InitCond(i_ic,1)==InitCond(i_ic,2)
                opt.X0Fixed.fixed = true;
                opt.X0Fixed.idx_fixed = [opt.X0Fixed.idx_fixed, i_ic];
                opt.X0Fixed.values = [opt.X0Fixed.values,InitCond(i_ic,1)];
            end
        end
    end
    if opt.X0Fixed.fixed
        opt.X0Fixed.idx_search = 1:size(InitCond,1);
        opt.X0Fixed.idx_search(opt.X0Fixed.idx_fixed) = [];
        InitCond(opt.X0Fixed.idx_fixed,:) = [];
    end
end

if isempty(InputRange) % If no inputs to the model

    XPoint = Sample;
    UPoint = [];
    
else
    
    % Determine # of control points from the input_range
    if iscell(InputRange) && isempty(CPArray)
        for j = 1:size(InputRange,1)
            CPArray(j) = size(InputRange{j},1);
        end
    end    
    
    nx = size(InitCond,1);
    XPoint = Sample(1:nx);
    UPoint = Sample(nx+1:end);
    
end

[hs, ~, InpSignal] = systemsimulator(InputModel, XPoint, UPoint, TotT, InputRange, CPArray, opt);

T = hs.T;
XT = hs.XT;
YT = hs.YT;
LT = hs.LT;
CLG = hs.CLG;
GRD = hs.GRD;

end
