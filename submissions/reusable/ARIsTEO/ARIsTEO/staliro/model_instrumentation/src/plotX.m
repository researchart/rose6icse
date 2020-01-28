% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function plotX(x, assignmentArr, withLegend, info)

figure;
if info.isMultiRate
    for i = 1:numel(info.blocksInHyperPeriod)
        mainBlockId = info.blocksInHyperPeriod{i}.block;
        coreMapped = 0;
        copyCount = info.blocksInHyperPeriod{i}.copyCount;
        sampleTimeId = info.blocksInHyperPeriod{i}.sampleTimeId;
        executionStartTime = x(info.solverInfo.startOfS+i-1);
        executionFinishTime = executionStartTime + info.wcet(mainBlockId);
        for p = 1:info.numOfCores
            if int64(x(getIndexB(mainBlockId, p, info.solverInfo))) == 1
                coreMapped = p;
            end
        end
        x_pt = [executionStartTime, executionFinishTime];
        y_pt = [coreMapped, coreMapped];
        %[ colorRGB, colorAsStr ] = getMappingColor( coreMapped );
        [ colorRGB, colorAsStr ] = getMappingColor( sampleTimeId );

        plot(x_pt, y_pt, 'color', colorRGB, 'linewidth', 2.0, 'marker', 'o');
        hold on;
        blockName = [];
        nameSeparator = [];
        for m = info.mainBlockIndices{mainBlockId} %m gets the original block index
            blockName = [blockName, nameSeparator];
            tempName = info.blockList{m};
            splitName = strsplit(tempName, '/');
            blockName = [blockName, splitName{end}];
            nameSeparator = ',';
        end
        %tempName = names{mainBlockId};
        %tempName = sprintf('%d', mainBlockId);
        blockStr = sprintf('(%s, %d : %d)', blockName, copyCount, info.sampleTimes(sampleTimeId)/1000);
        t = text(mean([x_pt, x_pt(1)]), y_pt(1) + 0.1, blockStr, 'Color', colorRGB);
        set(t, 'rotation', 90)
    end
    if withLegend == 1
        for i = 1:numel(info.mainBlocks)
            mapBlockList{i} = sprintf('%d - %s', i, info.blockList{info.mainBlocks(i)});
        end
    end
else
    for i = 1:numOfBlocks(info)
        coreMapped = assignmentArr(i);
        x_pt = [x(getIndexS(i, info)), x(getIndexS(i, info)) + info.wcet(i)];
        y_pt = double([coreMapped, coreMapped]);
        [ mapColor, colorAsStr ] = getMappingColor( coreMapped );

        plot(x_pt, y_pt, 'color', mapColor, 'linewidth', 2.0, 'marker', 'o');
        hold on;
        text(mean([x_pt, x_pt(1)]), y_pt(1) + 0.1, int2str(i), 'Color', mapColor);
        noStr = sprintf('%d', i);

        if withLegend == 1
            noStr = sprintf('%s - ', noStr);
            mapBlockList{i} = strcat(noStr, info.blockList{i});
        end
    end
end

if withLegend == 1
    legend(mapBlockList, 'Location', 'southoutside');
end
ylim([0, info.numOfCores + 0.5]);
title('CPU core mapping and execution periods of blocks');
xlabel('Time');
ylabel('CPU Core');
ybounds = ylim();
set(gca, 'ytick', ybounds(1):1:ybounds(2));
end

