% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = reduceFullDataDependencyGraph( infoIn )
%reduceFullDataDependencyGraph Discard the ports except the ones for main
%blocks.

try
    info = infoIn;
    
%     %Find nondirect feedthrough ports and delete incoming connections to
%     %them
%     for i = 1:numel(info.ports)
%         block = info.ports(i).block;
%         if ~isempty(find(info.mainBlocks == block, 1))
%             if ~isempty(find(info.nonVirtualSubsystemsBelowDesiredDepth == block, 1)) ...
%                     && (info.ports(i).type == 1)
%                 %First find all dependent ports
%                 portsToSearch = find(info.fullDataDepGraph(i, :));
%                 portsFoundOnThisPass = portsToSearch;
%                 lastFoundSet = portsToSearch;
%                 while ~isempty(portsFoundOnThisPass)
%                     portsFoundOnThisPass = [];
%                     for j = lastFoundSet
%                         portsFoundOnThisPass = [portsFoundOnThisPass, find(info.fullDataDepGraph(j, :))];
%                     end
%                     lastFoundSet = portsFoundOnThisPass;
%                     if ~isempty(intersect(portsFoundOnThisPass, portsToSearch))
%                         portsFoundOnThisPass = setdiff(portsFoundOnThisPass, portsToSearch);
%                        % fprintf('!!!\n');
%                     end
%                     portsToSearch = [portsToSearch, portsFoundOnThisPass];
%                 end
% 
%                 %Now search the output port of block in the independent ports
%                 isDirectFeedThrough = 0;
%                 for j = portsToSearch
%                     if info.ports(j).block == block && info.ports(j).type == 0
%                         isDirectFeedThrough = 1;
%                         break;
%                     end
%                 end
% 
%                 %Delete incoming connections to the nondirect feedthrough port
%                 if ~isDirectFeedThrough
%                     info.fullDataDepGraph(:, i) = 0;
%                 end
%             end
%         end
%     end
    
    info.mainDataDepGraph = info.fullDataDepGraph;
    info.mainPorts = info.ports;
    portsToDiscard = [];
    for i = 1:numel(info.ports)
        block = info.ports(i).block;
        
        if isempty(find(info.mainBlocks == block, 1))
            portsToDiscard = [portsToDiscard, i];
            srcs = find(info.mainDataDepGraph(:, i));
            srcs = srcs.';
            for src = srcs
                for dst = find(info.mainDataDepGraph(i, :))
                    info.mainDataDepGraph(src, dst) = info.mainDataDepGraph(src, i);
                end
            end
        end
    end
    info.mainDataDepGraph(portsToDiscard, :) = [];
    info.mainDataDepGraph(:, portsToDiscard) = [];
    info.mainPorts(portsToDiscard) = [];
catch
    error('reduceFullDataDependencyGraph failed!');
end


end

