% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function createDemoWithParameters( demoParams )

   % demoParams.fileID : the fileID to print into. Use matlab file open
   % demoParams.modeName: the name of the model. No need to add .mdl suffix
   % demoParams.nInputs: number of inputs
   % demoParams.inputRange: the range of inputs.
   % demoParams.cpArray: number of control points
   % demoParams.inpType: type of interpolation for the input.
   % demoParams.specString: the specification string.
   % demoParams.numPredicates: the number of atomic predicates.
   % demoParams.preds(i): information about the i^th predicate fields are [
   %    name, A, b ]
   % demoParams.numParameters: number of parameters in the formula
   % demoPArams.preds(i): information about i^th parameter [ par,
   % value, range]
   % demoParams.simTime: total time for simulation.
   % demoParams.solverString: string to identify the solver
   % demoParams.specSpace: 'Y' if we specify on output space or 'X' if on
   %     statespace (Note: Latter is quite rare).
   % demoParams.nRuns: number of runs
   % demoParams.nTests: number of tests
   % demoParams.nSpecialParams: number of special settings.
   % demoParams.special(i) : i = 1.. nSpecialParams
   %    has fields specialName and specialValue (we will support just
   %    numerical params for now).
   % demoParams.nViews: number of views necessary.
   % demoParams.viewIDs(i): which output port numbers do you want to see?
   % demoParams.viewType(i): type Input, state or output
   % demoParams.viewTitle(i): the title for this plot.
   % Which file ID should I print the file into.
   fID = demoParams.fileID;
   
   % First print the preamble
   fprintf(fID, '%s \n', 'clear;');
   fprintf(fID, '%% File autoprinted using S-Taliro auto generator. \n');
   
   % TODO: anything else that needs to go into the preamble
   % 1. Print the model name
   
   fprintf(fID, 'model = ''%s''; \n', demoParams.modelName);

   % Constraints on the initial conditions for delays/integrator/discrete transfer  blocks.
   
   fprintf(fID, '%% EDIT: constraints on initial conditions for delays, integrator and discrete transfer blocks.\n');
   fprintf(fID, '%% We highly recommend that you use external inputs to set these \n');
   fprintf(fID, 'initial_cond = [];\n');
   
   
   
   fprintf(fID, '%% EDIT: min/max ranges on input ports \n');
   fprintf(fID, ' input_range = [ ');
   fprintf (fID, ' %f  %f ; ', demoParams.inputRange);
   fprintf (fID, ']; \n');

   fprintf(fID, '%% EDIT: number of control points \n');
   fprintf(fID, ' cp_array =[ ');
   fprintf(fID, ' %f  ', demoParams.cpArray);
   fprintf(fID, '];\n');
   
   fprintf(fID, '%% EDIT: Specification string. \n');
   fprintf(fID, 'phi = ''%s''; \n', demoParams.specString);
   
  
   for i = 1: demoParams.numPredicates
       fprintf(fID, '%% Information for PREDICATE number %d: %s \n', i, demoParams.preds(i).str);
       fprintf(fID, 'preds(%d).str = ''%s''; \n', i, demoParams.preds(i).str);
       fprintf(fID, 'preds(%d).A = ', i);
       prettyPrintMatrix(fID, demoParams.preds(i).A);
       fprintf(fID, 'preds(%d).b = ',i);
       prettyPrintMatrix(fID, demoParams.preds(i).b);
   end   
   if (demoParams.numParameters > 0)
   for i = demoParams.numPredicates+1: (demoParams.numPredicates+demoParams.numParameters)
      fprintf(fID, '%% Information for parameter %d : %s \n', i, demoParams.preds(i).par);
       fprintf(fID, 'preds(%d).par = ''%s''; \n', i, demoParams.preds(i).par);
       fprintf(fID, 'preds(%d).value = %f; \n', i, demoParams.preds(i).value);
       fprintf(fID, 'preds(%d).range = [%f %f]; \n', i, demoParams.preds(i).range(1,1), demoParams.preds(i).range(1,2));
   end
   end
   
   fprintf(fID, '%% EDIT: total simulation time.\n');
   fprintf(fID, 'simTime = %f ; \n', demoParams.simTime);
   
   fprintf(fID, 'opt = staliro_options(); \n');
   
   fprintf(fID, '%% EDIT: Which solver to select \n\n');
   fprintf(fID, 'opt.optimization_solver= ''%s'' \n', demoParams.solverString);
   
   fprintf(fID, 'opt.spec_space = ''%s''; \n', demoParams.specSpace);
   
   fprintf(fID, '%% EDIT: Set some important options\n\n');
   fprintf (fID, 'opt.runs = %d; \n', demoParams.nRuns);
   fprintf(fID, 'opt.n_tests = %d; \n', demoParams.nTests);
   
   strArray={'const', 'pconst', 'pchip', 'spline','linear','nearest'};
   fprintf(fID, 'opt.interpolationtype= { ');
   for i = 1:demoParams.nInputs
       if (i > 1)
           fprintf(fID,' , ');
       end
       fprintf(fID, '''%s''', strArray{demoParams.inpType(i,1)+1});
   end
   fprintf(fID,'}; \n');
   
   for i = 1: demoParams.nSpecialParams
     fprintf(fID, '%% Setting special parameter %s \n', demoParams.special(i).specialName);
     fprintf(fID, 'opt.%s = %f; \n', demoParams.special(i).specialName, demoParams.special(i).specialValue);   
   end
   
   fprintf(fID, 'disp(''Running S-TaLiRo with chosen solver ...'') \n');
   fprintf(fID,'tic\n');
   fprintf(fID, 'results = staliro(model,initial_cond,input_range,cp_array,phi,preds,simTime,opt); \n');
   fprintf(fID, 'runtime=toc;\n');
   
   fprintf(fID, 'results.run(results.optRobIndex).bestRob\n');
   fprintf(fID,' figure \n');
   fprintf(fID,'[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,initial_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),simTime,opt);\n');
   
   for i = 1:demoParams.nViews
        fprintf(fID,'subplot(%d,1,%d) \n', demoParams.nViews, i);
        if (demoParams.viewType(i) == 1)
             fprintf(fID,'plot(IT1(:,1),IT1(:,%d)) \n',demoParams.viewIDs(i)+1);
        else
            if (demoParams.viewType(i)==2)
                 fprintf(fID,'plot(T1,XT1(:,%d))\n',demoParams.viewIDs(i));
            else
                  fprintf(fID,'plot(T1,YT1(:,%d)) \n',demoParams.viewIDs(i));
            end
        end
        
        fprintf(fID,'title(''%s'')\n', demoParams.viewTitle{i});
        fprintf(fID,'hold on \n');
   end
        
   end
   