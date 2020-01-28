% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef RunStats < handle
    %     NAME
    %
    %         RunStats - collect statistics on staliro runs
    %
    %     SYNOPSYS
    %
    %         stats = RunStats(parallel_optimization_on);
    %         stats.new_run();
    %         ... event ...
    %         stats.add_function_evals(1);
    %         ... stats.add_function_evals(1); ...
    %         stats.stop_collecting();
    %
    %
    % (C) 2013, Houssam Abbas, Arizona State University
    % (C) 2013, Georgios Fainekos, Arizona State University
    
    % This class's functionality is best implemented through events and
    % listeners: make the simulator an object, create an event for it
    % whenever it gets called, and make this class a listener to that
    % event.
    properties (Access = private)
        saved_collection_state = 0;
        % RunStats is not a supported feature if parallel optimization is
        % enabled. So set keep_stats to 0 to disable statistics keeping.
        keep_stats = nan;
        % Nb runs collected so far, including current one.
        nbruns = 0;
    end
    
    properties
        
        % Use this boolean to toggle statistics keeping on and off in a run
        % which is keeping stats.
        % So statistics are kept iff keep_stats == power == 1.
        power = 0;
        
        % Nb of objective function evaluations so far in one run of
        % staliro.
        nb_function_evals = 0;
        
        % Nb of objective function evaluations in current run.
        nb_function_evals_per_run = [];
        
        % Nb of samples from which local descent was performed
        nb_descent_acceptances_per_run = [];
        
    end
    
    methods
        
        function obj = RunStats(varargin)
            % mystats  = RunStats(parallel_optim_on);
            %
            % DESCRIPTION
            % Create an object of handle class RunStats.
            %
            %  parallel_optim_on
            %   Optional. If 1, indicates that parallel optimization is on,
            %   and therefore statistics should not be kept, because
            %   RunStats class does not yet support parallel optimization.
            %   Default = 0;
            po = 0;
            if nargin > 0
                po = varargin{1};
            end
            if po
                obj.keep_stats = 0;
            else
                obj.keep_stats = 1;
            end
        end
        
        function new_run(obj)
            % Call to indicate the beginning of a new run, and to
            % initialize the RunStats object.
            obj.nbruns = obj.nbruns + 1;
            obj.power = 1;
            obj.nb_function_evals_per_run = [obj.nb_function_evals_per_run 0];
            obj.nb_descent_acceptances_per_run = [obj.nb_descent_acceptances_per_run 0];
        end
        
        function stop_collecting(obj)
            % Call to stop collecting stats. Useful if some code sections
            % should not be tracked.
            obj.saved_collection_state = obj.power;
            obj.power = 0;
        end
        
        function resume_collecting(obj)
            % Call to resume collecting stats
            obj.power = 1;
            % Update saved state
            obj.saved_collection_state = 1;
        end
        
        function restore_collection_state(obj)
            % If Runstats object was collecting prior to last call that changed power
            % value, continue collecting now. If wasn't collecting, don't collect now.
            obj.power = obj.saved_collection_state;
        end
        
        function add_function_evals(obj,value)
            % Increment function_evals nbs by value
            if isempty(obj.nb_function_evals_per_run)
                warning('You need to first start a new run by calling new_run() before incrementing');
            end
            if obj.keep_stats && obj.power
                obj.nb_function_evals_per_run(end) = obj.nb_function_evals_per_run(end) + value;
                obj.nb_function_evals = obj.nb_function_evals + value;
            end
        end
        
        function add_descent_acceptances(obj,value)
            if isempty(obj.nb_descent_acceptances_per_run)
                error('You need to first start a new run by calling new_run() before incrementing');
            end
            if obj.keep_stats && obj.power
                obj.nb_descent_acceptances_per_run(end) = obj.nb_descent_acceptances_per_run(end) + value;
            end
        end
        
        function update_stats(obj, varargin)
            % Update all enabled stats
            
            fevals = varargin{1};
            obj.add_function_evals(fevals);
            desc_accepts = varargin{2};
            obj.add_descent_acceptances(desc_accepts);
        end
        
        function fe = nb_function_evals_this_run(obj)
            fe = obj.nb_function_evals_per_run(end);
        end
        
        function print(obj)
            % Print the kept statistics.
            if obj.keep_stats == 0
                disp('keep_stats = 0 so no statistics were kept. The following are the default values of the RunStats object.')
            end
            disp(['Nb of function evals = ',num2str(obj.nb_function_evals)]);
            disp(['Nb of function evals per run = ',num2str(obj.nb_function_evals_per_run)]);
            disp(['Nb of descent acceptances per run = ',num2str(obj.nb_descent_acceptances_per_run)]);
        end
        
        
    end
    
    % Set/Get methods for access control
    % See http://www.mathworks.com/help/matlab/matlab_oop/property-access-methods.html
    methods
        
        function set.keep_stats(obj,value)
            if isnan(obj.keep_stats )
                obj.keep_stats = value;
            else
                error('keep_stats can not be modified after object creation. It must remain fixed throughout a run.')
            end
        end
        
    end
    
end





