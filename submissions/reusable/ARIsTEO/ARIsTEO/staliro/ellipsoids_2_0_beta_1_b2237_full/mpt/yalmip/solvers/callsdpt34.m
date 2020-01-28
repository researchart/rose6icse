% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function output = callsdpt34(interfacedata)

% Author Johan L�fberg
% $Id: callsdpt34.m,v 1.21 2010-01-13 13:49:21 joloef Exp $ 

% Retrieve needed data
options = interfacedata.options;
F_struc = interfacedata.F_struc;
c       = interfacedata.c;
K       = interfacedata.K;
x0      = interfacedata.x0;
ub      = interfacedata.ub;
lb      = interfacedata.lb;

% Bounded variables converted to constraints
if ~isempty(ub)
    [F_struc,K] = addbounds(F_struc,K,ub,lb);
end

% % if options.removethem
%  [F_struc,K,c,variables] = preproc2(F_struc,K,c);
 % [F_struc,K,c,variables] = preproc1(F_struc,K,c);
%  [F_struc,K,c,variables] = preproc2(F_struc,K,c);
% % end

if any(K.m > 0)
    % Messy to keep track of
    options.sdpt3.smallblkdim = 0;
end

% Convert from internal (sedumi-like) format
if ~isempty(K.schur_funs)
    if length(length([(K.schur_funs{:})]))>0
        options.sdpt3.smallblkdim = 1;
    end
end
if ~isempty(interfacedata.lowrankdetails)
    options.sdpt3.smallblkdim = 1;
end
[blk,A,C,b,oldKs]=sedumi2sdpt3(F_struc(:,1),F_struc(:,2:end),c,K,options.sdpt3.smallblkdim);

% if ~isempty(interfacedata.lowrankdetails)
%     options.sdpt3.smallblkdim = 1;    
%     i = 1;
%     while blk{i,1}~='s'
%         i = i+1
%     end
%     for sdpi = 1:length(K.s)
%         if ismember(sdpi,interfacedata.lowrankdetails{1}.id)
%             for i = 1:length(c)
%                 Fi = reshape(F_struc(sdploc(lmiid):sdploc(lmiid+1)-1,i+1),K.s(lmiid),K.s(lmiid));
%                 if nnz(Fi)>0
%                     [D,V] = getfactors(Fi);
%                     if (options.sdplr.maxrank == 0) | (options.sdplr.maxrank ~= 0 & (length(D) <= options.sdplr.maxrank))
%                         lrA(k).cons = i;
%                         lrA(k).start = sdploc(lmiid);
%                         lrA(k).D = D;
%                         lrA(k).V = V;
%                         k = k+1;
%                         removethese(i) = 1;
%                     end
%                 end
%             end
%         end
%     end        
% end

options.sdpt3.printyes=double(options.verbose);
options.sdpt3.expon=options.sdpt3.expon(1);

% Setup the logarithmic barrier cost. We exploit the fact that we know that
% the only logaritmic cost is in the last SDP constraint
if abs(K.m) > 0
    for i = 1:size(blk,1)
        if isequal(blk{i,1},'l')
            options.sdpt3.parbarrier{i,1} = zeros(1,blk{i,2});
        else
            options.sdpt3.parbarrier{i,1} = 0*blk{i,2};
        end
    end
    n_sdp_logs = nnz(K.m > 1);
    n_lp_logs  = nnz(K.m == 1);
    if n_lp_logs>0
        lp_count = n_lp_logs;
    end
    if n_sdp_logs>0
        sdp_count = n_sdp_logs;
    end  
    for i = 1:length(K.m)
        if K.m(i) == 1
            % We placed it in the linear cone
            options.sdpt3.parbarrier{1,1}(end-lp_count+1) = -K.maxdetgain(i);
            lp_count = lp_count-1;
        elseif K.m(i) > 1
            % We placed it in the SDP cone
            options.sdpt3.parbarrier{end-sdp_count+1,1} = -K.maxdetgain(i);
            sdp_count = sdp_count-1;
        end
    end
    %options.saveduals = 0;
end

% Setup structures for user-defined Schur compilers
if isfield(K,'schur_funs')
    top = 1;
    if ~isempty(K.schur_funs)
        if K.f>0
            options.sdpt3.schurfun{top} = '';
            options.sdpt3.schurfun_par{top,1} = [];
            top = top+1;
        end
        if K.l > 0
            options.sdpt3.schurfun{top} = '';
            options.sdpt3.schurfun_par{top,1} = [];
            top = top+1;
        end
        if K.q > 0
            options.sdpt3.schurfun{top} = '';
            options.sdpt3.schurfun_par{top,1} = [];
            top = top+1;
        end
        for i = 1:length(K.s)
            if ~isempty(K.schur_funs{i})
                options.sdpt3.schurfun{top} = 'schurgateway';
                S.extra.par = options.sdpt3;
                S.data = K.schur_data{i};
                [init,loc] = ismember(K.schur_variables{i},interfacedata.used_variables);
                S.index = loc;
                S.fun =  K.schur_funs{i};
                S.nvars = length(interfacedata.used_variables);
                options.sdpt3.schurfun_par{top,1} = S;
                V = {S.extra,S.data{:}};
                feval(S.fun,[],[],V{:});
            else
                options.sdpt3.schurfun{top} = '';
                options.sdpt3.schurfun_par{top,1} = [];
            end
            top = top+1;
        end
    end
