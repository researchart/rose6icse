
To setup S-TaLiRo run the following in the Matlab command window:
>> setup_staliro

Other Required Matlab Packages

1. For the hybrid distance metric with distances to the location guards the Matlab package MatlabBGL is required:
   http://www.mathworks.com/matlabcentral/fileexchange/10922
2. For the Powertrain demo example CheckMate is required. CheckMate is not publicly available anymore so please send us an email.
3. Toolboxes required for running the Robust Testing Toolbox:
	1) Multi Parametric Toolbox (http://control.ee.ethz.ch/~mpt/)
	   Tested version 3.0
	2) Ellipsoidal Toolbox (http://code.google.com/p/ellipsoids/)
	   Tested version 1.1.2
	3) CVX: Disciplined Convex Optimization (http://cvxr.com/cvx/)
	   Tested version 1.21
4. Toolboxes required for the motion planning demos. 
	1) Robotics Toolbox	(http://www.petercorke.com/Robotics_Toolbox.html)
	2) Multi Parametric Toolbox (http://control.ee.ethz.ch/~mpt/)

Note For Linux/Mac Users
	Before running S-Taliro setup, make sure the version of both gcc and g++ is supported by Matlab mex function.

Further information on S-TaLiRo:
	* Assembla wiki: https://www.assembla.com/spaces/s-taliro_public/wiki
	* TaLiRo tools website: https://sites.google.com/a/asu.edu/s-taliro/ 
	
Other toolboxes or part of toolboxes included in the S-TaLiRo distribution:
	* minimize by Rody Oldenhuis: http://www.mathworks.com/matlabcentral/fileexchange/24298-minimize for the Nelder-Mead optimization algorithm.
	
HISTORY

April 4, 2015
	* Version S-Taliro 1.6 is posted on the public SVN repository:
	  https://subversion.assembla.com/svn/s-taliro_public/
	  For new features and bug-fixes see the commit history at:
	  https://www.assembla.com/spaces/s-taliro_public/subversion/commits/list
	  
S-Taliro Ver. 1.61 (not publicly distributed)
	* Added Graphical User Interface.
	* Added runtime monitoring.
S-Taliro Ver. 1.6
	* Added multiple parameter estimation for MTL specifications.
S-Taliro Ver. 1.52
	* Added benchmarks for the Applied Verification for Continuous and Hybrid Systems 2014 workshop.
S-Taliro Ver. 1.51
	* Added support for setting the random number generator seed option for Matlab 2010b.
	* Bug fix: S-TaLiRo checks if the Parallel Computing Toolbox is installed and licensed before attempting parallelized simulations.
	* Bug fix: If opt.n_workers is set to 0 or 1, S-TaLiRo will not use the Parallel Computing Toolbox.
S-Taliro Ver. 1.5
	* Added the feature to indicate to S-Taliro to only focus on specific outputs of the system 
	* Added the feature to include variable distribution of control points in the search space
	* Added the option to undersample the output trajectories in the case that the they are too long and cause dp_taliro to crash due to limited memory.
	* Added support for the use of the parallel toolbox with optimization functions.
	* CE_Taliro now supports the hybrid distance metric without using map2line
	* CE_Taliro and SA_Cold_Stoch now return history
	* Separate classes for the options of optimization functions
	* Updated demos and benchmarks to conform to the new options setup
	* Added demos for falsification of stochastic systems (staliro_demo_stoch_cold_chain) and for conformance testing (staliro_demo_conformance)
	* Added the option to set the seed for the random generator for S-Taliro
	* Added the option to have S-Taliro save the results of each run as soon as they are done.
	* Bug fix: dp_taliro and dp_t_taliro: The code for the weak next operator was removed in version 1.4 and that caused dp_taliro and dp_t_taliro to crash if a next time operator appeared under a negation operator.
S-Taliro Ver. 1.4
	* Added MTL parameter estimation
	* dp_taliro can now be used within the Matlab Parallel Computing Toolbox
	* Added optimizer for noisy cost functions (SA_cold)
	* Added dp_t_taliro for computing time robustness. This is an alpha version and it has not been thoroughly tested.
	* Added a quick user guide
	* Added interactive scripts for generating m-scripts for calling S-Taliro. The scripts are under demoCreator folder.
	* Bug fix: dp_taliro: Fixed bug in boundary conditions of temporal operators. In certain cases, if the total signal duration was shorter than that required by the temporal logic formula and the formula was using the X operator or hybrid distances, then the robustness value might not have been computed correctly.
S-Taliro Ver. 1.3 
	* Added option for minimization 
	* Added in the distribution dp_taliro and fw_taliro
	* Added robust tester for hybrid automata
S-Taliro Ver. 1.2 
	* Added the Cross Entropy method
	* Added scripts for all the benchmark problems
  
KNOWN ISSUES
	* Only dp_taliro and dp_t_taliro can be called within the Matlab Parallel Computing Toolbox.
	* The user manual has not been updated to reflect the changes between versions 1.0 and 1.1. Thus, please use the help files for the latest information.

LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.                                    

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.                           

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
