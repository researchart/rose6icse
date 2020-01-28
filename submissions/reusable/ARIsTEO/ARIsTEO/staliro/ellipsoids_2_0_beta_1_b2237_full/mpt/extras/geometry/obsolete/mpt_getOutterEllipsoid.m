% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [E,x0]=mpt_getOutterEllipsoid(P,Options)
%MPT_GETOUTTERELLIPSOID Computes the smallest ellipsoid which covers the polytope P
%
% [E,x0]=mpt_getOutterEllipsoid(P)
%
% ---------------------------------------------------------------------------
% INPUT
% ---------------------------------------------------------------------------  
%   P                - Polytope object  
%   Options
%     .plotresult    - If problem is in 2D and flag is set to 1, the result 
%                      will be plotted (Default: 0).
% ---------------------------------------------------------------------------
% OUTPUT
% ---------------------------------------------------------------------------
%  E,x0     -   Minimal volume ellipsoid,  (x-x0) E (x - x0) <= 1, covering P   
%
% ---------------------------------------------------------------------------
% LITERATURE
% ---------------------------------------------------------------------------
%   S. Boyd and L. Vanderberghe, Convex Optimization
%
% see also MPT_PLOTELLIP, MPT_GETINNERELLIPSOID


% (C) 2004 Pascal Grieder, Automatic Control Laboratory, ETH Zurich,
%          grieder@control.ee.ethz.ch

% ---------------------------------------------------------------------------
% Legal note:
%          This program is free software; you can redistribute it and/or
%          modify it under the terms of the GNU General Public
%          License as published by the Free Software Foundation; either
%          version 2.1 of the License, or (at your option) any later version.
%
%          This program is distributed in the hope that it will be useful,
%          but WITHOUT ANY WARRANTY; without even the implied warranty of
%          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%          General Public License for more details.
% 
%          You should have received a copy of the GNU General Public
%          License along with this library; if not, write to the 
%          Free Software Foundation, Inc., 
%          59 Temple Place, Suite 330, 
%          Boston, MA  02111-1307  USA
%
% ---------------------------------------------------------------------------

global mptOptions

% warning('mpt_getOutterEllipsoid: This function is obsolete and will be removed in the future versions. Use ''getOutterEllipsoid()'' instead.');

error(nargchk(1,2,nargin));
if(nargin<2 | isempty(Options) | ~isfield(Options,'plotresult'))
    Options.plotresult=0;
end

[H,K]=double(P);
nx=size(H,2);
vertex=extreme(P); %get extreme points of polytope 

%formulate LMI
S=sdpvar(nx,nx);    %Ellipsoid variables ||Sx+b||<=1
b=sdpvar(nx,1);     %Ellipsoid variables ||Sx+b||<=1

myprog=lmi;
myprog=myprog + set('S>0');                                 %add constraint for each vertex
for i=1:size(vertex,1)
    myprog=myprog+set('||S*vertex(i,:)''+b||<1');            %add constraint for each vertex
end

options = mptOptions.sdpsettings;

solution = solvesdp(myprog,-logdet(S),options);              %find solution using LMI solver
    
Ss=double(S);   %extract results
bb=double(b);   %extract results

E=Ss'*Ss;
x0=-Ss^-1*bb;


if(nx==2)
    %plot results
    plot(P);
    hold on
    [xe,ye]=mpt_plotellip(E,x0);%   plots ellipsoid (x-xc)*E*(x-xc) = 1 in R^2
end

return 
