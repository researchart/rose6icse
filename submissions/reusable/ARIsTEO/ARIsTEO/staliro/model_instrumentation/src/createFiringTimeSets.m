% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ firingTimeBlockSets, blocksInHyperPeriod, sampleTimesInHyperPeriod, blocksInHyperPeriodForSampleTime ] = createFiringTimeSets(firingTimes, sampleTimes, sampleTimeSets)
%createFiringTimeSets Create set of blocks for each firing time

try
    firingTimeBlockSets = cell(numel(firingTimes), 0);
    firingTimeBlockSets{numel(firingTimes)} = [];
    
    blocksInHyperPeriod = cell(0, 0);
    sampleTimesInHyperPeriod = cell(0, 0);
    
    for f = 1:numel(firingTimes)
        firingTime = firingTimes(f).time;
        for sampleTime = firingTimes(f).sampleTimes
            copyCount = firingTime/sampleTime;
            sampleTimeIndex = find(sampleTimes == sampleTime, 1);
            rateEntry.sampleTimeId = sampleTimeIndex;
            rateEntry.copyCount = copyCount;
            rateEntry.firingTimeId = f;
            sampleTimesInHyperPeriod{end+1} = rateEntry;
            blocksInHyperPeriodForSampleTime{numel(sampleTimesInHyperPeriod)} = [];
            if ~isempty(sampleTimeIndex)
                for block = sampleTimeSets{sampleTimeIndex} %for each block with sampleTime
                    firingTimeBlockSets{f}(end+1).block = block;
                    firingTimeBlockSets{f}(end).copyCount = copyCount;
                    blocksInHyperPeriod{end+1} = firingTimeBlockSets{f}(end);
                    blocksInHyperPeriod{end}.firingTimeId = f;
                    blocksInHyperPeriod{end}.sampleTimeId = sampleTimeIndex;
                    blocksInHyperPeriod{end}.sampleTimeInHP = numel(sampleTimesInHyperPeriod);
                    blocksInHyperPeriodForSampleTime{numel(sampleTimesInHyperPeriod)} = ...
                        [blocksInHyperPeriodForSampleTime{numel(sampleTimesInHyperPeriod)}, numel(blocksInHyperPeriod)];
                end
            else
                fprintf('WARNING! createFiringTimeSets: Sample time %f could not be found\n', sampleTime);
            end
        end
    end
catch
    error('ERROR: createFiringTimeSets failed!');
end

end

