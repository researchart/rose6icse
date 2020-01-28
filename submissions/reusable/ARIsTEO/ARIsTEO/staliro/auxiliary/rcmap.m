% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef rcmap < Singleton
    % NAME
    % rcmap - encapsulates return codes and provides access methods to them.
    %
    % SYNOPSYS
    %   mymap = rcmap.instance();
    %   stringRC = mymap.str(1);
    %   intRC = mymap.int('RC_SUCCESS');
    %
    % DESCRIPTION
    % This is a singleton so can not call constructor directly, use method
    % instance as shown above.
    %
    %
    
    properties (SetAccess = private)
        int2str=[];
        str2int=[];
    end
    
    methods (Access = private)
        function obj = rcmap
            % Indices must start from 1
            obj.int2str{1}  = 'RC_SUCCESS';
            obj.int2str{2}  = 'RC_OPTIMIZATION_RAN_BUT_FAILED';
            obj.int2str{3}  = 'RC_UNHAPPY_OPTIMIZATION';
            obj.int2str{4}  = 'RC_NO_OPTIMIZATION';

            obj.int2str{5}  = 'RC_SIMULATION_UNSAFE_SET_REACHED';
            obj.int2str{6}  = 'RC_SIMULATION_TARGET_SET_REACHED';
            obj.int2str{7}  = 'RC_SIMULATION_NONDETERMINISTIC';
            obj.int2str{8}  = 'RC_SIMULATION_ZENO';
            obj.int2str{9}  = 'RC_SIMULATION_FAILED';

            obj.int2str{10}  = 'RC_JUNK_RESULTS';           
            
            obj.str2int = cell2struct({0,1,2,3,4,5,6,7,8,9},obj.int2str,2);
            
            assert(length(fieldnames(obj.str2int))==length(obj.int2str), 'Maybe you forgot to update both data structures int2str and str2int with your changes?');
            
        end
    end
    
    methods(Static)
        % Concrete implementation.  See Singleton superclass.
        function obj = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = rcmap();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
    methods
        
        function strRC = str(obj, intRC)
            cellRC = obj.int2str(intRC+1);
            % for some reason cellRC is a cell so take its contents
            strRC = cellRC{1};
        end
        
        function intRC = int(obj, strRC)
            intRC = obj.str2int.(strRC);
        end
        
        function cellRCs = get_str_rcs(obj)
            cellRCs = obj.str2int;
        end
        
        
        
        
    end % methods
    
end