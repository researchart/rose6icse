% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ depGraph ] = displayDependencyGraph(conn, cpuAssignmentArray, isPrompt, names, showWeights)
%displayDependencyGraph Display the given adjacency matrix as graph.

try
    if nargin < 3
        isPrompt = 0;
    end
    if nargin < 2 || isempty(cpuAssignmentArray)
        cpuAssignmentArray = zeros(length(conn), 1);
    end
    if nargin < 5
        showWeights = 0;
    end
    if nargin < 4
        depGraph = biograph(conn, 1:length(conn));
    else
        if showWeights == 0
            depGraph = biograph(conn, names);
        else
            depGraph = biograph(conn, names, 'ShowWeights', 'on', 'Scale', 0.9);
        end
    end
    colors = zeros(length(cpuAssignmentArray), 3);
    for i = 1:length(cpuAssignmentArray)
        if cpuAssignmentArray(i) == 2
            colors(i,:) = [0, 0, 1]; %blue
        elseif cpuAssignmentArray(i) == 1
            colors(i,:) = [1, 0, 0]; %red
        elseif cpuAssignmentArray(i) > 0
            thisColor = double(1)/double(cpuAssignmentArray(i));
            colors(i,:) = [thisColor, thisColor, thisColor];
        else
            colors(i,:) = [0, 0, 0];
        end
    end
    for i = 1:numel(depGraph.Nodes)
        depGraph.Nodes(i).Color = [1,1,1];
        depGraph.Nodes(i).TextColor = colors(i,:);
        depGraph.Nodes(i).LineColor = colors(i,:);
    end
    
    if isPrompt == 1
        prompt = sprintf('Do you want to see task graph?(Y/N) ');
        wantToSeeGraph = input(prompt, 's');
    else
        wantToSeeGraph = 'Y';
    end
    if ((wantToSeeGraph == 'Y') || (wantToSeeGraph == 'y'))
        view(depGraph);
    end
catch
    fprintf('WARNING! displayDependencyGraph failed!\n');
end
end

