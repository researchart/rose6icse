% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%DOUBLE_INTEGRATOR_PARU 2nd order LTI example with polytopic uncertainty
%
% ---------------------------------------------------------------------------
% DESCRIPTION
% ---------------------------------------------------------------------------
%
% 2nd order Double Integrator dynamics with 2 states and 1 control input
% 
% Default values are:
%   * Norm 2
%   * Prediction horizon N = 5
%   * Weight in the cost function Q = I, R = 1
%   * No bounds on x0
%   * Level of suboptimality = 0
%   * Parametric uncertainty 
%
% Correct results:
% probStruct.N          :  5 |  8 | Inf | Inf | Inf
% probStruct.subopt_lev :  0 |  0 |  0  |  1  |  2
% # regions             : 41 | 57 | 69  | 66  |  7
%
%
% USAGE:
%   Double_Integrator_parU
%   ctrlStruct = mpt_control(sysStruct,probStruct);
%
% ---------------------------------------------------------------------------
% INPUT
% ---------------------------------------------------------------------------
% none
%
% ---------------------------------------------------------------------------
% OUTPUT                                                                                                    
% ---------------------------------------------------------------------------
% sysStruct, probStruct - system and problem definition structures stores
%                         in the workspace
%

% Copyright is with the following author(s):
%
% (C) 2003 Michal Kvasnica, Automatic Control Laboratory, ETH Zurich,
%          kvasnica@control.ee.ethz.ch
% (C) 2003 Pascal Grieder, Automatic Control Laboratory, ETH Zurich,
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

%+++++++++++++++++++++++++++++++++++++++
%Loads relevant matrices for the
%double integrator example
%
%(c) Pascal Grieder: grieder@aut.ee.ethz.ch
%+++++++++++++++++++++++++++++++++++++++

clear sysStruct probStruct

%x(k+1)=Ax(k)+Bu(k)
sysStruct.A= [1 1; 0 1];
sysStruct.B= [1; 0.5];

%y(k)=Cx(k)+Du(k)
sysStruct.C= [1 0; 0 1];
sysStruct.D= [0;0];

%definition of parametric uncertainty
pct=0.3;
sysStruct.Aunc{1}=sysStruct.A*(1-pct);
%sysStruct.Aunc{2}=sysStruct.A*(1-2*pct);
sysStruct.Aunc{2}=sysStruct.A*(1+pct);

sysStruct.Bunc{1}=sysStruct.B;
sysStruct.Bunc{2}=sysStruct.B;

%set constraints on output
sysStruct.ymin    =   [-5; -5];
sysStruct.ymax    =   [5; 5];

%set constraints on input
sysStruct.umin    =   -1;
sysStruct.umax    =   1;

% string labels for states, inputs and outputs
sysStruct.StateName = { 'Position', 'Speed' }; 
sysStruct.InputName = 'Acceleration';
sysStruct.OutputName = { 'Position', 'Speed' };

probStruct.norm=2;
probStruct.Q=eye(2);
probStruct.R=1;
probStruct.N=5;
probStruct.x0bound=0;
probStruct.subopt_lev=0;