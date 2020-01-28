% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function tf = ge(P,S)
% P greater or equal than S

validate_polyhedron(S);

tf = P.contains(S);

end
