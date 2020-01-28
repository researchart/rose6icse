% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% 1) Modifying the STL/MTL formula and checking the specifications for
%    logical inconsistencies (validity, redundancy, vacuity).
% 2) Creating the Antecedent-Failure mutation for signal vacuity detection.
%
% WARNING: Finding logical inconsistencies needs MITL/LTL satisfiability
%          solvers. For more information about installing MITL/LTL 
%          satisfiability solvers run:
%          >> help setup_vacuity
%
% USAGE
%
%         report = stl_debug(phi,Pred,opt,debug_type,redound_type)
%
%
% INPUTS
%
%   phi   - An MTL/STL formula
%
%    Syntax: 
%       phi := p | (phi) | !phi | phi \/ phi | phi /\ phi |
%			| phi -> phi | phi <-> phi | 
%           | X_{a,b} phi | phi U_{a,b} phi | phi R_{a,b} phi | 
%           | <>_{a,b} phi | []_{a,b} phi
%        where:           
%            p     is a predicate. Its first character must be a lower-case 
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
%            Note: For STL debugging where debug_type is 'validity' or
%                  'redundancy' or 'vacuity', the interval must be
%                  right-closed. Therefore } CANNOT be ). 
%                  Also a,b must be integer values.
%          X_{a,b} is the 'next' operator with time bounds {a,b}. It
%                  means that the next event should occur within time {a,b}
%                  from the current event. If timing constraints are not
%                  needed, then simply use X.
%          Note 1: For STL debugging where debug_type is 'validity' or
%                  'redundancy' or 'vacuity', X operator is not allowed
%          Note 2: For STL debugging where debug_type is 'antecedent_failure',
%                  antecedent of implication (->) operator cannot be a 
%                  subformula of any X operator because Effective Interval 
%                  (EI) is not defined for X operator.   
%          U_{a,b} is the 'until' operator with time bounds {a,b}. If
%                  no time bounds are required, then use U.  
%            Note: The 'until' operator in not supported for STL debugging 
%                  where debug_type is 'validity' or 'redundancy' or
%                  'vacuity'.
%          R_{a,b} is the 'release' operator with time bounds {a,b}. If
%                  no time bounds are required, then use R.
%            Note: The 'release' operator in not supported for STL debugging 
%                  where debug_type is 'validity' or 'redundancy' or
%                  'vacuity'.
%         <>_{a,b} is the 'eventually' operator with time bounds {a,b}. If 
%                  no timing constraints are required, then simply use <>.
%            Note: Unbounded 'eventually' operator is not supported for STL 
%                  debugging where debug_type is 'validity' or 'redundancy'
%                  or 'vacuity'.
%         []_{a,b} is the 'always' operator with time bounds {a,b}. If no 
%				   timing constraints are required, then simply use [].  
%            Note: Unbounded 'always' operator is not supported for STL 
%                  debugging where debug_type is 'validity' or 'redundancy'
%                  or 'vacuity'.
%
%         Examples for debug_type = 'validity' or 'redundancy' or 'vacuity':
%             * At some point in time in the first 30 seconds, vehicle speed 
%                  will go over 100 and stay above for 20 seconds:
%                   phi = '<>_[0,30][]_[0,20]( p1 )'
%             * At every point in time in the first 40 seconds, vehicle speed
%                   will go over 100 in the next 10 seconds:
%                   phi = '[]_[0,40]<>_[0,10]( p1 )'
%             * If, at some point in time in the first 40 seconds, vehicle 
%                   speed goes over 100 then from that point on, for the next 
%                   30 seconds, engine speed should be over 4000:
%                   phi = '<>_[0,40]( p1 -> []_[0,30]( p2 ) )'
%             * At some point in time in the first 40 seconds, vehicle speed 
%                   should go over 100 and then from that point on, for the 
%                   next 30 seconds, engine speed should be over 4000.
%                   phi = '<>_[0,40]( p1 /\ []_[0,30]( p2 ) )'
%             where:
%                   p1 : speed>100
%                   p2 : rpm>4000
% 
%         Examples for debug_type = 'antecedent_failure' (Request Response):
%             * Always in 10 unit time 'REQ' (Request) implies eventually 'ACK'
%                   (Acknowledge) within 5 time unit (Bounded response):
%                   phi = '[]_[0,10](REQ -> <>_[0,5] ACK)'
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
%   opt -  s-taliro options. opt should be of type "staliro_options". 
%          If the default options are going to be used, then this input may 
%          be omitted. For instructions on how to change S-Taliro options, 
%          see the staliro_options help file for each desired property.
%
%          When debug_type = 'validity' or 'redundancy' or 'vacuity' the
%          parameter of opt.vacuity_param.use_LTL_satifiability is checked
%          to be 1 in order to use LTL satisfiability solver before MITL
%          satisfiability solver. LTL satisfiability is used when the modified 
%          formula contains only ALWAYS or EVENTUALLY operators.
%
%   debug_type - Must contain one of the following values:
%          - 'validity' for checking the validity issue in STL/MITL.
%          - 'redundancy' for checking the redundancy issue in STL/MITL.
%          - 'vacuity' for checking the vacuity issue in STL/MITL.
%          - 'antecedent_failure' for creating the Antecedent Failure of a
%            Request-Response MTL/STL formula that contain one implication
%            operation in the positive form.
%
%   redound_type - Specifies the level of redundancy checking (Optional):
%          - 'root' (Default Value) checks the redundancy with respect to
%             the whole formula if the specification is a conjunction of 
%             STL/MITL formulas.
%          - 'subTrees' checks the redundancy with respect to any conjunctive
%             subformula if the specification contains conjunctive subformulas.
%          - 'allNodes' check all the redundancies with respect to all
%             conjunctive formulas.
%
%
% OUTPUT
%     report: String contains one of the following:
%          1 - Empty if there is no specification issue.
%          2 - Textual description of the logical issue in the specification.
%          3 - Antecedent Failure of MTL formula for signal vacuity where
%              debug_type = 'antecedent_failure'
%
%
%
% Copyright (c) 2018  Adel Dokhanchi	- ASU							  
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

