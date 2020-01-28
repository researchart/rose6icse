% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function listMergedBlockNames(x, giveBlockNames, info)

for i = 1:length(info.mergedList)
    fprintf('%d contains: ', i);
   for j = 1:length(info.mergedList{i})
       fprintf('%d %s\n',);
   end
end

if info.lengthOfX == length(x)
    for p = 1:info.numOfCores
        for i = 1:numOfBlocks(info)
            if int64(x(getIndexB(i, p, info))) == 1
                if giveBlockNames == 1
                    fprintf('Block %d: %s is mapped to core %d, will execute at %g\n', i, info.blockList{i}, p, x(getIndexS(i, info)));
                else
                    fprintf('Block %d is mapped to core %d, will execute at %g\n', i, p, x(getIndexS(i, info)));
                end
            end
        end
%         for j = i + 1:numOfBlocks(info)
%             if int64(x(getIndexD(i, j, info))) == 1
%                 if giveBlockNames == 1
%                     fprintf(' Block %d: %s will execute before block %d: %s\n', i, info.blockList{i}, j, info.blockList{j});
%                 else
%                     fprintf(' Block %d will execute before block %d\n', i, j);
%                 end
%             end
%         end
    end
else
    fprintf('ERROR in readX: NOT compatible x.. Size (%d) is different than expected(%d)!\n', length(x), info.lengthOfX);
end
end
