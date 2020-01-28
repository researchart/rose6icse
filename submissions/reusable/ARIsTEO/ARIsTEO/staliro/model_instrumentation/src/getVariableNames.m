% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function name = getVariableNames(info)

n = numOfBlocks(info);
name = cell(1, info.lengthOfX);
for i = 1:info.lengthOfX
    if i == info.optimIndex
        name{i} = 'f';
    elseif i >= info.startOfS
        name{i} = sprintf('(s%d)',i-(info.startOfS-1));
        if getIndexS(i-(info.startOfS-1), info) ~= i
            fprintf('index S of %d is not %d\n', i-(info.startOfS-1), i);
        end
    elseif i >= info.startOfD
        for b = 1:n
            startOfNextBlock = info.startOfD + ((b * ((2 * n) - b - 1)) / 2);
            if i < startOfNextBlock
                d = n - ((startOfNextBlock - i) - 1);
                name{i} = sprintf('(d%d,%d)', b, d);
                if getIndexD(b, d, info) ~= i
                    fprintf('index D of %d,%d is not %d\n', b, d, i);
                end
                break
            end
        end
    else
        for b = 1:n
            startOfNextBlock = info.startOfB + (b * info.numOfCores);
            if i < startOfNextBlock
                p = info.numOfCores - ((startOfNextBlock - i) - 1);
                name{i} = sprintf('(b%d,%d)', b, p);
                if getIndexB(b, p, info) ~= i
                    fprintf('index B of %d,%d is not %d\n', b, p, i);
                end
                break;
            end
        end
    end
end
end

