% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ preemptionGraph ] = findPreemptionPairs( infoIn )
%findPreemptionPairs Find block to sample time pairs where block can be
%preempted by task of a sample rate.

info = infoIn;
preemptionGraph = zeros(numel(info.blocksInHyperPeriod), numel(info.sampleTimesInHyperPeriod));
index = 0;
try
    for i = 1:numel(info.sampleTimesInHyperPeriod)
        firingTimeIndex = info.sampleTimesInHyperPeriod{i}.firingTimeId;
        sampleTimeIndex = info.sampleTimesInHyperPeriod{i}.sampleTimeId;
        sampleTime = info.sampleTimes(sampleTimeIndex);
        firingTime = info.firingTimes(firingTimeIndex).time;
        deadline = firingTime + sampleTime;
        
        for j = i+1:numel(info.sampleTimesInHyperPeriod)
            firingTimeIndex_j = info.sampleTimesInHyperPeriod{j}.firingTimeId;
            firingTime_j = info.firingTimes(firingTimeIndex_j).time;
            if firingTime_j > firingTime && firingTime_j < deadline
                %this task j can preempt blocks in i
                blocks = info.blocksInHyperPeriodForSampleTime{i};
                for k = 1:numel(blocks)
                    index = index + 1;
                    preemptionGraph(blocks(k), j) = index;
                end
            end
        end
    end
catch
    error('findPreemptionPairs failed!');
end

end

