% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ sampleTimeList ] = readCompiledSampleTimes( blockList )
%readCompiledSampleTimes Read compiled sample time information of all blocks.

try
    numOfBlocks = numel(blockList);
    sampleTimeList = cell(numOfBlocks, 1);
    for i = 1:numOfBlocks
        try
            sampleTimeList{i} = get_param(blockList{i}, 'CompiledSampleTime');
            if iscell(sampleTimeList{i})
                for j = 1:numel(sampleTimeList{i})
                    if isnumeric(sampleTimeList{i}{j})
                        sampleTimeList{i}{j} = sampleTimeList{i}{j}*1000000; % Sample time is converted from sec to microsec
                    end
                end
            else
                sampleTimeList{i} = sampleTimeList{i}*1000000;
            end
        catch
            sampleTimeList{i} = 'NA';
        end
    end
catch
    error('ERROR: readCompiledSampleTimes failed!');
end
end