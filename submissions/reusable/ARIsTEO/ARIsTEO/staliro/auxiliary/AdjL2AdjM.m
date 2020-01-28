% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Convert an adjacency list to an adjacency matrix

% (C) G. Fainekos - GRASP - UPenn - last update 2006.10.14

function Gr = AdjL2AdjM(AdjL)

if isa(AdjL,'cell')
    m = length(AdjL);
    Gr = sparse(zeros(m));
    for ii = 1:m
        fnz = find(AdjL{ii}~=0);
        Gr(ii,AdjL{ii}(fnz)) = 1;
    end
else
    [m,n] = size(AdjL);
    Gr = sparse(zeros(m));
    for ii = 1:m
        fnz = find(AdjL(ii,:)~=0);
        Gr(ii,AdjL(ii,fnz)) = 1;
    end
end
