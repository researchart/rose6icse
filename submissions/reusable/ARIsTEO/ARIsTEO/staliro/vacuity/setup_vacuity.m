% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% setup_vacuity will automatically compile all the files needed for
% running stl_debug EXCEPT the third-party software.
%
% The third-party software is:
%   - QTLsolver for MITL satisfiability solver.
%   - NuSMV for LTL satisfiability solver.
%
% In order to run STL/MITL debugging algorithm of MEMOCODE 2015 paper: of
% Dokhanchi, et al. "Metric Interval Temporal Logic Specification
% Elicitation and Debugging", you need to install the third-party software.
%
% Instructions for installing MITL/LTL Satisfiability solvers on Windows 7, 10:
% Last update: 2/28/2018
% 
% 1) Install java
% 
% 2) Install Steel Bank Common Lisp (sbcl): 
%    -  Go to https://sourceforge.net/projects/sbcl/files/sbcl/1.0.55/
%    -  Download sbcl-1.0.55-x86-windows-binary.msi 
%    -  Run sbcl-1.0.55-x86-windows-binary.msi
% 
% 3) Install Z3 SMT solver (Satisfiability Modulo Theories):
%    -  Go to https://github.com/Z3Prover/z3/releases
%    -  Download z3-4.3.2-x86-win.zip
%    -  Unzip z3-4.3.2-x86-win.zip
%    -  Copy z3-4.3.2-x86-win folder to C:\[Desired_Directory] folder.
% 
% 4) Install zot:
%    -  Go to https://code.google.com/archive/p/zot/source/default/source
%    -  Click on Source -> Download
%    -  Unzip source-archive.zip
%    -  Create a new [Desired Directory]\zot folder in C: drive.
%    -  Copy the content of /trunk subfolder of unzipped zot into C:\[Desired_Directory]\zot (new).
% 
% 5) Install qtlsolver (MITL Satisfiability solver):
%    -  Go to https://code.google.com/archive/p/qtlsolver/downloads
%    -  Download qtlsolver-2.0.jar 
%    -  Copy qtlsolver-2.0.jar in the folder of the MATLAB test scripts.
% 
% 6) Install NuSMV (for LTL Satisfiability solver):
%    -  Go to http://nusmv.fbk.eu/NuSMV/download/getting_bin-v2.html
%    -  Register and Download NuSMV-2.6.0-win64.tar.gz
%    -  Unzip NuSMV-2.6.0-win64.tar.gz
%    -  Go to \NuSMV-2.6.0-win64\bin and copy NuSMV.exe in the folder of the MATLAB test scripts.
% 
% 7) Add to Environment Variables -> System Variables -> Path:
% ;C:\[Desired_Directory]\z3-4.3.2-x86-win\bin;C:\[Desired_Directory]\zot\bin;C:\Program Files (x86)\Steel Bank Common Lisp\1.0.55
%
% (C) 2018 by Adel Dokhanchi
% Send bug-reports and/or questions to: Georgios Fainekos (fainekos@asu.edu)

function setup_vacuity(varargin)
skip_mex = 0;
if nargin == 1
    skip_mex = varargin{1};
end

path_var=pwd;
addpath(path_var);

if ~skip_mex
    mex mx_debugging.c cache.c distances.c lex.c mtl_vacuity.c parse.c rewrt.c
end


disp('***************************************************************************')
disp('You are all set to use vacuity!')
disp('Type "help vacuity" to get a detailed description of using the tool.')
disp('***************************************************************************')

