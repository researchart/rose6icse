% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Convert an adjacency matrix to an adjacency list

% (C) G. Fainekos - GRASP - UPenn - last update 2006.10.14

function AdjL = AdjM2AdjL(AdjM)
m = size(AdjM,1);
for ii = 1:m
    fn1 = find(AdjM(ii,:)~=0);
    AdjL{ii} = fn1;
end
