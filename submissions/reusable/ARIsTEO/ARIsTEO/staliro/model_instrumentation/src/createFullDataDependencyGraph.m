% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = createFullDataDependencyGraph( infoIn )
%createFullDataDependencyGraph Full data dependency graph for ports data.
%Connects inports of a block to outport blocks (except delays)

try
    info = infoIn;
    
    fullDataDepGraph = info.portsGraph;
    unProcessedPorts = 1:numel(info.ports);
    while ~isempty(unProcessedPorts)
        port = unProcessedPorts(1);
        if info.ports(port).type == 1
            inPorts = port;
            outPorts = [];
        else
            outPorts = port;
            inPorts = [];
        end
        
        block = info.ports(port).block;
        processedPorts = port;
        if isempty(find(strcmpi(info.blockTypeList{block},...
                {'UnitDelay', 'Delay', 'ZeroOrderHold',  'Memory', 'Subsystem', 'Goto', 'Outport'}), 1))
            %Goto and outport have only one input port only so no need
            %to search. Do not connect subsystems since they are
            %already connected to related inport.
            for i = unProcessedPorts
                if i ~= port
                    if block == info.ports(i).block
                        processedPorts = [processedPorts, i];
                        if info.ports(i).type == 1
                            inPorts = [inPorts, i];
                        else
                            outPorts = [outPorts, i];
                        end
                    end
                end
            end
            for src = inPorts
                for dst = outPorts
                    fullDataDepGraph(src, dst) = 1000;
                end
            end
  %          portsL = logical(fullDataDepGraph);
%            if graphisdag(sparse(portsL)) == 0
 %               fprintf('Connections for block %d created cycle(s)\n', block);
       %     end
        end
        unProcessedPorts = setdiff(unProcessedPorts, processedPorts);
    end
    info.fullDataDepGraph = fullDataDepGraph;
catch
    error('createFullDataDependencyGraph failed!');
end

end

