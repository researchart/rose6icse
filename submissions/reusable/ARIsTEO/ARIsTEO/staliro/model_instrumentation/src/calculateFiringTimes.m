% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ firingTimes ] = calculateFiringTimes( hyperPeriod, sampleTimeArr )
%calculateFiringTimes Calculate different firing times in the hyper period.

try
    firingTimes = [];
    for sTime = sampleTimeArr
        cnt = hyperPeriod/sTime;
        for i = 0:cnt-1
            firingTime = i*sTime;
            firingTimeIndex = 0;
            for f = 1:numel(firingTimes)
                if firingTimes(f).time == firingTime
                    firingTimeIndex = f;
                    break;
                end
            end
            if firingTimeIndex == 0
                firingTimeIndex = numel(firingTimes) + 1;
                firingTimes(firingTimeIndex).time = firingTime;
                firingTimes(firingTimeIndex).sampleTimes = sTime;
            else
                firingTimes(firingTimeIndex).sampleTimes = [firingTimes(firingTimeIndex).sampleTimes, sTime];
            end
        end
    end

    %sort firing times
    timeArr = [firingTimes(:).time];
    [tmp ind] = sort(timeArr);
    firingTimes = firingTimes(ind);
catch
    error('ERROR: calculateFiringTimes failed!');
end

end

