% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ cost, ind, cur_par, rob ] = globalBridge( gls, curSample )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    global staliro_mtlFormula;
    global staliro_Predicate;
    global staliro_SimulationTime;
    global staliro_InputBounds;
    global temp_ControlPoints;
    global staliro_dimX;
    global staliro_opt;
    global staliro_ParameterIndex;
    global staliro_Polarity;
    global staliro_InputModel;
    global staliro_InputModelType;
    
    staliro_mtlFormula = gls{1,1};
    staliro_Predicate = gls{1,2} ;
    staliro_SimulationTime = gls{1,3} ;
    staliro_InputBounds = gls{1,4};
    temp_ControlPoints = gls{1,5};
    staliro_dimX = gls{1,6} ;
    staliro_opt = gls{1,7} ;
    staliro_ParameterIndex = gls{1,8};
    staliro_Polarity = gls{1,9};    
    staliro_InputModel = gls{1,10};
    staliro_InputModelType = gls{1,11};
    
    [cost, ind, cur_par, rob] = Compute_Robustness_Right(staliro_InputModel,staliro_InputModelType,curSample);
end

