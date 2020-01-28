runProperty script under the folder trunk performs a test for R1.6 of Autopilot
It generates inputs driven by UR_Taliro and runs the inputs on Autopilot 

-------------------------
Go to staliro_options.m :
- Set the optimization parameters for the optimization algorithm. 
	* Choose the algorithm among the list under optimisation folder.
	* set the following properties 
	priv_optimization_solver = 'UR_Taliro';
	priv_optim_params = UR_Taliro_parameters;
- Choose interpolation function for input signals for input types.
  Default option : interpolationtype = {'pchip'};  
- Run staliro_options.m
- Restart Matlab

The inputs of staliro are:
- model: a string with the name of the Simulink model, a pointer function oran object of the hybrid automata class- icond: a hypercube defining the set of initial conditions- irange: a hypercube defining the set of constraints on the inputs- cparray: the number of control points for each input signal- phi: a string with the MTL formula- pred: a structure with the atomic proposition mapping- tt: the total simulation time- opt: various S-TaLiRo options

- Formulate phi using pred.b, pred.A, pred.str that are described under tp_taliro/tp_taliro.m

Res = staliro(model,icond,irange,cparray,phi,pred,tt,opt);
