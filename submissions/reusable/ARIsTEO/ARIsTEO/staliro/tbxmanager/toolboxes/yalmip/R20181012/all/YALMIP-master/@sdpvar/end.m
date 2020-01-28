% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function index = end(X,position,numindices)
%END (overloaded)

switch position
    case {1,2}       
        if numindices == 1
            % User has written someting like X(end) or X(1:end)
            index = prod(X.dim);
        else
            index = X.dim(position);
        end
    otherwise
        index = 1;
end
