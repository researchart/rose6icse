% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [x, sample_success] = get_next_ur_sample(space,gen_method)
% SYNOPSYS
%   [x, sample_success] = get_next_ur_sample(space)
%
% DESCRIPTION
% Geneate a uniformly random sample on input space.
% If input space is ellipsoid_inter_rectangle, the point is selected UR in
% the hyperellipsoid, then rejected if it lies outside the rectangle. This
% can lead to a large nb of rejections, so we have an arbitrary limit on nb
% of rejections before quitting.
%
% INPUTS
% space : a struct with varying fields. 'shape' is always a field. The
% others depend on the shape.
%   shape: 'ball' or 'ellipsoid' or 'ellipsoid_inter_rectangle'. Required.
%   radius: Radius of ball. Default = 1;
%   center: center of ball or ellipsoid.
%   Pinv: ellipsoid shape matrix: ellipsoid = {x |(x-center)'Pinv(x-center)<=1}
%   CHOL: Lower triangular matrix L s.t. LL' = Pinv. Used to save
%       computations in ellipsoid_inter_rectangle
%   rectangle: n-by-2 matrix giving lower and upper bounds on rectangle in
%       n-space.
% gen_method : way of generating the next sample. 'accept-reject',
% 'HD-hit-and-run'.
%
% From "Handbook of Monte Carlo Methods" by Dirk P. Kroese, Thomas Taimre
% and others.
% Available online from Google books at http://books.google.com/books?id=Trj9HQ7G8TUC&pg=PA75&lpg=PA75&dq=generate+uniform+random+points+in+hyper+ellipsoid&source=bl&ots=1CTkLg_2AC&sig=BqWqhaWMlBAwyuBkWGeip3fQcMI&hl=en&sa=X&ei=J7DeT7yHNMnC2wX_4YDhAQ&ved=0CFcQ6AEwBg#v=onepage&q=generate%20uniform%20random%20points%20in%20hyper%20ellipsoid&f=false
% Also of interest:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/83592
%

if nargin < 2
    gen_method = 'HD-hit-and-run';
end    

sample_success = 0;
n=length(space.center);
if strcmp(space.shape, 'ball') % unit ball centered at 0    
    z=randn(n,1);
    u=rand;
    r = u^(1/n);
    x = (r/norm(z))*z;
    if isfield(space,'radius')
        x = space.radius*x;
    end
    
elseif strcmp(space.shape, 'ellipsoid')
    % First, generate point in ellipsoid centered at 0...
    %   Generate Cholesky matrix L: Pinv = LL'
    L = chol(space.Pinv, 'lower');
    %   Generate Z~UR(unit hyper ball)
    hb=struct('shape', 'ball', 'center', zeros(n,1));
    [z, success] = get_next_ur_sample(hb);
    assert(success == 1, 'Failed to generate a random uniform sample on unit ball for ellipsoid');
    %   Solve L'X=Z for X using backward-substitution
    opts.UT=true;
    x = linsolve(L',z, opts);
    assert(x'*space.Pinv*x <= 1, 'UR sample over ellipsoid doesn not satisfy ellipsoid equation');
    % ...then shift by center to get point in ellipsoid
    x = x+space.center;
elseif strcmp(space.shape, 'ellipsoid_inter_rectangle')
    if strcmp(gen_method, 'accept-reject')
        nb_attempts=0;
        %  Generate Cholesky matrix L: Pinv = LL'
        L = chol(space.Pinv, 'lower');
        max_attempts= 100;
        nInputs = size(space.rectangle,1);
        % If rectangle is too thin along some dimensions, we will
        % need to sample on a sphere of lower dimension to avoid too many
        % rejections. Note I have no proof the final vector is still
        % UR~ellipsoid
        min_thickness = 0;
        ix = (space.rectangle(:,2)-space.rectangle(:,1) <= min_thickness);
        ixthin=find(ix);
        ixthick=find(~ix);
        filler_values = 0.5*(space.rectangle(ix,2)+space.rectangle(ix,1) );
        neff = n-length(ixthin);
        while (~sample_success)
            if nb_attempts > max_attempts
                yn = my_input(['Made ', num2str(max_attempts), ' attempts at generating a point in ', space.shape, ' - continue?(y/n): '],...
                    @error, 'get_next_ur_sample:possible_infinite_loop', ['Exceeded max limit ', num2str(max_attempts), ' at generating a point in  ', space.shape, ' - quitting' ]);
                if strcmp(yn,'n')
                    error('');
                end
            end
            nb_attempts=nb_attempts+1;
            % First, generate point in ellipsoid centered at 0...
            %     Generate Z~UR(unit hyper ball)
            hb=struct('shape', 'ball', 'radius', 1, 'center', zeros(neff,1));
            [z, success] = get_next_ur_sample(hb);
            assert(success == 1, 'Failed to generate a random uniform sample on unit ball for ellipsoid');
            %     Fill back to full dimension if warranted
            if neff<n
                ztemp=zeros(n,1);
                ztemp(ixthin)=filler_values;
                ztemp(ixthick) =z;
                z=ztemp;
            end
            %     Solve L'X=Z for X using backward-substitution
            opts.UT=true;
            x = linsolve(L',z, opts);
            assert(x'*space.Pinv*x <= 1, 'UR sample over ellipsoid doesn not satisfy ellipsoid equation');
            % ...then shift by center to get point in ellipsoid
            x = x+space.center;
            % Accept only if sample in rectangle
            if (nnz(x <= space.rectangle(:,2))==nInputs && nnz(x >= space.rectangle(:,1))==nInputs)
                sample_success=1;
            end
        end
    elseif strcmp(gen_method, 'HD-hit-and-run')
        % uses Hyperspheres-Direction H&R (Belisle et al., "convergence properties of hit-and-run samplers")
        direction_vector = @(dim) hd_direction_vector(dim);
        [x, sample_success] = hit_and_run(space.center,space,direction_vector);
        return;
    end
else
    error('Un-recognized shape');
end
sample_success = 1;

end % function

function v = hd_direction_vector(n)
% Choose direction vector uniformly at random over unit sphere
z=randn(n,1);
v = (1/norm(z))*z;

end

function [xk, success ] = hit_and_run(x0,space,dv)
% space = A in Belisle's paper = space being sampled
% dv: fnt handle to fnt that generates next direction vector \theta_k
xk=x0;
dim = length(xk);
% Stopping criterion is that upper bound a*rho^n < closeness <=> n
% = nb_mc_samples < log_rho(closeness/a)
% closeness = 0.01;
% a = 1; % XXX parameter in paper's Eq.(7)
% rho = 0.1;
% nb_mc_samples = log(closeness/a)/log(rho);
nb_mc_samples = 30;
% Run MC until it is close enough to MC dsbn
for length_chain = 1:nb_mc_samples
    theta = dv(dim);
    [lambdaL lambdaU] = get_lambda_set(xk,theta,space);
    lambda = lambdaL + rand*(lambdaU - lambdaL);
    xk = xk + lambda*theta;
end
% % Validation 
% yk=xk;
% Y=zeros(dim,20);
% for i=1:20
%     theta = dv(dim);
%     [lambdaL lambdaU] = get_lambda_set(yk,theta,space);
%     lambda = lambdaL + rand*(lambdaU - lambdaL);
%     yk = yk + lambda*theta;
%     Y(:,i)=yk;
% end
% corrcoef(Y')
    
success = 1;

end

function [lL lU] = get_lambda_set(x0,theta,space)
global ACTIVATE_ASSERT;
% lL and lU are smallest and largest values of lambda, resp., such that
% xk+lambda*theta \in A, theta = unit vector.
% Assumes therefore that A is convex
% See Belisle's paper referenced above (proposition 1 proof)
lL = 0; lU = 0;
n = length(x0);
% First, let's determine the max offsets induced by rectangle
lam1 = (space.rectangle(:,1) - x0)./theta;
lam2 = (space.rectangle(:,2) - x0)./theta;
ix_swap = find(lam1 > lam2);
temp = lam1(ix_swap);
lam1(ix_swap) = lam2(ix_swap);
lam2(ix_swap) = temp;
if ACTIVATE_ASSERT
    assert(nnz(lam1<=0)==n);
    assert(nnz(lam2>=0)==n);
end
lL = max(lam1);
lU = min(lam2);
% Next, restrict to ellipsoid by solving
% (x+lambda*theta-x0)'Pinv(x+lambda*theta-x0) = 1, with x = x0
Pinv = space.Pinv;
lell2 = sqrt(1/(theta'*Pinv*theta));
lell1 = -lell2;
lL = max([lL lell1]);
lU = min([lU lell2]);

end

