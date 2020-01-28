% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ rob ] = custom_cost( x, t, auxData )
%CUSTOM_COST - a cost function made to illustrate the custom cost function
%feature of S-TaLiRo.
% (C) B. Hoxha 2016 - Arizona State Univeristy

rob = t(1) + auxData(ceil(rand(1,1) * 10));
end

