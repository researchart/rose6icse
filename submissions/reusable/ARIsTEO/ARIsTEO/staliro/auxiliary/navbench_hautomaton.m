% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function HA = navbench_hautomaton(opt,init,A,unsafe,Av,Bv,reg)
% Function HA = navbench_hautomaton(opt,init,A,unsafe,Av,Bv,reg)
%
%   Navigation Benchmark from the HSCC 04 paper by Fehnker & Ivancic
% 
%   opt - options: a vector of options for creating graphs
%        Set to empty for using the default values
%        opt(1) - 0 do not plot (default)
%                 1 plot environment 
%        opt(2) - the number of simulation trajectories to be plotted on 
%                 the graph starting from random initial conditions picked 
%                 from the set of initial conditions
%                 Default option: 0 (no trajectory is plotted)
%        opt(3) - id of the figure
%                 Default option: 0 (new figure is generated)
%        opt(4) - 0 no text 
%                 1 numerical value of vector direction 
%                 2 HA location 
%                 3 both 1 and 2 above
%        opt(5) - 0 no arrows
%                 1 constant term vector arrows (input u(i,j) below)
%                 2 plot vector field in each location for x_3, x_4 set in
%                 option vector opt(6) and opt(7), respectively
%                 (does not provide any useful information)
%        opt(8) - 0 do not plot vector fields on x_2 - x_4 = dot x_2
%                 opt(8)>0 plot vector field for x_1 = opt(8)
%                 opt(8) cannot be integer values
%                 a new figure will be generated
%                       This also requires the function vectfield which 
%                       can be downloaded from:
%                   http://www-users.math.umd.edu/~tvp/246/vectfield.m
%        opt(9) - 0 do not plot vector fields on x_1 - x_3 = dot x_1
%                 opt(9)>0 plot vector field for x_2 = opt(9)
%                 opt(9) cannot be integer values
%                 a new figure will be generated
%                       This also requires the function vectfield which 
%                       can be downloaded from:
%                   http://www-users.math.umd.edu/~tvp/246/vectfield.m
%        
%   init - initial continuous set. 
%       A structure with fileds: loc and cube
%           loc : the initial locations
%           cube : A hyper cube of the form 
%                   [x1_m x1_M; x2_m x2_M; x3_m x3_M; x4_m x4_M]
%       i.e., initial locations are
%                   loc x [x1_m x1_M; x2_m x2_M; x3_m x3_M; x4_m x4_M]
%
%   A - An array giving the direction of the constant vector in each
%       location. I.e.
%           System obeys 
%                   x'(t) = As*x - Bs*u(i,j)
%           where
%                   u(i,j) = [sin(pi/4*A(i,j)); 
%                           cos(pi/4*A(i,j)]
%           and As, Bs depend on Av and Bv. See paper by Fehnker & Ivancic.
%       Special entries in A:
%           9 - unsafe cell
%           8 - target cell
%       Example: 
%           A = [9 2 4; 4 3 4; 2 2 8]
%
%   unsafe - The unsafe set given as a conjunction of halfspaces. unsafe is
%       a structure with fields A and b such that 
%           unsafe.A*x <= unsafe.b
%       defines the unsafe set.
%       Note: if unsafe is provided then the unsafe set defined in A is
%       ignored.
%
%   Av - An array used in the system dynamics. See A above.
%        If you want to use the default value enter [].
%        Typically it is a 2 x 2 array, but you may define a 4 x 4 array 
%        in order to directly define As.
%
%   Bv - An array used in the system dynamics. See A above.
%        If you want to use the default value enter [].
%        Typically it is a 2 x 2 array, but you may define a 4 x 2 array
%        in order to directly define Bs.
%
%   reg - other regions that should be ploted. This is a cell array of 2D
%         arrays. Eg.
%           reg{1} = [1 2; 1 2]
%
% OUTPUT:
%   HA : Hybrid Automaton object
%
% See also: hautomaton
%
% (C) Georgios Fainekos, 2009, Arizona State University
%
% History:
% 2011.12.30 - GF - Added some plotting options
% 2011.10.02 - GF - Changed to return an hautomaton object and added
%                   support for plotting trajectories
% 2011.06.06 - GF - Added figure id
% 2010.10.03 - GF - Added support for the inital location (at last!)
% 2010.09.29 - GF - Added support for general unsafe sets

simtime = 20;
nboptions = 9;

if nargin==0 || isempty(opt), opt = zeros(1,nboptions); end

% For backward compatibility
if length(opt)==1
    old_opt = opt;
    opt = zeros(1,nboptions);
    if old_opt > 0
        opt(1) = 1;
    end
    if old_opt == 2
        opt(4) = 1;
        opt(5) = 1;
    elseif old_opt == 3
        opt(4) = 2;
        opt(5) = 1;
    elseif old_opt == 4
        opt(4) = 3;
        opt(5) = 1;
    end
end

if length(opt)~=nboptions
    error('navbench_hautomaton: insufficient number of options')
end

if nargin<=1 || isempty(init)
    HA.init.loc = 8; 
    HA.init.cube = [1.2, 1.8; 2.2, 2.8; -1, 1; -1, 1]; 
else
    HA.init = init; 
end
if nargin<=2 || isempty(A), A = [9 2 4; 4 3 4; 2 2 8]; end
if nargin<=3, unsafe = []; end
if nargin<=4 || isempty(Av), Av = [-1.2 0.1; 0.1 -1.2]; end
if nargin<=5 || isempty(Bv)
    if length(Av) == 4
        Bv = [-1.2 0.1; 0.1 -1.2]; 
    elseif length(Av) == 2;
        Bv = Av;
    end
end
if nargin<=6, reg = []; end

if length(Av)==4
    As = Av;
else
    As = zeros(4);
    As(1,3) = 1;
    As(2,4) = 1;
    As(3:4,3:4) = Av;
end

if length(Bv)==4
    Bs = Bv;
else
    Bs = zeros(4,2);
    Bs(3:4,1:2) = Bv;
end

[nx,ny] = size(A);

nLoc = nx*ny;

for ii = 1:nLoc
    HA.adjList{ii} = [];
end

ii = 1; % HA location
for j = 1:nx
    for k  = 1:ny
        % Location Dynamics
        iiA = nx+1-j;
        HA.loc(ii).dyn = 0; 
        HA.loc(ii).A = As;
        HA.loc(ii).b = -Bs*vv(A(iiA,k));
        HA.loc(ii).f = @(t,x) HA.loc(ii).A*x+HA.loc(ii).b;
        HA.loc(ii).ftest = @(t,x) -Av*vv(A(iiA,k));
        if A(nx+1-j,k)==8
            tloc = ii;
        end
        % Guards and Transitions
        if (j < nx)
            nxtLoc = ii+ny;
            HA.adjList{ii} = [HA.adjList{ii}, nxtLoc];
            HA.guards(ii,nxtLoc).A = [0 -1 0 0];
            HA.guards(ii,nxtLoc).b = -j;
            HA.adjList{nxtLoc} = [HA.adjList{nxtLoc}, ii];
            HA.guards(nxtLoc,ii).A = [0 1 0 0];
            HA.guards(nxtLoc,ii).b = j;
        end
        if (k < ny)
            nxtLoc = ii+1;
            HA.adjList{ii} = [HA.adjList{ii}, nxtLoc];
            HA.guards(ii,nxtLoc).A = [-1 0 0 0];
            HA.guards(ii,nxtLoc).b = -k;
            HA.adjList{nxtLoc} = [HA.adjList{nxtLoc}, ii];
            HA.guards(nxtLoc,ii).A = [1 0 0 0];
            HA.guards(nxtLoc,ii).b = k;
        end
        ii = ii+1;
    end
end

% % Add diagonal Guards and Transitions
% ii = 1; % HA location
% for j = 1:nx
%     for k  = 1:ny
%         if (j < nx)&&(k < ny)
%             idx = ii+ny+1;
%             HA.adjList{ii} = [HA.adjList{ii}, idx];
%             HA.guards(ii,idx).A = [-1 0 0 0; 0 -1 0 0];
%             HA.guards(ii,idx).b = [-k; -j];
%             HA.adjList{idx} = [HA.adjList{idx}, ii];
%             HA.guards(idx,ii).A = [1 0 0 0; 0 1 0 0];
%             HA.guards(idx,ii).b = [k; j];
%             if (j > 1)&&(k > 1)
%                 idx = ii+nx-1;
%                 HA.adjList{ii} = [HA.adjList{ii}, idx];
%                 HA.guards(ii,idx).A = [1 0 0 0; 0 -1 0 0];
%                 HA.guards(ii,idx).b = [k; -j];
%                 HA.adjList{idx} = [HA.adjList{idx}, ii];
%                 HA.guards(idx,ii).A = [-1 0 0 0; 0 1 0 0];
%                 HA.guards(idx,ii).b = [-k; j];
%             end
%         end
%         ii = ii+1;
%     end
% end

% unsafe set
if isempty(unsafe)
    [ju,iu] = find(A==9);
    ju = ny+1-ju;
    nu = length(iu);
    if nu==1
        HA.unsafe.A = ...
            [-1 0 0 0;...
            1 0 0 0;...
            0 -1 0 0; ...
            0 1 0 0];
        HA.unsafe.b = [-(iu-1); iu; -(ju-1); ju];
    elseif nu>1
        error('Multiple unsafe sets are not supported yet');
    end
else
    HA.unsafe = unsafe;
end

% target set
[ju,iu] = find(A==8);
ju = ny+1-ju;
nu = length(iu);
if nu==1
    HA.target.A = ...
        [-1 0 0 0;...
        1 0 0 0;...
        0 -1 0 0; ...
        0 1 0 0];
    HA.target.b = [-(iu-1); iu; -(ju-1); ju];
elseif nu>1
    error('Multiple sets to be reached are not supported yet');
end

% Remove transitions to the target set
if nu>0
    for ii = 1:nLoc
        jj = HA.adjList{ii}==tloc;
        HA.adjList{ii}(jj) = [];
    end
end

HA = hautomaton(HA);

% Plot Navigation Benchmark
if opt(1)
    if opt(3)>0
        figure(opt(3))
    else
        figure
    end
    rectangle('Position',[HA.init.cube(1,1), HA.init.cube(2,1), HA.init.cube(1,2)-HA.init.cube(1,1), HA.init.cube(2,2)-HA.init.cube(2,1)],'FaceColor','g');
    hold on 
    if ~isempty(unsafe)
        plot(polytope(unsafe.A(:,1:2),unsafe.b),'r');
    end
    if ~isempty(reg)
        for ii = 1:length(reg)
            plot(polytope(ProdTop2Polytope(reg{ii})),'c');
            hold on 
        end
    end
    for ii = 1:nx
        for jj = 1:ny
            yy = nx+0.5-ii;
            str = [];
            if A(ii,jj)==9 && isempty(unsafe)
                plot(polytope(ProdTop2Polytope([jj-1,jj;nx-ii,nx-ii+1])),'r');
                str = 'Unsafe';
                xx = jj-0.8;
            elseif A(ii,jj)==8 
                plot(polytope(ProdTop2Polytope([jj-1,jj;nx-ii,nx-ii+1])),'y');
                str = 'Goal';
                xx = jj-0.8;
            else
                xx = jj-0.5;
                if opt(5) == 1
                    arrow([xx-0.25 yy+0.25],[xx-0.25 yy+0.25]+vv(A(ii,jj))'*0.25,8);
                elseif opt(5) == 2
                    tmpfun = @(t,x) proj2D(HA.loc((nx-ii)*ny+jj).f(t,[x(1);x(2);opt(6);opt(7)]),1,2);
                    vectfield(tmpfun,(nx-ii):0.25:(nx-ii+1),jj-1:0.25:jj);
                end
                str = [];
                if opt(4) == 1
                    str = num2str(A(ii,jj));
                elseif opt(4) == 2
                    str = num2str((nx-ii)*ny+jj);
                elseif opt(4) == 3
                    str = ['(',num2str(A(ii,jj)),',',num2str((nx-ii)*ny+jj),')']; %#ok<AGROW>
                end
                
            end
            if ~isempty(str)
                hh = text(xx,yy,str);
                set(hh,'FontSize',12)
            end
        end
    end
    axis([0 ny 0 nx])
    axis square
    set(gca,'XTick',0:ny)
    set(gca,'YTick',0:nx)
    grid on
    ylabel('x_2')
    xlabel('x_1')
    if opt(2)>0
        x0 = zeros(4,opt(2));
        for ii = 1:opt(2)
            x0(:,ii) = HA.init.cube(:,1)+(HA.init.cube(:,2)-HA.init.cube(:,1)).*rand(4,1);
        end
        for ii = 1:opt(2)
            hh = hasimulator(HA,[HA.init.loc 0 x0(:,ii)'],simtime,'ode45',[1 0 0 0]);
            plot(hh(:,3),hh(:,4))
        end
    end
end

if opt(1)>0 && opt(8)>0
    figure
    hold on 
    for ii = 1:nx
        for jj = 1:ny
            yy = 0;
            str = [];
            if jj-1<opt(8) && opt(8)<jj
                if A(ii,jj)==9 && isempty(unsafe)
                    plot(polytope(ProdTop2Polytope([nx-ii,nx-ii+1;HA.init.cube(4,1)-1,HA.init.cube(4,2)+1])),'r');
                    str = 'Unsafe';
                    xx = nx-ii+0.2;
                elseif A(ii,jj)==8 
                    plot(polytope(ProdTop2Polytope([nx-ii,nx-ii+1;HA.init.cube(4,1)-1,HA.init.cube(4,2)+1])),'y');
                    str = 'Goal';
                    xx = nx-ii+0.2;
                else
                    xx = nx-ii+0.5;
                    tmpfun = @(t,x) proj2D(HA.loc((nx-ii)*ny+jj).f(t,[opt(8);x(1);0;x(2)]),2,4);
                    vectfield(tmpfun,nx-ii:0.2:nx-ii+1,HA.init.cube(4,1)-1:0.2:HA.init.cube(4,2)+1);
                    str = [];
                    if opt(4) == 1
                        str = num2str(A(ii,jj));
                    elseif opt(4) == 2
                        str = num2str((nx-ii)*ny+jj);
                    elseif opt(4) == 3
                        str = ['(',num2str(A(ii,jj)),',',num2str((nx-ii)*ny+jj),')']; %#ok<AGROW>
                    end
                end
            end
            if ~isempty(str)
                hh = text(xx,yy,str);
                set(hh,'FontSize',12)
            end
        end
    end
    axis([0 nx HA.init.cube(4,1)-1 HA.init.cube(4,2)+1])
    axis square
    set(gca,'XTick',0:nx)
    set(gca,'YTick',[HA.init.cube(4,1)-1,HA.init.cube(4,2)+1])
    grid on
    ylabel('x_4')
    xlabel('x_2')
    % For plotting trajectories add the option to keep only the part of the 
    % trajectory that remains within the plotted vector fields
%     if opt(2)>0
%         for ii = 1:opt(2)
%             hh = hasimulator(HA,[HA.init.loc 0 x0(:,ii)'],simtime,'ode45',[1 0 0 0]);
%             plot(hh(:,4),hh(:,6))
%         end
%     end
end

if opt(1)>0 && opt(9)>0
    figure
    hold on 
    for ii = 1:nx
        for jj = 1:ny
            yy = 0;
            str = [];
            if nx-ii<opt(9) && opt(9)<nx-ii+1
                if A(ii,jj)==9 && isempty(unsafe)
                    plot(polytope(ProdTop2Polytope([jj-1,jj;HA.init.cube(3,1)-1,HA.init.cube(3,2)+1])),'r');
                    str = 'Unsafe';
                    xx = jj-0.8;
                elseif A(ii,jj)==8 
                    plot(polytope(ProdTop2Polytope([jj-1,jj;HA.init.cube(3,1)-1,HA.init.cube(3,2)+1])),'y');
                    str = 'Goal';
                    xx = jj-0.8;
                else
                    xx = jj-0.5;
                    tmpfun = @(t,x) proj2D(HA.loc((nx-ii)*ny+jj).f(t,[x(1);opt(9);x(2);0]),1,3);
                    vectfield(tmpfun,jj-1:0.2:jj,HA.init.cube(3,1)-1:0.2:HA.init.cube(3,2)+1);
                    str = [];
                    if opt(4) == 1
                        str = num2str(A(ii,jj));
                    elseif opt(4) == 2
                        str = num2str((nx-ii)*ny+jj);
                    elseif opt(4) == 3
                        str = ['(',num2str(A(ii,jj)),',',num2str((nx-ii)*ny+jj),')']; %#ok<AGROW>
                    end
                end
            end
            if ~isempty(str)
                hh = text(xx,yy,str);
                set(hh,'FontSize',12)
            end
        end
    end
    axis([0 ny HA.init.cube(3,1)-1 HA.init.cube(3,2)+1])
    axis square
    set(gca,'XTick',0:ny)
    set(gca,'YTick',[HA.init.cube(3,1)-1,HA.init.cube(3,2)+1])
    grid on
    ylabel('x_3')
    xlabel('x_1')
    % For plotting trajectories add the option to keep only the part of the 
    % trajectory that remains within the plotted vector fields
%     if opt(2)>0
%         for ii = 1:opt(2)
%             hh = hasimulator(HA,[HA.init.loc 0 x0(:,ii)'],simtime,'ode45',[1 0 0 0]);
%             plot(hh(:,3),hh(:,5))
%         end
%     end
end

% Auxiliary functions
    function val = vv(x)
        val = [sin(x*pi/4); cos(x*pi/4)];
    end

    function val = proj2D(x,i,j)
        val = x([i,j]);
    end
end

