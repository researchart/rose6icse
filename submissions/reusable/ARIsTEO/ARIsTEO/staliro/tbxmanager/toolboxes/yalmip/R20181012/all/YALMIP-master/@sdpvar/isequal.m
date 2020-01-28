% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function  out = isequal(X,Y,check)
%ISEQUAL (overloaded)

if nargin == 3
    if (isa(X,'sdpvar') & isa(Y,'sdpvar'))
        out = isequal(X.basis,Y.basis) & isequal(X.lmi_variables,Y.lmi_variables);
    else
        out = false;
    end
else
    if (isa(X,'sdpvar') & isa(Y,'sdpvar'))
        out = isequal(struct(X),struct(Y));
    else
        out = false;
    end
end
