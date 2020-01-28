% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [T, X, Y, L, CLG, GRD] = blackbox_exec_identified_model(X0, EndTime, TimeStamps, InpSignals)
%BLACKBOX_EXEC_IDENTIFIED_MODEL Summary of this function goes here
%   Detailed explanation goes here

    global m
    global staliro_opt;
    d=iddata([],InpSignals,staliro_opt.SampTime);
    
    if( ~isempty(X0))
        opt = simOptions('InitialCondition', X0);
        simOut=sim(m,d, opt);
    else
        simOut=sim(m,d);
    end
    Y=simOut.OutputData;
    T=simOut.SamplingInstants;

    X=[];
    L=[];
    CLG=[];
    GRD=[];
end

