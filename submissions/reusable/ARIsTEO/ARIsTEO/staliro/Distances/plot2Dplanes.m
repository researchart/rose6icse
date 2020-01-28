% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% function plot2Dplanes(A,b,ax,sp,cl)
%   Plots a set of halfspaces defined by the constraints Ax<=b
%
% INPUTS
%   A,b - The constraints
%   ax = [xmin xmax ymin ymax] - default [-4 4 -4 4]
%   sp - The spacing of the numbers (default 0.1)
%   cl - color

% G. Fainekos - GRASP Lab - 2006.08.30


function plot2Dplanes(varargin)

nn = prod(size(varargin));

global id1;

if nn<2
    error('At least two arguments are required!');
elseif nn>5
    error('Too many input arguments!');
else
    A = varargin{1};
    b = varargin{2};
    if nn==3
        ax = varargin{3};
    else
        ax = [-4 4 -4 4];
    end
    if nn==4
        ax = varargin{3};
        sp = varargin{4};
    else
        sp = 0.1;
    end
    if nn==5
        ax = varargin{3};
        sp = varargin{4};
        cl = varargin{5};
    else
        cl = 'b';
    end
end

[m,n] = size(A);

hold on;
axis(ax);
x = ax(1):sp:ax(2);
xp = ax(3):sp*5:ax(4);

for i = 1:m
    c = A(i,:);
    d = b(i);
    if abs(c(2))<1e-9
        if c(1)>0
            s = -sp;
        else
            s = sp;
        end
        plot(d/c(1)*ones(2,1),[ax(3),ax(4)],cl)
        text(d/c(1)*ones(length(xp),1)+s,xp,num2str(i))
    else
        y = (d-c(1)*x)/c(2);
        plot(x,y,cl)
        if c(2)>0
            s = -sp;
        else
            s = sp;
        end
        text(x,y+s,num2str(i))
    end
end
