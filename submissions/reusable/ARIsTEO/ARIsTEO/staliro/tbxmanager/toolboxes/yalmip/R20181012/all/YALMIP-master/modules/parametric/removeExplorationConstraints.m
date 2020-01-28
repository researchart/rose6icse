% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function Matrices = removeExplorationConstraints(Matrices);
candidates = find((~any(Matrices.G,2)) & (sum(Matrices.E | Matrices.E,2) == 1));
if ~isempty(candidates)
    Matrices.bndA = -Matrices.E(candidates,:);
    Matrices.bndb = Matrices.W(candidates,:);
    Matrices.G(candidates,:) = [];
    Matrices.E(candidates,:) = [];
    Matrices.W(candidates,:) = [];
end