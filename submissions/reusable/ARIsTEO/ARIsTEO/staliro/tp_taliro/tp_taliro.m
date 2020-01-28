% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% function tp_taliro - Computing the robustness estimate of timed state
% sequences of Timed Propositional Temporal Logic (TPTL) formulas
%
% For the theory see the paper:
% Dokhanchi, et al. "An Efficient Algorithm for Monitoring Practical TPTL 
% Specifications", MEMOCODE 2016
%
% USAGE
%
%         rob = tp_taliro(phi,Pred,seqS,seqT,seqL,CLG,GRD)
%    or,  
%         [rob, aux] = tp_taliro(phi,Pred,seqS,seqT,seqL,CLG,GRD)
%
% INPUTS
%
%   phi   - A TPTL formula 
%   
%    Syntax: 
%       phi := p | (phi) | !phi | phi \/ phi | phi /\ phi |
%           | phi -> phi | phi <-> phi | 
%           | X phi | phi U phi | phi R phi | <> phi | [] phi
%           | @ Var_a | ... | @ Var_z |
%           | { Var_a <= r } | { Var_a < r } | { Var_a == r } | 
%           | { Var_z >= r } | { Var_z > r } 
%        where:           
%            p      is a predicate. Its first character must be a lowercase 
%                   letter and it may contain numeric digits.
%                   Examples: 
%                         pred1, isGateOpen2  
%            !      is 'Not' 
%            \/     is 'Or'
%            /\     is 'And'
%            ->     is 'Implies'
%            <->    if 'If and only if'
%            X      is the 'Next' operator. It means that the next event 
%                   should occur. 
%            U      is the 'Until' operator.  
%            R      is the 'Release' operator. 
%            <>     is the 'Eventually' operator. 
%            []     is the 'Always' operator. 
%          @ Var_a  is the 'Freeze time operator' for Var_a time variable.  
%          { Var_a <= r },{ Var_a < r },{ Var_a == r },{ Var_z >= r },
%          { Var_z > r }
%                   are the 'time constraints' of TPTL. Time constraints 
%                   must be represented inside curly brackets { tc }. Time 
%                   constraints must be of the form { x ~ r } where x is a 
%                   time variable, r is a real value, and ~ is a relational
%                   operator.
%
%          Examples:
%             * Bounded response: 
%               Always 'a' implies eventually 'b' within 1 time unit
%               phi = '[](a -> @ Var_x <>( b /\ { Var_x <= 1 }))';
%
%               MTL equivalent: Use dp_taliro to compute the robusntees of
%               phi_MTL = '[](a -> <>_[0,1] b)';
%
%             * Bounded response (TPTL): 
%               Any occurrence of a problem 'p' will eventually trigger 
%               alarm 'a' and then eventually enter failsafe mode 'f'  
%               within at most 5 time units.  
%               phi = '[](p -> @ Var_x <>( a /\ <>(f /\ { Var_x <= 5} )))';
%
%             * 'a' is true until 'b' becomes true after 4 and before 7.5  
%               time units 
%               phi = '@ Var_x ( a U (b /\{ Var_x < 4 }/\{ Var_x < 7.5 })';
%
%               MTL equivalent: Use dp_taliro to compute the robusntees of
%               phi_MTL = 'a U_(4,7.5) b';
%
%             * 'p1' eventually will become true between 0.1 and 3.6 
%               time units 
%               phi = '@ Var_x <>(p1 /\{ Var_x <= 0.1 }/\{ Var_x < 3.6 })';
%
%               MTL equivalent: Use dp_taliro to compute the robusntees of
%               phi_MTL = '<>_[0.1,3.6) p1';
%
%
%   Pred - The mapping of the predicates to their respective states.
%
%          Pred(i).str : the predicate name as a string 
%          Pred(i).A, Pred(i).b : a constraint of the form Ax<=b
%          Pred(i).loc : is a vector with the control locations on which  
%		   	   the predicate should hold in case of trajectories of hybrid 
%		   	   systems. If the control location vector is empty, then the 
%		   	   predicate should hold in any location, i.e., this is 
%		   	   equivalent with including in loc all the Hybrid Automaton 
%		   	   locations.
%          Pred(i).Normalized : 0 - No normalization
%                               1 - normalize robusntess to range [-1,1]
%          Pred(i).NormBounds : A 1D or 2D array that contains the bounds 
%              on the distance for normalization.
%              Pred(i).NormBounds(1) : The maximum absolute robustenss  
%                   value for Euclidean distances. 
%                   E.g., if Pred(i).NormBounds = 2.5, then any
%                   robustness value will be first saturated to the  
%                   interval [-2.5,2.5] and then mapped to the interval 
%                   [-1,1].
%              Pred(i).NormBounds(2) : The maximum path distance on the
%                   control location graph.
%              Remarks: 
%              (1) Normalization does not affect +/- inf values returned 
%                  due to violations of the real-time constraints of
%                  the temporal operators.
%              (2) If normalization of hybrid distances is requested, then
%                  the return robustness value is going to be HyDis object
%                  where the path component is 0 and the Euclidean
%                  component stores the normalized hybrid distance.
%
%               
%   seqS - The sequence of states from a Euclidean space X. Each row must  
%          be a different sampling instance and each column a different 
%	       dimension in the state space.
%
%	       For example, a 2D signal sampled at 3 time instances is:
%
%               seqS = [0.1  0.2;
%                       0.15 0.19;
%                       0.14 0.18];
%
%   seqT - The time-stamps of the trace. It must be a column vector.
%          For example:
%               seqT = [0 0.1 0.2]';
%          It should be a monotonically increasing sequence.
%          Enter [] or ignore if you are interested only about LTL 
%          properties.
%
%   seqL - This is the sequence of locations in case of hybrid system 
%	       trajectory. It is assumed that each location has a unique 
%	       numerical (integer) value. It can be omitted in case the 
%	       predicates refer to global conditions on the continuous state 
%          space.
%
%   CLG - The control location graph. This is the adjecency matrix or graph 
%	      of the control locations of the Hybrid Automaton. It can be  
%	      omitted in case the predicates refer to global conditions on the  
%	      continuous state space.
%
%   GRD - Guard set for each edge of the CLG. For each edge (l,m) of CLG, 
%         the set that enables the transition represents a union of j  
%         number of polytopes of the form \/_i=[1...j] A_i x<=b_i where  
%         each A_i x<=b_i is a constraint. Guard set is defined by cell 
%         array structure as follows:
%               GRD(l,m).A = { A_1 A_2 .. A_j }
%               GRD(l,m).b = { b_1 b_2 .. b_j }
%
% OUTPUTS
%
%   rob - the robustness estimate. This is a HyDis object for hybrid system
%	      trajectory robustness. To get the continuous state robustness 
%	      type get(rob,2).
%
%   aux - information about the most related iteration and most related
%       predicate.
%         aux.i indicates the most related iteration of the rob
%         aux.pred indicates the most related predicate index of the rob
%   
%       Example for aux:
%     c_pred = get_predicate_index(aux.pred,pred);
%     SignedDist(x(aux.i,:),c_pred.A,c_pred.b) == tp_taliro(phi,pred,X,T);
%
%

