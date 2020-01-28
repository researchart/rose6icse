% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% function dp_taliro - Computing the robustness estimate of timed state
% sequences of Metric Temporal Logic (MTL) formulas
%
% For the theory see the paper:
% Fainekos, et al. "Verification of Automotive Control Applications using
% S-TaLiRo", ACC 2012
%
% USAGE
%
%         rob = dp_taliro(phi,Pred,seqS,seqT,seqL,CLG,GRD)
%    or,  
%         [rob, aux] = dp_taliro(phi,Pred,seqS,seqT,seqL,CLG,GRD)
%
% INPUTS
%
%   phi   - An MTL formula 
%   
%    Syntax: 
%       phi := p | (phi) | !phi | phi \/ phi | phi /\ phi |
%           | phi -> phi | phi <-> phi | 
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
%            ->    is 'implies'
%            <->   if 'if and only if'
%            {a,b} where { is [ or ( and } is ] or ) is for defining 
%                  open or closed timing bounds on the temporal 
%			       operators.
%          X_{a,b} is the 'next' operator with time bounds {a,b}. It
%                  means that the next event should occur within time {a,b}
%                  from the current event. If timing constraints are not
%                  needed, then simply use X.
%          U_{a,b} is the 'until' operator with time bounds {a,b}. If
%                  no time bounds are required, then use U.  
%          R_{a,b} is the 'release' operator with time bounds {a,b}. If
%                  no time bounds are required, then use R.
%         <>_{a,b} is the 'eventually' operator with time bounds {a,b}. If 
%                  no timining constraints are required, then simply use 
%                  <>.  
%         []_{a,b} is the 'always' operator with time bounds {a,b}. If no 
%		  	       timining constraints are required, then simply use [].  
%
%          Examples:
%             * Bounded response: 
%               Always 'a' implies eventually 'b' within 1 time unit
%                   phi = '[](a -> <>_[0,1] b)';
%             * 'a' is true until 'b' becomes true after 4 and before 7.5  
%               time units 
%                   phi = 'a U_(4,7.5) b';
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
%          Pred(i).A, Pred(i).b : a constraint of the form Ax<=b which 
%			   the predicate i represents
%          Pred(i).proj: a vector of indices of the signal variables in 
%               case, not all the variables are needed in the requirement. 
%               With projection, we can remove columns in A with zero 
%               values to simplify the matrix A. The projection array .proj 
%               must have the corresponding indices in the ascending order.
%               For example, instead of
%               	Pred(i).A = [0,1,0;0,-1,0];
%               we can write
%               	Pred(i).A = [1;-1]; 
%               	Pred(i).proj = [2];
%               Instead of
%               	Pred(i).A = [1,0,-1;1,0,1];
%               we can write
%               	Pred(i).A = [1,-1;1,1]; 
%					Pred(i).proj = [1,3];
%          Pred(i).loc : is a vector with the control locations on which  
%		   	   the predicate should hold in case of trajectories of hybrid 
%		   	   systems. If the control location vector is empty, then the 
%		   	   predicate should hold in any location, i.e., this is 
%		   	   equivalent with including in loc all the Hybrid Automaton 
%		   	   locations.
%          Pred(i).Normalized : 0 - No normalization
%                               1 - normalize robustness to range [-1,1]
%          Pred(i).NormBounds : A 1D or 2D array that contains the bounds 
%              on the distance for normalization.
%              Pred(i).NormBounds(1) : The maximum absolute robustness  
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
%       In case the specification has parameters, as for example described 
%       in the paper:
%          Yang, et al. "Querying Parametric Temporal Logic Properties on 
%          Embedded Systems", ICTSS 2012
%       then these are define in the predicate structure as follows:
% 
%          Pred(i).par : the name of the parameter. One predicate structure
%              can only have non-empty the str or par fields.
%          Pred(i).value : the value of the parameter in case a range is 
%              not provided. 
%          Pred(i).range : search range of a parameter or a predicate. It 
%              can be empty if a value is provided. ? If a parameter has  
%              both value and range defined, then the value will be used.
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
% For a detailed explanation of the following inputs see the help files
% of the class hautomaton. Type "help hautomaton".
%
%   seqL - This is the sequence of locations in case of hybrid system 
%	       trajectory. It is assumed that each location has a unique 
%	       numerical (integer) value. It can be omitted in case the 
%	       predicates refer to global conditions on the continuous state 
%          space.
%
%   CLG - The control location graph. This is the adjacency matrix or graph 
%	      of the control locations of the Hybrid Automaton. It can be  
%	      omitted in case the predicates refer to global conditions on the  
%	      continuous state space.
%
%   GRD - Guard set for each edge of the CLG. For each edge (i,j) of CLG, 
%         the set that enables the transition represents a union of m  
%         number of polytopes of the form 
%						\/_k=[1...m] A_k x<=b_k 
%		  where each A_k x <= b_k is a constraint. The guard set is defined 
% 		  by a cell array structure as follows:
%               GRD(i,j).A = { A_1 A_2 .. A_m }
%               GRD(i,j).b = { b_1 b_2 .. b_m }
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
%		  aux.HA indicates the most related hybrid automata (Default=0)
%		  aux.guardHead indicates the Head location of the most related 
%                       Guard (Default=0)
%		  aux.guardTail indicates the Tail location of the most related     
%                       Guard (Default=0)
%   
%       Example for aux:
%     c_pred = get_predicate_index(aux.pred,pred);
%     SignedDist(x(aux.i,:),c_pred.A,c_pred.b) == dp_taliro(phi,pred,X,T);
%
% See also: dp_t_taliro, fw_taliro, polarity, 

