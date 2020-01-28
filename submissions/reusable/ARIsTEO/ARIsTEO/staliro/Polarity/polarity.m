% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% function polarity - Computing the polarity of given formula
%
% USAGE
%
%   [has_param, phi_polarity, list_param] = polarity(phi,Pred)
%
% INPUTS
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
%                  no timining constraints are required, then simply use <>.  
%         []_{a,b} is the 'always' operator with time bounds {a,b}. If no 
%		  	       timining constraints are required, then simply use [].  
%
%
%   Pred - The mapping of the predicates to their respective states.
%
%          Pred(i).str : the predicate's name as a string if .par is empty.
%          Pred(i).par : is a string to specify time/magnitude parameters.
%               It is time parameter if Pred(i).str is not given (empty).
%               It is magnitude parameter if Pred(i).str is provided as
%               well (.str is not empty).
%          Pred(i).value : the value of the parameter
%          Pred(i).range : search range of a parameter 
%          Pred(i).A, Pred(i).b : a constraint of the form Ax<=b
%               Note that if Pred(i) is a magnitude parameter, Pred(i).b
%               should be the same dimention as Pred(i).value, and also the
%               value would take over b.
%          
%          Rules of Pred : Predicates and parameters are at the same level.
%               Value field must exist alongside par field to indicate the 
%               value of the parameter. If a parameter has both value and 
%               range indicator the value would take over.              
%               
%          Examples:
%             * Always 'a' implies eventually 'b' within K time units,
%               where K is the time parameter:
%               Pred(1).par='K';
%               Pred(1).value=1;
%               Pred(1).range=[0 2];
%                   phi = '[](a -> <>_[0,K] b)';
%             * 'a' is true until 'b' becomes true after K and before 7.5  
%               time units, where K is the time parameter: 
%                   phi = 'a U_(K,7.5) b';
%             * 'predPar1' eventually will become true between 0.1 and 3.6 
%               time units, where 'par1' is a magnitude parameter of the
%               form (Ax<=par1): 
%               Pred(2).str='predPar1';
%               Pred(2).par='par1';
%               Pred(2).A=1;
%               Pred(2).b=1;
%               Pred(2).value=1;
%               Pred(2).range=[0 2];
%                   phi = '<>_[0.1,3.6) predPar1';
%             * 'pred2' must always be true between K and 2.9 time units 
%               unless 'predPar1' becomes true before that, where K is the
%               time parameter, and 'par1' is a magnitude parameter of the
%               form (Ax<=par1):
%                    phi = 'predPar1 R_(K,2.9) pred2';
%
%
% OUTPUTS
%
%   has_param - indicate if the formula has parameter or not. Output 1 when
%               there are parameters in the formula and output 0 otherwise.
%
%   phi_polarity - polarity of formula. Here: 	
%     POSITIVE_POLARITY = 1, i.e. non-decreasing robustness wrt. parameter
%     NEGATIVE_POLARITY = -1, i.e. non-increasing robustness wrt. parameter
%     MIXED_POLARITY = 0,
%     UNDEFINED_POLARITY = 2,
%
%   list_param - A vector that with the same size as the predicate map.
%       Each entry has value:
%          1 - if it is a fully defined predicate used in the formula (with
%              no parameter), i.e. it maps to a subset of the state space.
%          2 - if it is a time parameter used in the formula
%          3 - if it is a predicate in the formula with magnitude parameter 
%              'p' in its right hand side of the predicate map (Ax<=p).
%          0 - if the predicate or paramter is not not used in the formula
%              but specified in Preds structure.
%       For example
%           list_param(1) = 2 means the first item in the predicate map 
%           list is a time parameter and it is used in the formula phi.
%

% Copyright (c) 2011  Georgios Fainekos	- ASU							  
% Send bug-reports and/or questions to: fainekos@asu.edu
% Last update: 2015.07.10 by Adel Dokhanchi

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


function [has_param, phi_polarity, list_param] = polarity(phi,Pred)

clear mx_polarity

temp = casting_polarity(mx_polarity(phi,Pred));

phi_polarity = temp.polarity;
list_param = temp.index;

if(phi_polarity == 2)
        has_param = 0;
else
        has_param = 1;   
end

clear mx_polarity

end
