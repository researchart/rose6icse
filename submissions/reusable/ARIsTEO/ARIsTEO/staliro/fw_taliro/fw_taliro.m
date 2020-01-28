% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% function fw_taliro - Computing the robustness estimate of timed state
% sequences of Metric Temporal Logic formulas
%
% USAGE
%
%         rob = fw_taliro(phi,Pred,seqS,seqT,seqL,CLG,GRD)
%
%
% INPUTS
%
%   phi   - An MTL formula
%
%    Syntax: 
%       phi := p | (phi) | !phi | phi \/ phi | phi /\ phi |
%			| phi -> phi | phi <-> phi | 
%           | X_{a,b} phi | phi U_{a,b} phi | phi R_{a,b} phi | 
%           | <>_{a,b} phi | []_{a,b} phi
%        where:           
%            p     is a predicate. Its first character must be a lowercase 
%                  letter and it may contain numeric digits.
%                  Examples: 
%                         pred1, isGateOpen2  
%            !     is not 
%            \/    is 'or'
%            /\    is 'and'
%			 ->    is 'implies'
%			 <->   if 'if and only if'
%            {a,b} where { is [ or ( and } is ] or ) is for defining 
%				   open or closed timing bounds on the temporal 
%				   operators.
%          X_{a,b} is the 'next' operator with time bounds {a,b}. It
%                  means that the next event should occur within time {a,b}
%                  from the current event. If timing constraints are not
%                  needed, then simply use X.
%          U_{a,b} is the 'until' operator with time bounds {a,b}. If
%                  no time bounds are required, then use U.  
%          R_{a,b} is the 'release' operator with time bounds {a,b}. If
%                  no time bounds are required, then use R.
%         <>_{a,b} is the 'eventually' operator with time bounds {a,b}. If 
%                  no timining constraints are required, then simply use <>.  
%         []_{a,b} is the 'always' operator with time bounds {a,b}. If no 
%				   timining constraints are required, then simply use [].  
%
%          Examples:
%             * Always 'a' implies eventually 'b' within 1 time unit
%                   phi = '[](a -> <>_[0,1] b)';
%               (Bounded response)
%             * 'a' is true until 'b' becomes true after 4 and before 7.5  
%               time units
%                   phi = 'a U_[4,7.5] b';
%             * 'pred1' eventually will become true between 0.1 and 3.6 
%               time units 
%                   phi = '<>_[0.1,3.6) pred1';
%             * 'pred2' must always be true between 1.2 and 2.9 time units 
%               unless 'pred1' becomes true before that
%                    phi = 'pred1 R_(1.2,2.9) pred2';
%
%   Pred - The mapping of the predicates to their respective states.
%
%          Pred(i).str : the predicate name as a string 
%          Pred(i).A, Pred(i).b : a constraint of the form Ax<=b
%              Setting A and b to [] implies no constraints. That is, the set
%              is R^n.
%		   Pred(i).loc : is a vector with the control locations on which  
%              the predicate should hold in case of trajectories of hybrid 
%			   systems. If the control location vector is empty, then the 
%			   predicate should hold in any location, i.e., this is 
%			   equivalent with with including in loc all the Hybrid 
%			   Automaton locations.
%              * Note 1: If of interest is only whether the trajectory enters 
%              a particular control location, then the arrays A and b can be 
%              set to empty, e.g., []. In this case, the continuous part of 
%              the robustness value is set +inf when the trajectory enters 
%              the control location.
%              * Note 2: Location information is used only with hybrid 
%              distance metrics.
%
%   seqS - The sequence of states from a Euclidean space X. Each row must  
%		   be a different sampling instance and each column a different  
%		   dimension in the state space.
%
%		   For example, a 2D signal sampled at 3 time instances is:
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
%		   trajectory. It is assumed that each location has a unique 
%		   numerical (integer) value. It can be omitted in case the 
%		   predicates refer to global conditions on the continuous state 
%          space.
%
%	CLG - The control location graph. This is the adjecency matrix or graph 
%		  omitted of the control locations of the Hybrid Automaton. It can   
%		  be in case the predicates refer to global conditions on the  
%		  continuous state space.
%
%   GRD - Guard set for each edge of the CLG. For each edge (l,m) of CLG, 
%         the set that enables the transition represents a union of j  
%         number of polytopes of the form \/_i=[1...j] A_i x<=b_i where  
%         each A_i x<=b_i is a constraint. Guard set is defined by cell 
%         array structure as follows:
%               GRD(l,m).A = { A_1 A_2 .. A_j }
%               GRD(l,m).b = { b_1 b_2 .. b_j }
%
% OUTPUT
%
%   rob - the robustness estimate. This is a HyDis object for hybrid 
%		  system trajectory robustness. To get the continuous state 
%		  robustness type get(rob,2).
%
% Note: mx_fw_taliro has been ported from C code and it contains a lot of 
% static variables which remain in the Matlab workspace when the call  
% returns from mx_fw_taliro. Currently, these are reset after fw_taliro 
% execution. However, this may cause issues in parallel execution of 
% fw_taliro.

% Copyright (c) 2011  Georgios Fainekos	- ASU							  
% Send bug-reports and/or questions to: fainekos@asu.edu

% History:
% 2011.08.30: GF: Added support for polytopic constraints in the 
%	predicates
% 2011.06.20: GF: Fixed bugs
% 2011.06.03: GF: Added the hybrid metric that includes the guard sets
% 2011.05.25: GF: First stable release

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

function rob = fw_taliro(phi,Pred,seqS,seqT,seqL,A,G)

clear mx_fw_taliro

if nargin==3 || (nargin==4 && isempty(seqT)) ...
        || (nargin==5 && isempty(seqT) && isempty(seqL)) ...
        || (nargin==6 && isempty(seqT) && isempty(seqL) && isempty(A)) ...
        || (nargin==7 && isempty(seqT) && isempty(seqL) && isempty(A) && isempty(G))
    rob = getfield(mx_fw_taliro(phi,Pred,seqS),'ds');
elseif nargin==4 || (nargin==5 && isempty(seqL)) ...
        || (nargin==6 && isempty(seqL) && isempty(A)) ...
        || (nargin==7 && isempty(seqL) && isempty(A) && isempty(G))
    rob = getfield(mx_fw_taliro(phi,Pred,seqS,seqT),'ds');
elseif nargin>=6 && nargin<=7
    if iscell(A)
        CLG = AdjL2AdjM(A);
        Adj = A;
    else
        CLG = A;
        Adj = AdjM2AdjL(A);
    end
    % D(i,j) = min distance from location i to location j
    D = floyd_warshall_all_sp(sparse(CLG)); 
    % Compute the min distance from each location i to the control 
    % locations for each predicate j
    mm = length(A);
    nn = length(Pred);
    DMin = zeros(mm,nn);
    for ii=1:mm
        for jj=1:nn
            if isempty(Pred(jj).loc)
                DMin(ii,jj) = min(D(ii,:));
            else
				DMin(ii,jj) = min(D(ii,Pred(jj).loc));
			end
        end
    end
    if nargin<7 || isempty(G) 
        rob = hydis(mx_fw_taliro(phi,Pred,seqS,seqT,seqL,DMin));
    else
        rob = hydis(mx_fw_taliro(phi,Pred,seqS,seqT,seqL,DMin,Adj,G));
    end
else
    error('fw_taliro: Input is not in the right format.')
end

if nargout == 0 || nargout == 1 
    varargout{1} = rob;
elseif nargout == 2
    varargout{1} = rob;
    varargout{2} = aux;
end

clear mx_fw_taliro

end

