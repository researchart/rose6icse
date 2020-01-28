% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ cost ] = calculateCommCost( dataAmount, sendOrReceive, fromCore, toCore)
%calculateCommCost Time takes to send/receive ('S'/'R') dataAmount bytes of data from
%fromCore to toCore

% S(end) or T(ransmit) 
if sendOrReceive(1) == 'S' || sendOrReceive(1) == 's' || sendOrReceive(1) == 'T' || sendOrReceive(1) == 't'
    cost = 4000+dataAmount*40; %dataAmount microsecs
elseif sendOrReceive(1) == 'R' || sendOrReceive(1) == 'r' %R(eceive)
    cost = 5000+dataAmount*40;  %dataAmount microsecs
else
    cost = 0;
    fprintf('WARNING! calculateCommCost incorrect option!');
end

end

