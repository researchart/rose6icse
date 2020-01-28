% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function varargout = log10(varargin)
%log10 (overloaded)

% Author Johan L�fberg
% $Id: log10.m,v 1.10 2007-08-17 19:11:42 joloef Exp $
switch class(varargin{1})

    case 'double' 
        error('Overloaded SDPVAR/NORM CALLED WITH DOUBLE. Report error')

    case 'sdpvar'
        varargout{1} = InstantiateElementWise(mfilename,varargin{:});

    case 'char'      

        X = varargin{3};        
        F = set(X > eps);

        operator = struct('convexity','concave','monotonicity','increasing','definiteness','none','model','callback');
        operator.convexhull = @convexhull;
        operator.bounds = @bounds;
        operator.derivative = @derivative;

        varargout{1} = F;
        varargout{2} = operator;
        varargout{3} = X;

    otherwise
        error('SDPVAR/LOG10 called with CHAR argument?');
end

function df = derivative(x)
df = (1./(abs(x)+eps))/log(10);

function [L,U] = bounds(xL,xU)
if xL < 0
    % The variable is not bounded enough yet
    L = -inf;
elseif xL==0
    L = -inf;
else
    L = log10(xL);
end
if xU < 0
    % This is an infeasible problem
    L = inf;
    U = -inf;
else
    U = log10(xU);
end

function [Ax, Ay, b] = convexhull(xL,xU)
fL = log10(xL);
fU = log10(xU);
dfL = (1/(xL))/log(10);
dfU = (1/(xU))/log(10);
[Ax,Ay,b] = convexhullConcave(xL,xU,fL,fU,dfL,dfU);