end

if options.savedebug
    ops = options.sdpt3;
    save sdpt3debug blk A C b ops x0 -v6
end

if options.showprogress;showprogress(['Calling ' interfacedata.solver.tag],options.showprogress);end
solvertime = clock;
if options.verbose==0 % SDPT3 does not run silent despite printyes=0!
   evalc('[obj,X,y,Z,info,runhist] =  sdpt3(blk,A,C,b,options.sdpt3,[],x0,[]);');
else
    [obj,X,y,Z,info,runhist] =  sdpt3(blk,A,C,b,options.sdpt3,[],x0,[]);            
end

% if options.removethem
% temp = y;
% y = nan(length(interfacedata.c),1);
% y(variables) = temp;
% end

% Create YALMIP dual variable and slack
Dual = [];
Slack = [];
top = 1;
if K.f>0
    Dual = [Dual;X{top}(:)];
    Slack = [Slack;Z{top}(:)];
    top = top+1;
end
if K.l>0
    Dual = [Dual;X{top}(:)];
    Slack = [Slack;Z{top}(:)];
    top = top + 1;
end
if K.q(1)>0
    Dual = [Dual;X{top}(:)];
    Slack = [Slack;Z{top}(:)];
    top = top + 1;
end
if K.s(1)>0  
    % Messy format in SDPT3 to block and sort small SDPs
    u = blk(:,1);
    u = find([u{:}]=='s');
    s = 1;
    for top = u
        ns = blk(top,2);ns = ns{1};
        k = 1;
        for i = 1:length(ns)
            Xi{oldKs(s)} = X{top}(k:k+ns(i)-1,k:k+ns(i)-1);
            Zi{oldKs(s)} = Z{top}(k:k+ns(i)-1,k:k+ns(i)-1);
            s = s + 1;                 
            k = k+ns(i);
        end
    end 
    for i = 1:length(Xi)
        Dual = [Dual;Xi{i}(:)];     
        Slack = [Slack;Zi{i}(:)];     
    end
end

if any(K.m > 0)
   % Dual = [];
end

% if options.removethem
% Dual = [];
% end

solvertime = etime(clock,solvertime);
Primal = -y;  % Primal variable in YALMIP

% Convert error code
switch info.termcode
    case 0
        problem = 0; % No problems detected
    case {-1,-5} 
        problem = 5; % Lack of progress
    case {-2,-3,-4,-7}
        problem = 4; % Numerical problems
    case -6
        problem = 3; % Maximum iterations exceeded
    case -10
        problem = 7; % YALMIP sent incorrect input to solver
    case 1
        problem = 2; % Dual feasibility
    case 2
        problem = 1; % Primal infeasibility 
    otherwise
        problem = -1; % Unknown error
end
infostr = yalmiperror(problem,interfacedata.solver.tag);

if options.savesolveroutput
    solveroutput.obj = obj;
    solveroutput.X = X;
    solveroutput.y = y;
    solveroutput.Z = Z;
    solveroutput.info = info;
    solveroutput.runhist = runhist;
 else
    solveroutput = [];
end

if options.savesolverinput
    solverinput.blk = blk;
    solverinput.A   = A;
    solverinput.C   = C;
    solverinput.b   = b;
    solverinput.X0   = [];
    solverinput.y0   = x0;
    solverinput.Z0   = [];
    solverinput.options   = options.sdpt3;
else
    solverinput = [];
end

% Standard interface 
output.Primal      = Primal;
output.Dual        = Dual;
output.Slack       = Slack;
output.problem     = problem;
output.infostr     = infostr;
output.solverinput = solverinput;
output.solveroutput= solveroutput;
output.solvertime  = solvertime;

function [F_struc,K] = deblock(F_struc,K);
X = any(F_struc(end-K.s(end)^2+1:end,:),2);
X = reshape(X,K.s(end),K.s(end));
[v,dummy,r,dummy2]=dmperm(X);
blks = diff(r);

lint = F_struc(1:end-K.s(end)^2,:);
logt = F_struc(end-K.s(end)^2+1:end,:);

newlogt = [];
for i = 1:size(logt,2)
    temp = reshape(logt(:,i),K.s(end),K.s(end));
    temp = temp(v,v);
    newlogt = [newlogt temp(:)];
end
logt = newlogt;

pattern = [];
for i = 1:length(blks)
    pattern = blkdiag(pattern,ones(blks(i)));
end

F_struc = [lint;logt(find(pattern),:)];
K.s(end) = [];
K.s = [K.s blks];
K.m = blks;
