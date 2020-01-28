% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Class definition for Cross Entropy parameters 
% 
% ce_params = CE_Taliro_parameters
%
% The above code sets the default parameters for Cross Entropy 
% optimization.
%
% Default parameter values:
%
% num_subdivs = 25;     % Number of subdivisions when choosing a new sample
% n_tests = 1000;       % The total number of simulations
% num_iteration = 20;   % Number of rounds for the CE algorithm
% tilt_divisor = 5;     % A divisor which helps determine the number of
%                       % samples that need to be considered when 
%                       % choosing a new sample
%                             
% To change the default values to user-specified values use the default 
% object already created to specify the properties.                             
%                              
% E.g., to change cross_entropy_num_subdivs type:
% 
% ce_params.cross_entropy_num_subdivs = 10;
% 
% See also: staliro_options
%
% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2015, Georgios Fainekos, Arizona State University

classdef CE_Taliro_parameters
    
    properties
		num_subdivs = 25;
        num_iteration = 20;
        tilt_divisor = 5;
        n_tests = 1000;
    end
    
    methods     
        
        function obj = CE_Taliro_parameters(varargin)
            if nargin>0
                error(' CE_Taliro_parameters : Please access directly the properties of the object.')
            end
        end
        
    end
    
end

        