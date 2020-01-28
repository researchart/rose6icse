% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function B = behavior(hs)
% NAME
%   behavior - get some behavior descriptors
%
% SYNOPSYS
%   hs = systemsimulator(<data>);
%   beh = behavior(hs);
% 
% DESCRIPTION
%   Gets some behavior descriptors for trajectory hs.
%   Current descriptors are entry events into locations, and exit events
%   from locations.
%   INPUTS
%       hs = output of systemsimulator
%
%   OUTPUTS
%       B
%           struct with fields
%           B.entry_events : each row is
%               [index in hs of event, time of entry into a new location, the new location, the point of entry]
%           B.exit_events : same info but for exiting the location.
%
% (C) Houssam Abbas, Arizona State University, 2013

% This is how systemsimulator creates locHis.
sLT = [hs.LT(1); hs.LT(1:end-1)];
ixLocationChange = [1; find(hs.LT-sLT ~= 0)];
locHis = hs.locHis;
entry_events = [ixLocationChange, hs.T(ixLocationChange), locHis, hs.STraj(ixLocationChange,:)];

N = length(hs.T);
fLT = fliplr(hs.LT')';
sLT = [fLT(1); fLT(1:end-1)];
ixTemp = [1; find(fLT-sLT ~= 0)];
ixLocationChange = zeros(size(ixTemp));
for i=1:length(ixTemp)
    ixLocationChange(i) = N - (ixTemp(i)-1);
end
ixLocationChange = fliplr(ixLocationChange')';

exit_events = [ixLocationChange, hs.T(ixLocationChange), locHis, hs.STraj(ixLocationChange,:)];

B.entry_events = entry_events;
B.exit_events = exit_events;

end


