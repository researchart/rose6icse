This folder includes customized optimization algorithms for S-Taliro and 
wrappers for general purpose optimization algorithms.

OPTIMIZATION ALGORITHM

An optimization algorithm should be implemented in an m-file with the 
following interface:

[run, history] = OptimizationAlgo(inpRanges,opt)

where:

 INPUTS:

   inpRanges: n-by-2 lower and upper bounds on initial conditions and
       input ranges, e.g.,
           inpRanges(i,1) <= x(i) <= inpRanges(i,2)
       where n = dimension of the initial conditions vector +
           the dimension of the input signal vector * # of control points

   opt : staliro_options object

 OUTPUTS:
   run: a structure array that contains the results of each run of
       the stochastic optimization algorithm. The structure has the
       following fields:

           bestRob : The best (min or max) robustness value found

           bestSample : The sample in the search space that generated
               the trace with the best robustness value.

           nTests: number of tests performed (this is needed if
               falsification rather than optimization is performed)

           bestCost: Best cost value. bestCost and bestRob are the
               same for falsification problems. bestCost and bestRob
               are different for parameter estimation problems. The
               best robustness found is always stored in bestRob.

           paramVal: Best parameter value. This is used only in
               parameter querry problems. This is valid if only if
               bestRob is negative.

           falsified: Indicates whether a falsification occured. This
               is used if a stochastic optimization algorithm does not
               return the minimum robustness value found.

           time: The total running time of each run. This value is set by
               the calling function.

   history: array of structures containing the following fields

       rob: all the robustness values computed for each test

       samples: all the samples generated for each test

       cost: all the cost function values computed for each test.
           This is the same with robustness values only in the case
           of falsification.
		   
The cost function should be used as follows:

	curVal = Compute_Robustness(curSample);
	
where:

 INPUTS:
 
	curSample - is the current sample.
	
		In case of a non-parallel optimization, this is a vector.
		The length of the vector should be:
		if varying_cp_times = 0, then
			the number of initial conditions (size(init_cond,1)) plus 
			the total number of control points (sum(cp_array)).
		if varying_cp_times = 1,   
			the number of initial conditions (size(init_cond,1)) plus 
			the total number of control points (sum(cp_array)) plus 
			the number of time variables for the control points 
			(max(cp_array)-2).
			Remark: the time variables for the control points should 
			satisfy 0 = t0 <= t1 <= ... <= tn-1 <= tn = TotSimTime
			See SA_Taliro.m and getNewSample.m for this case.
			In a different implementation, the property TotSimTime of
			staliro_options can be used for inferring TotSimTime.
			
		In case of parallel execution, curSample should be a cell 
		vector with length n_workers.
		
 OUTPUTS:
 
	curVal - the temporal logic robustness of the curSample. In case 
		of parallel execution, this is a cell vector of length 
		n_workers.
		
OPTIMIZATION ALGORITHM OPTIONS

The m-file OptimizationAlgo must be accompanied by a class for setting 
the options for the algorithm. The naming convention should be:

	OptimizationAlgo_parameters

The only required property is n_tests which sets the maximum number of 
tests that must be performed by the optimization algorithm.

See UR_Taliro_parameters.m for an example and template.
			
		
			

		   
		   