function [report] = stl_debug(phi,Pred,opt,debug_type,redound_type)% for memocode/tecs

clear mx_debugging
report=[];
if ischar(debug_type)==0
    error('Debug_type must be a string');
end

if nargin==4
    mitl  = mx_debugging(phi,Pred,debug_type);
elseif nargin==5
    mitl  = mx_debugging(phi,Pred,debug_type,redound_type);
else
    error('mx_debugging: Input is not in the right format.')
end

if(isempty(mitl))
    report=[];
    return;
end

disp('  ');
s=size(mitl);
assignin('base','mitl', mitl);
c=mitl;

if  strcmp(debug_type,'antecedent_failure')==1
    report=mitl;
    return;
end
c=cellstr(mitl);
report=[];
testMITL=1;
for ii=1:s(1)
    if mod(ii,3) == 2 
        if    testMITL ==1
            disp('test with MITL Satisfiability solver');
            fid(ii) = fopen( 'output.tl', 'w' );
            fprintf(fid(ii),':mitl-i\n:bound 20\n\n\n:formula %s\n',c{ii});
            fclose(fid(ii));
        	command = 'dir';
            [status,cmdout] = system(command);
            command = 'java -jar qtlsolver-2.0.jar output.tl';
            [status,cmdout] = system(command);
            command = 'zot output.cltl';
            [status,cmdout] = system(command);
            assignin('base', 'cmdout', cmdout);  
            if(isempty(strfind(cmdout,'---SAT---'))==0)
                disp('MITL is satisfiable');
            end
            if(isempty(strfind(cmdout,'---UNSAT---'))==0)
                disp('MITL is UN-satisfiable');
                disp('!!!!ERROR:');
                disp(c{ii+1});
                disp(phi);
                report=['ERROR: ',c{ii+1},' ',phi,' .'];
                return;
            end
            delete('output.cltl');
        end
    elseif mod(ii,3) == 1 && opt.vacuity_param.use_LTL_satifiability==1
        testMITL =1;
        if(isempty(strfind(c{ii},'MITL'))==1)
            fid(ii) = fopen( 'ltl.smv', 'w' );
            l=length(Pred);
            fprintf(fid(ii),'MODULE main\nVAR\n');
            for jj=1:l
                fprintf(fid(ii),'%s  : boolean;\n',Pred(jj).str);
            end
            fprintf(fid(ii),'LTLSPEC  !( %s )\nFAIRNESS TRUE',c{ii});
            fclose(fid(ii));
        	command = 'NuSMV.exe ltl.smv';
            [status,cmdout] = system(command);
            if(isempty(strfind(cmdout,'is false'))==0)
                disp('LTL is satisfiable');
                if(isempty(strfind(c{ii},'F'))==0)
                    disp('EVENTUALLY only operator');
                elseif (isempty(strfind(c{ii},'G'))==0)
                    disp('ALWAYS only operator');
                    disp('No need to check MITL');
                    testMITL =0;
                end
            end
            if(isempty(strfind(cmdout,'is true'))==0)
                disp('LTL is UN-satisfiable');
                if(isempty(strfind(c{ii},'F'))==0)
                    disp('No need to check MITL');
                    disp('EVENTUALLY only operator');
                    testMITL =0;
                    disp('!!!!ERROR:');
                    disp(c{ii+2});
                    disp(phi);
                    report=['ERROR: ',c{ii+2},' ',phi,' .'];;
                    return;
                elseif (isempty(strfind(c{ii},'G'))==0)
                    disp('ALWAYS only operator');
                end
            end
        end
    end
clear mx_debugging
end

