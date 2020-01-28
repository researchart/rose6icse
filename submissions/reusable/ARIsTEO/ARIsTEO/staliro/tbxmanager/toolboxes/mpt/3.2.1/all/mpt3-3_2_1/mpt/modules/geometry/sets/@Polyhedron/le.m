% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function tf = le(P,S)
% P less or equal than S

validate_polyhedron(S);

tf = S.contains(P);

end
