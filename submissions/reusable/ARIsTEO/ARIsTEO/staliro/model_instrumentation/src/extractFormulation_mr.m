% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function rule = extractFormulation_mr(prob, info)

variableNames = getVariableValues_mr(info);
rule = cell(length(prob.beq) + length(prob.bineq), 1);
%fprintf('\n************ Ax = b ************\n');
for line = 1:length(prob.beq)
    rule{line} = ' ';
    for i = 1:info.lengthOfX
        if prob.Aeq(line, i) > 0
            rule{line} = sprintf('%s +%g%s', rule{line}, prob.Aeq(line, i), variableNames{i});
        elseif prob.Aeq(line, i) < 0
            rule{line} = sprintf('%s %g%s', rule{line}, prob.Aeq(line, i), variableNames{i});
        end
    end
    rule{line} = sprintf('%s = %g\n', rule{line}, prob.beq(line));
     % fprintf(rule{line});
end
%fprintf('\n************ Ax <= b ************\n');
for line = 1:length(prob.bineq)
    rule{length(prob.beq) + line} = ' ';
    for i = 1:info.lengthOfX
        if prob.Aineq(line, i) > 0
            rule{length(prob.beq) + line} = sprintf('%s +%g%s', rule{length(prob.beq) + line}, prob.Aineq(line, i), variableNames{i});
        elseif prob.Aineq(line, i) < 0
            rule{length(prob.beq) + line} = sprintf('%s %g%s', rule{length(prob.beq) + line}, prob.Aineq(line, i), variableNames{i});
        end
    end
    rule{length(prob.beq) + line} = sprintf('%s <= %g\n', rule{length(prob.beq) + line}, prob.bineq(line));
    %  fprintf(rule{length(prob.beq) + line});
end
end
