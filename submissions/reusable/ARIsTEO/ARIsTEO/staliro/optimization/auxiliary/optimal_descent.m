% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function du = optimal_descent(linsys, T, samp_T, pf)
% This function calculates the optimal control based descent direction
% for the cost function 0.5*(x(t*)-z*)'(x(t*)-z*), given system's local
% linearizations, where t* is the critical time for robustness evaluation.
% See the following paper for more details:
%
% Yaghoubi, Shakiba, and Georgios Fainekos. "Gray-box Adversarial Testing 
% for Control Systems with Machine Learning Component." arXiv preprint
% arXiv:1812.11958 (2018).

% Inputs:
%        linsys: linearization matrices returned by linearize command
%        T: sample time of input from 0 to t*
%        samp_T: sample time of linearization
%        pf:  vector (x(t*)-z*), final value for co-states lambda
% Output:
%        du: change in the input
%
% See also: staliro, Apply_Opt_GD_default
%
% (C) 2019, Shakiba Yaghoubi, Arizona State University

du = zeros(size(T));
lambda(:,length(T)) = pf;
eq = sum(T == samp_T) == length(T);
current_A = zeros(size(linsys.A(:,:,1),1), size(linsys.A(:,:,1),2),length(T)-1);
current_B = zeros(size(linsys.B(:,:,1),1), size(linsys.B(:,:,1),2),length(T)-1);

% Approximate A and B for all times in T based on sample times in samp_T
for i = 1:length(T)-1
    if ~eq 
    j = find(T(i) >= samp_T);
    j = j(end); %index for last sample
    try
        wi0 = 1-((T(i)-samp_T(j))/(samp_T(j+1)- samp_T(j)));
        wi1 = 1-((samp_T(j+1)-T(i))/(samp_T(j+1)- samp_T(j)));
        current_A(:,:,i) = wi0*linsys.A(:,:,j)+ wi1*linsys.A(:,:,j+1);
        current_B(:,:,i) = wi0*linsys.B(:,:,j)+ wi1*linsys.B(:,:,j+1);
    catch
        assert( j == length(samp_T) || j>= length(linsys.A) )
        current_A(:,:,i) = linsys.A(:,:,end);
        current_B(:,:,i) = linsys.B(:,:,end);
    end  
    else
        current_A(:,:,i) = linsys.A(:,:,i);
        current_B(:,:,i) = linsys.B(:,:,i);
    end
end
% Calculate the co-state backward in time and return changes in the
% input based on the co-states
for i = length(T)-1:-1:1
    dt = T(i+1)-T(i);
     lambda(:,i) = lambda(:,i+1)+dt*(current_A(:,:,i)'*lambda(:,i+1)); 
     du(i) = -lambda(:,i+1)'*current_B(:,:,i);
end
end