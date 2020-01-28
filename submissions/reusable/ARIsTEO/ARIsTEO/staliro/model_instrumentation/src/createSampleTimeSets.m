% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ info ] = createSampleTimeSets( infoIn )
%createSampleTimeSets Find different sample time values among the model

try
    info = infoIn;
    
    sampleTimes = [];
    for i = 2:info.numOfBlocks
        if iscell(info.sampleTimeList{i})
            cnt = numel(info.sampleTimeList{i});
        else
            cnt = 1;
        end
        for j = 1:cnt
            if cnt == 1
                sampleTime = info.sampleTimeList{i}(1);
                phase = info.sampleTimeList{i}(2);
            else
                sampleTime = info.sampleTimeList{i}{j}(1);
                phase = info.sampleTimeList{i}{j}(2);
            end
            if sampleTime > 0 && sampleTime ~= Inf
                if isempty(find(sampleTimes == sampleTime, 1))
                    sampleTimes(end+1) = sampleTime;
                end
            end
        end
    end
    
    sampleTimeSets = cell(numel(sampleTimes), 0);
    sampleTimeSets{numel(sampleTimes)} = [];
    for i = 2:info.numOfBlocks
        if iscell(info.sampleTimeList{i})
            cnt = numel(info.sampleTimeList{i});
        else
            cnt = 1;
        end
        for j = 1:cnt
            if cnt == 1
                sampleTime = info.sampleTimeList{i}(1);
                phase = info.sampleTimeList{i}(2);
            else
                sampleTime = info.sampleTimeList{i}{j}(1);
                phase = info.sampleTimeList{i}{j}(2);
            end
            if phase > 0 || sampleTime == 0 || sampleTime == Inf || ...
                    (sampleTime < 0 && phase >= 0)
                fprintf('WARNING! createSampleTimeSets: block %d has sampleTime %d, phase %d\n',i, sampleTime, phase);
            elseif sampleTime < 0
                %negative sample time and phase means block is inside while
                %subsystem etc. find sample time from its ancestors
                foundAncestor = 0;
                for k = info.ancestorsList{i}
                    if iscell(info.sampleTimeList{k})
                        cnt_k = numel(info.sampleTimeList{k});
                    else
                        cnt_k = 1;
                    end
                    for m = 1:cnt_k
                        if cnt_k == 1
                            sampleTime = info.sampleTimeList{k}(1);
                            phase = info.sampleTimeList{k}(2);
                        else
                            sampleTime = info.sampleTimeList{k}{m}(1);
                            phase = info.sampleTimeList{k}{m}(2);
                        end
                        if phase > 0 || sampleTime == 0 || sampleTime == Inf || ...
                            (sampleTime < 0 && phase < 0)
                            fprintf('WARNING! createSampleTimeSets: block %d - ancestor %d, has sampleTime %d, phase %d\n',i, k, sampleTime, phase);
                        elseif sampleTime > 0
                            foundAncestor = 1;
                            
                            %add block to sample time set
                            index = find(sampleTimes == sampleTime, 1);
                            if index > 0
                                sampleTimeSets{index}(end+1) = i;
                            else
                                fprintf('WARNING!!! createSampleTimeSets: Unexpected index %d for block %d sample time\n', index, i);
                            end
                        end
                    end
                    if foundAncestor == 1
                        break;
                    end
                end
            else % valid sampleTime
                %add block to sample time set
                index = find(sampleTimes == sampleTime, 1);
                if index > 0
                    sampleTimeSets{index}(end+1) = i;
                else
                    fprintf('WARNING !!! createSampleTimeSets: Unexpected index %d for block %d sample time\n', index, i);
                end
            end
        end
    end
    info.sampleTimes = sampleTimes;
    info.sampleTimeSets = sampleTimeSets;
catch
    error('ERROR: createSampleTimeSets failed!');
end

end