% Copyright (c) 2017  Georgios Fainekos	- ASU							  
% Copyright (c) 2017  Adel Dokhanchi - ASU							  
% Send bug-reports and/or questions to: fainekos@asu.edu

% This program is free software; you can redistribute it and/or modify   
% it under the terms of the GNU General Public License as published by   
% the Free Software Foundation; either version 2 of the License, or      
% (at your option) any later version.                                    
%                                                                        
% This program is distributed in the hope that it will be useful,        
% but WITHOUT ANY WARRANTY; without even the implied warranty of         
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          
% GNU General Public License for more details.                           
%                                                                        
% You should have received a copy of the GNU General Public License      
% along with this program; if not, write to the Free Software            
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function varargout = tp_taliro(phi,Pred,seqS,seqT,seqL,A,G)

clear mx_tp_taliro


seqS = double(seqS);
if nargin==3 || (nargin==4 && isempty(seqT)) ...
        || (nargin==5 && isempty(seqT) && isempty(seqL)) ...
        || (nargin==6 && isempty(seqT) && isempty(seqL) && isempty(A)) ...
        || (nargin==7 && isempty(seqT) && isempty(seqL) && isempty(A) && isempty(G))
    [tmp_rob,aux] = tp_taliro_casting(mx_tp_taliro(phi,Pred,seqS));
    rob = tmp_rob.ds;
elseif nargin==4 || (nargin==5 && isempty(seqL)) ...
        || (nargin==6 && isempty(seqL) && isempty(A)) ...
        || (nargin==7 && isempty(seqL) && isempty(A) && isempty(G))
    [tmp_rob,aux] = tp_taliro_casting(mx_tp_taliro(phi,Pred,seqS,seqT));
    rob = tmp_rob.ds;
elseif nargin>=6 && nargin<=7
        % Check whether we have multiple state machines as input
        multiHAs = ~isempty(A) && iscell(A) && iscell(A{1});
        if(multiHAs==1)
            error('Multiple Hybrid Automata is not suppoterd in TP_TaLiRo');
        end
        if iscell(A)
            CLG = AdjL2AdjM(A);
            Adj = A;
        else
            CLG = A;
            Adj = AdjM2AdjL(A);
        end
        D = floyd_warshall_all_sp(sparse(CLG)); 
        % Compute the min distance from each location i to the control 
        % locations for each predicate j
        mm = length(A);
        NewPred = Pred;
        nn = length(NewPred);

        DMin = zeros(mm,nn);
        for ii=1:mm
            for jj=1:nn
                % Revise to compute distances only to atomic propositions used
                if isempty(NewPred(jj).loc)
                    DMin(ii,jj) = min(D(ii,:));
                else
                    DMin(ii,jj) = min(D(ii,NewPred(jj).loc));
                end
            end
        end    

        if nargin<7 || isempty(G) 
           [rob_temp,aux] = tp_taliro_casting(mx_tp_taliro(phi,NewPred,seqS,seqT,seqL,DMin));
           rob = hydis(rob_temp);
        else
        
            try
                % Catching only this call to mx_dp_taliro because it's the only
                % one using the guards, and we're interested in the error
                % involving the signed dist to guards
                [rob_temp,aux] = tp_taliro_casting(mx_tp_taliro(phi,NewPred,seqS,seqT,seqL,DMin,Adj,G));
                rob = hydis(rob_temp);
            catch ME
                msg = ME.message(37:end);
                % this message is the one issued by dp_taliro/distances.c
                if strcmp(msg, 'signed distance to the guard set is positive!')
                    display('[dp_taliro] Ignoring the following mx_dp_taliro error:')
                    display(ME.message)
                    % For this error, we will be lazy and assume that it is due
                    % to numerical inaccuracies, and so we set it to 0
                    rob = hydis(0);                
                else
                    error(ME.message);
                end
            end
          
        end   


else
    error('tp_taliro: Input is not in the right format.')
end

if nargout == 0 || nargout == 1 
    varargout{1} = rob;
elseif nargout == 2
    varargout{1} = rob;
    varargout{2} = aux;
end

clear mx_tp_taliro

end

