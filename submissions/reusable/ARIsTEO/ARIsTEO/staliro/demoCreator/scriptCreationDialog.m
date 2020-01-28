% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function demoParams = scriptCreationDialog()
    
    fStem = input('Enter the name of the file (without the .m suffix):','s');
    if (isempty(fStem))
       printf(1,' You entered an empty response. Setting file stem to demoScript');
       fStem='demoScript';
    end
    
    fileName = sprintf('%s.m',fStem);
    
    
    demoParams.modelName = '';
    while (isempty(demoParams.modelName))
        demoParams.modelName = input('Enter the name of the model: ','s');
    end
    
    fprintf(1,'MODEL: ''%s'' \n', demoParams.modelName);
    nInputs = -1;
    while (nInputs < 0)
        nInputs=input('Enter the number of inputs: ');
    end
    demoParams.nInputs=nInputs;
    fprintf(1,' Number of model inputs: %d \n', nInputs);
    if (nInputs  <= 0)
        demoParams.inputRange = [];
        demoParams.cpArray=[];
    else
        demoParams.inputRange = zeros(nInputs,2);
        demoParams.cpArray=ones(nInputs,1);
        demoParams.inpType = zeros(nInputs,1);
        for i = 1: nInputs
           fprintf (1,'Input port # %d \n', i);
           demoParams.inputRange(i,1:2) = input('Enter [lo,hi] range for input: ');
           demoParams.cpArray(i,1) = input('Enter how many control points for this input: ');
           if (demoParams.cpArray(i,1) <= 0) 
               demoParams.cpArray(i,1) = 1;
           end
           disp (' Select an interpolation type to use for this input ')
           disp (' ')
           disp(' 5. ''nearest''  - nearest neighbor interpolation ');
           disp(' 4. ''linear'' - linear interpolation');
           disp( ' 3. ''spline''   - piecewise cubic spline interpolation (SPLINE)');
           disp(' 2. ''pchip'' - shape-preserving piecewise cubic interpolation');
           disp(' 1. ''pconst'' - piecewise constant');
           disp(' 0. ''const'' - constant signal (this is the default) ');
           disp(' ')
           demoParms.inpType(i,1) = input ('Select an option (0-5): ');
           if (demoParams.inpType(i,1) < 0 || demoParams.inpType(i,1) > 5)
               demoParams.inpType(i,1) = 0;
           end
         
           
        end
    end
    
    
    demoParams.specString = input('Enter the specification string (MTL): ','s');
    %% TODO: check/provide user help to see if this parses.
    %% TODO: Auto extract the atomic propositions used and drive the remaining prompt.
    
    demoParams.numPredicates = 0;
    
    fprintf(1,'Now tell us about the atomic propositions you used in the string \n');
    
    demoParams.numPredicates = input('How many atomic predicates are there? ');
    
    if (demoParams.numPredicates <= 0)
        demoParams.numPredicates = 0; %% this is wierd.
        fprintf(1,'Warning: no atomic predicates? S-Taliro is not going to do much with this formula. \n ');
    end
    
    for i = 1: demoParams.numPredicates
        fprintf (1, 'Tell me about the predicate number %d \n', i);
        demoParams.preds(i).str = input('Enter the name for predicate: ','s');
        fprintf (1, 'Note: A matrix must have as many columns as the number of outputs \n');
        demoParams.preds(i).A = input('Enter the ''A'' matrix: ');
        [m nn] = size(demoParams.preds(i).A);
        
        
        
        if (m > 0) 
            fprintf(1,' For the vector b, I will expect a %d x 1 vector. \n', m);
            demoParams.preds(i).b = input('Enter the b vector: ');
            [mm nn] = size(demoParams.preds(i).b);
            if ( (nn ~= 1) || (mm ~= m))
               fprintf(1,'Warning: size mismatch between A and b matrices. S-Taliro will definitely complain. \n'); 
            else
               fprintf(1,'Good! Everything looks OK to me so far! \n \n ');
            end
        else
           demoParams.preds(i).b = [];
           fprintf(1,'Warning: you just entered an empty matrix. S-Taliro may reject your predicate input. \n');
        end
        
    end
    
    demoParams.numParameters = input('How many parameters does your formula have? (default = 0): ');
    if (isempty(demoParams.numParameters) || demoParams.numParameters <= 0)
        demoParams.numParameters = 0;
    end
    if (demoParams.numParameters > 0)
    for i = (demoParams.numPredicates+1): (demoParams.numPredicates+demoParams.numParameters)
          fprintf (1, 'Tell me about the paramater number %d \n', i);
          demoParams.preds(i).par = input('Enter name for this parameter ','s');
          demoParams.preds(i).value = input('Enter the value for this parameter: ');
          demoParams.preds(i).range=input('Enter a range for this parameter: ');  
    end
    end
    
    
    fprintf(1, 'Done with entering predicates + parameters \n');
    demoParams.specSpace='Y';
    
    %%demoParams.solverString: string to identify the solver
    
    disp(' ')
    disp (' Select a solver to use ')
    disp (' 1. Simulated Annealing Method. ')
    disp (' 2. Cross Entropy Method. ' )
    disp (' 3. Uniform Random Simulation. ')
    disp (' 4. Genetic Algorithm.')
    disp (' ')
    form_id = input ('Select an option (1-4): ');
    if (form_id == 1)
        demoParams.solverString = 'SA_Taliro';
    else
        if (form_id == 2)
        demoParams.solverString = 'CE_Taliro';
        else if (form_id == 3)
                demoParams.solverString = 'UR_Taliro';
            else
                demoParams.solverString = 'GA_Taliro';
            end
        end
    end

    demoParams.simTime = 0;
    
    while (demoParams.simTime <= 0.0)
        demoParams.simTime = input('Enter Simulation Time (> 0): ');
    end
    
    fprintf(1, 'Now tell me some solver options \n');
    
    demoParams.nRuns = input('Enter the number of runs (default=1): ');
    if (isempty(demoParams.nRuns) || demoParams.nRuns <= 0)
        demoParams.nRuns = 1;
    end
    
    demoParams.nTests = input('Enter the number of test cases to run (default = 5000): ');
    if (isempty(demoParams.nTests) || demoParams.nTests <= 0)
         demoParams.nTests = 5000;
    end
   
    %% Let us deal with this later.
    
    demoParams.nSpecialParams=0;
    
    
    %% enter the number of the views
    
    
    demoParams.nViews = input('How many output views? ');
    
    if (isempty(demoParams.nViews) || demoParams.nViews <= 0)
        demoParams.nViews = 0;
    end
    
    for i = 1: demoParams.nViews
       fprintf(1,'Tell me about view number %d \n', i);
       disp(' ');
       disp('1. View an input port ');
       disp('2. View a state (do you know the ID for sure???)');
       disp('3. (Default) view an output port');
       disp(' ');
       demoParams.viewType(i,1) = input('Enter the view option (1-3): ');
       
       demoParams.viewIDs(i,1) = input('Enter the port number: ');
       
       demoParams.viewTitle{i}= input('Enter a title for the view: ','s');
       
       
    end
    
    fprintf(1,'Output will be printed to script file: %s \n', fileName);
    
    demoParams.fileID = fopen(fileName,'w');
    
    createDemoWithParameters(demoParams);

end