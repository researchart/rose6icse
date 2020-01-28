% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function completedHis = complete_location_history(locHis, ha, mode)
% Complete locHis to reach ha.locunsafe
% INPUTS
%     - locHis : sequence of locations to complete
%     - ha     : hybrid automaton struct
%     - mode   : 'nearest' complete from location in locHis nearest to target loc
%                'last'   complete from last location in locHis
% OUTPUTS
%       - completedHis : completed location history
% 
% Following assumes:
% locations are on a square grid
% numbered starting from 1 at the bottom left of grid
% numbers increase by going left to right, bottom to top
% unsafe set is in one location, and is not a union
% e.g. 7 8 9
%      4 5 6
%      1 2 3

if ~strcmp(ha.name, 'nav0')
    error('complete_location_history can only be called on nav0')
end
if nargin < 3
    mode = 'last';
end
nbloc_per_row = sqrt(length(ha.loc)); %assumes square grid
locB = ha.unsafe.descriptions(1).loc;
xcoord = loc2coord(locB);
xB = xcoord(1,1); yB = xcoord(1,2);

if strcmp(mode,'last')
    completedHis = locHis;
    lastloc = locHis(end);
elseif strcmp(mode, 'nearest')
    % Find traj location that is closest to locB
    lastcoord = loc2coord(locHis);
    dist = zeros(length(locHis),1);
    for i = 1:length(dist)
        dist(i) = norm(lastcoord(i,:)-xcoord);
    end
    [mini, ixmin] = min(dist);
    % truncate locHis to the prefix leading to closest loc
    completedHis = locHis(1:ixmin);
    lastloc = completedHis(end);
else
    error(['Unrecognized complete_location_history mode ', mode]);
end

coord = loc2coord(lastloc);
xlast = coord(1,1); ylast = coord(1,2);
xunit = -sign(xlast - xB); yunit = -sign(ylast - yB);
while lastloc ~= locB
    if ylast ~= yB
        lastloc = completedHis(end) + yunit*nbloc_per_row; % vertical step
        completedHis = [completedHis lastloc]; %#ok<*AGROW>
    end
    if xlast ~= xB
        lastloc = lastloc + xunit; %horiz step
        completedHis = [completedHis lastloc];
    end
    coord = loc2coord(lastloc);
    xlast = coord(1,1); ylast = coord(1,2);
end

%=====================================================================
    function coord = loc2coord(locs)
        coord = zeros(length(locs),2);
        for i=1:length(locs)
            loc=locs(i);
            coord(i,1) = mod(loc,nbloc_per_row); if coord(i,1) == 0 coord(i,1) = nbloc_per_row; end;
            coord(i,2) = 1 + (loc-coord(i,1))/nbloc_per_row;
        end
    end
%=====================================================================

end