% Copyright (c) 2011  Georgios Fainekos	- ASU							  
% Copyright (c) 2013  Hengyi Yang - ASU							  
% Copyright (c) 2013  Adel Dokhanchi - ASU							  
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

function varargout = dp_taliro(phi,Pred,seqS,seqT,seqL,A,G)

clear mx_dp_taliro

global robCompCounter;
% global staliro_opt;
robCompCounter = robCompCounter + 1;

seqS = double(seqS);

if nargin==3 || (nargin==4 && isempty(seqT)) ...
        || (nargin==5 && isempty(seqT) && isempty(seqL)) ...
        || (nargin==6 && isempty(seqT) && isempty(seqL) && isempty(A)) ...
        || (nargin==7 && isempty(seqT) && isempty(seqL) && isempty(A) && isempty(G))
    [tmp_rob,aux] = dp_taliro_casting(mx_dp_taliro(phi,Pred,seqS));
    rob = tmp_rob.ds;
    
elseif nargin==4 || (nargin==5 && isempty(seqL)) ...
        || (nargin==6 && isempty(seqL) && isempty(A)) ...
        || (nargin==7 && isempty(seqL) && isempty(A) && isempty(G))
    [tmp_rob,aux] = dp_taliro_casting(mx_dp_taliro(phi,Pred,seqS,seqT));
    rob = tmp_rob.ds;
    
elseif nargin>=6 && nargin<=7
    
    % Check whether we have multiple state machines as input
    multiHAs = ~isempty(A) && iscell(A) && iscell(A{1});
    
    % Compute all shortest paths from each state to each other state 
    if multiHAs % Check whether we have multiple state machines as input
        
        s = size(A);
        CLG = cell(s);
        Adj = cell(s);
        D = cell(s);
        mm = cell(s);
        for i=1:length(A)
            if iscell(A(i))
                CLG{i} = AdjL2AdjM(A{i});
                Adj{i} = A{i};
            else
                error('dp_taliro: CLG must be a cell array of calls.')
            end
            D{i} = floyd_warshall_all_sp(sparse(CLG{i})) ;
            mm{i} = length(A{i});
            % See comments and warnings in the else branch below
        end
        
    else

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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % warning('This section of the code has not been updated for use with parameters in the predicate structure')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Easy solution remove predicates that are not used in the formula and
        % short entries so that parameters are at the end and thus can be
        % ignored.
        
    end
    
    [hPar, ~, lPar] = polarity(phi,Pred);
    
    % In case we have parameters 
    if hPar
        idxPred = find(lPar==1);
        idxPar = lPar==2;
        NewPred = [Pred(idxPred) Pred(idxPar)];
        nn = length(idxPred);
    else
        NewPred = Pred;
        nn = length(NewPred);
    end
    
    if multiHAs
        DMin = cell(s);
        for i = 1:length(A)
            DMin{i} = zeros(mm{i},nn);
            for ii = 1:mm{i}
                for jj = 1:nn
                   % Revise to compute distances only to atomic propositions used
                   if isempty(NewPred(jj).loc{i})
                       DMin{i}(ii,jj) = 0;
                   else
                       locs=NewPred(jj).loc{i};
                       DMin{i}(ii,jj) = min(D{i}(ii,locs));
                   end
                end
            end   
        end
    else
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
    end
    
    % dp_taliro code must be modified so only distances for the atomic
    % propositions used are passed to mx_dp_taliro
    if nargin<7 || isempty(G) 
        
       [rob_temp,aux] = dp_taliro_casting(mx_dp_taliro(phi,NewPred,seqS,seqT,seqL,DMin));
       rob = hydis(rob_temp);
       
    else

        try
            % Catching only this call to mx_dp_taliro because it's the only
            % one using the guards, and we're interested in the error
            % involving the signed dist to guards
            [rob_temp,aux] = dp_taliro_casting(mx_dp_taliro(phi,NewPred,seqS,seqT,seqL,DMin,Adj,G));
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
    error('dp_taliro: Input is not in the right format.')
end

if nargout == 0 || nargout == 1 
    varargout{1} = rob;
elseif nargout == 2
    varargout{1} = rob;
    varargout{2} = aux;
else
    error(' dp_taliro: The maximum number of outputs is two. See the dp_taliro help file.')
end

clear mx_dp_taliro

end

