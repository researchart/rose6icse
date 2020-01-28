% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ delayIntroducing ] = isDelayIntroducing( blockType )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

delayIntroducing =  strcmpi(blockType, ...
    {'unitdelay', 'integrator', 'statespace', 'delay', ...
    'discretefilter', 'discreteintegrator', 'zeroorderhold', 'memory'});
delayIntroducing = ~isempty(find(delayIntroducing, 1));
end

