% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function F = lt(X,Y)
% Internal class for constraint lists

% Author Johan L�fberg
% $Id: lt.m,v 1.2 2007-09-12 14:28:29 joloef Exp $

superiorto('sdpvar');
superiorto('double');

% Try to evaluate
try
    if isa(X,'constraint')
        % (z > w) < y
        Z = Y - X.List{end};
        F = X;
        F.List{end+1} = '<';
        F.List{end+1} = Y;
        F.Evaluated{end+1} = Z;
        F.ConstraintID(end+1) = yalmip('ConstraintID');
        F.strict(end+1) = 1;
    else
        % x < (w > y)
        Z = Y.List{1} - X;
        F = Y;
        F.List = {X,'<',F.List{:}};
        F.Evaluated = {Z,F.Evaluated{:}};
        F.ConstraintID = [yalmip('ConstraintID') F.ConstraintID];
        F.strict = [1 F.strict];
    end
catch
    error(lasterr);
end



