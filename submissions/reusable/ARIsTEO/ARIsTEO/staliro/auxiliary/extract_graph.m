% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [newmap,E] = extract_graph(inputstate,inputmodel)

rt=sfroot;

m = rt.find('-isa','Simulink.BlockDiagram', '-and','Name',inputmodel);

chartArray = m.find('-isa','Stateflow.Chart');

if (length(chartArray)==0)
    error('no stateflow chart available in the model')
end

for i = 1:length(chartArray)
    states = chartArray(i).find('-isa','Stateflow.State','-and','Name',inputstate);
    if (length(states)==0)
        continue;
    else
        break;
    end
end

states = chartArray(i).find('-isa','Stateflow.State');
transitions = chartArray(i).find('-isa','Stateflow.Transition');

stateL = length(states);
transitionsL = length(transitions);

newmap = containers.Map;
E = cell(stateL,1);

for i = 1 : stateL
    newmap(states(i).Name) = i;
end

for i = 1:transitionsL
    if isempty(transitions(i).Source)
        continue;
    else
        S = newmap(transitions(i).Source.Name);
        D = newmap(transitions(i).Destination.Name);    
        if (isempty(E{S}))
            E{S} = [D];
        else
            E{S} = [E{S} D];
        end
    end
end

for i = 1 : stateL
    str1 = states(i).LabelString;
    if isempty(regexp(str1,'STaliro', 'once'))
        str2 = sprintf('STaliro_StateVar = %d;',newmap(states(i).Name));
        str = [str1,10,str2];
        states(i).LabelString = str;
    end
end

sfsave(m.Name, inputmodel);


end








