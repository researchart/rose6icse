% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef HA_Input_Data
    % Create an object that contains the initial conditions and input
    % signals for the ha_automaton class.
    %
    % Typical use:
    %   ha_dat = HA_Input_Data(h0,u)
    % where:
    %   h0 are the initial conditions for the hybrid automaton as defnied
    %       in <a href="matlab: doc hautomaton">hautomaton</a>.
    %   u is an array of the form [t, u1, u2, ...] where t is a column
    %       vector containing the timestamps for the signals and u1, u2,
    %       ... are column vectors containing the input signal values.
    % 
    % Examples:
    %   1) Empty object:
    %   >> ha_dat = HA_Input_Data;
    %   2) Define initial conditions and input signals:
    %   >> t = 0:0.1:4;
    %   >> u = 0.5*(1+sin(t));
    %   >> ha_dat = HA_Input_Data([1 0 5 0],[t; u]);
    %
    % See also: hautomaton, hasimulator
    
    properties
        h0;
        u;
    end 
    
    methods
        function obj = HA_Input_Data(varargin)
            if nargin==0 
                obj.h0 = [];
                obj.u = [];
            elseif nargin==2
                obj.h0 = varargin{1};
                obj.u = varargin{2};
            else 
                error(' ha_input_data: Either you need to instantiate an empty object or provide both the initial conditions and the input singals at instantiation.')
            end
        end
    end
    
    methods 
        function obj = set.h0(obj,x)
           obj.h0 = x;
        end
        
        function obj = set.u(obj,x)
           obj.u = x;
        end
    end
    
end

    

