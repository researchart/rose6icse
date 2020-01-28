% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [locHis,listOfCheckedLocations ,seenList,unseenList,results,history,falsified] ...
    = Structural_Coverage(model, init_cond, input_range, cp_array, phi, preds, time, opt)
%FUNCTIONAL_COVERAGE Summary of this function goes here
%   Detailed explanation goes here
global  strlCov_locationHistory;

    listOfCheckedLocations=[];
    seenList=[];
    unseenList=[];
    locHis=[];
    numupdates=0;
    numVisitLoc=0;

disp('STRUCTURAL_COVERAGE');

% Check for the options
if(nargin<8) || isempty(opt)
    staliro_opt = staliro_options();
else
    if ~isa(opt,'staliro_options')
        error('S-Taliro: the options must be an staliro_options object')
    end
    staliro_opt = opt;
end
% disp(staliro_opt.StrlCov_params.locSearch);   
staliro_opt.runs=1;
if staliro_opt.StrlCov_params.nLocUpdate <= 0
    error('STRUCTURAL_COVERAGE: number of location update must be positive')
end

% if isempty(phi)
%     phi = 'true';
%     i=1;
%     preds(i).str='dummy';
%     preds(i).A = [];
%     preds(i).b = []';
%     staliro_opt.optimization_solver='UR_Taliro';
%     opt.optim_params.n_tests=100;
% end

if staliro_opt.StrlCov_params.instumentModel > 0
   disp('MODEL_INSTRUMENTATION');
   %%Added by Rahul
   if isempty(staliro_opt.StrlCov_params.modelInitFile)
        modelInitFile = '';
   else
       if ~ischar(staliro_opt.StrlCov_params.modelInitFile)
           error('STRUCTURAL_COVERAGE: the model initializing file must be a string without file extension');
       end
       modelInitFile = staliro_opt.StrlCov_params.modelInitFile;
   end
   if isempty(staliro_opt.StrlCov_params.exclusionlist)
        exclusion_list = {};
   else
       if ~iscell(staliro_opt.StrlCov_params.modelInitFile)
           error('STRUCTURAL_COVERAGE: the exclusion list must be cell array of blocks to be excluded');
       end
       exclusion_list = staliro_opt.StrlCov_params.exclusionlist;
   end
   %%%%
   bdclose all;
   if staliro_opt.StrlCov_params.instumentModel==1
       %output_struct=model_instrumentation(model,0);
       output_struct=model_instrumentation(model,modelInitFile,0,exclusion_list);%new API for model Instr
   else
       %output_struct=model_instrumentation(model,1);
       output_struct=model_instrumentation(model,modelInitFile,1,exclusion_list);
   end
   new_BBox=output_struct.BBox_file_name;
   num_of_HAs= output_struct.num_of_HAS;
   HAs_state_matrix=output_struct.HAs_state_matrix;
   
   
   model=str2func(new_BBox);
   sz=size(preds);
   maxPredID=sz(2);
   new_outports = output_struct.extra_outports_added;
   for i=1:maxPredID
       preds(i).loc=cell(1,num_of_HAs);
       try 
           if isempty(preds(i).proj)
               error('Projection must be not empty')
           end
       catch
           s=size(preds(i).A);
           zeroPred=zeros(s(1),new_outports);
           preds(i).A=[preds(i).A zeroPred];
       end
   end
   staliro_opt.StrlCov_params.numOfMultiHAs=HAs_state_matrix;
   staliro_opt.black_box=1;
   staliro_opt.taliro_metric='hybrid';
   staliro_opt.StrlCov_params.multiHAs=1;

end


if staliro_opt.falsification ~=1
    error('STRUCTURAL_COVERAGE: is only for falsification')
end

if  staliro_opt.StrlCov_params.pathCoverage ~= 0
    error('STRUCTURAL_COVERAGE: path coverage is not supported yet')
end

if  staliro_opt.StrlCov_params.startUpTime<0
    error('STRUCTURAL_COVERAGE: startup time must be non-negative')   
end

if staliro_opt.StrlCov_params.multiHAs==0
    LocTrace=cell(staliro_opt.StrlCov_params.nLocUpdate+1,staliro_opt.runs);
    predIDs=zeros(staliro_opt.StrlCov_params.nLocUpdate+1,staliro_opt.runs);
else
    staliro_opt.black_box = 1;
end 

[results{1}, history{1}, staliro_opt] = staliro(model, init_cond, input_range, cp_array, phi, preds, time, staliro_opt);


falsified=[];
sz=size(preds);
maxPredID=sz(2);
nLoc_loc_pred=0;
new_phi_ID=0;
locID=zeros(1,staliro_opt.StrlCov_params.numOfParallel);
new_phi=cell(1,staliro_opt.StrlCov_params.numOfParallel);

if strcmp(staliro_opt.taliro_metric,'none')==1 
     staliro_opt.taliro_metric='hybrid';
end

if  strcmp(staliro_opt.StrlCov_params.locSearch, 'specific')
       s=size(staliro_opt.StrlCov_params.specificLoc);
       staliro_opt.StrlCov_params.nLocUpdate=s(1);
       if staliro_opt.StrlCov_params.multiHAs==1
            if(s(2)~=length(staliro_opt.StrlCov_params.numOfMultiHAs))
                error('the number if HAs does not match with the specificLoc columns');
            end
       else
          if  iscell(staliro_opt.StrlCov_params.specificLoc)
              error('In single HA the specificLoc must be array');
          end
       end
       numupdates=s(1);
       listOfCheckedLocations=staliro_opt.StrlCov_params.specificLoc;
end

if   staliro_opt.StrlCov_params.multiHAs==1 
     nHA=length(staliro_opt.StrlCov_params.numOfMultiHAs);
     max_possible_locs=1;
     for ii=1:nHA
         max_possible_locs=max_possible_locs*staliro_opt.StrlCov_params.numOfMultiHAs(ii);
     end
     if(max_possible_locs<staliro_opt.StrlCov_params.nLocUpdate)
         disp('The number of possible locations is');
         disp(max_possible_locs);
         disp('But the number of location updates is');
         disp(staliro_opt.StrlCov_params.nLocUpdate);                
         return;
     end
end


bestrob=inf;
if  staliro_opt.StrlCov_params.multiHAs==0
    pathLoc=cell(staliro_opt.runs,staliro_opt.optim_params.n_tests);
    locationNumbers=staliro_opt.StrlCov_params.singleHALocNum;
    for iter=1:staliro_opt.StrlCov_params.nLocUpdate
        disp('Iteration number is');
        disp(iter); 
        if(iter==1)
            falsified=results{iter}.run(1).falsified;
            if(falsified==1)
                disp('SPECIFICATION IS FALSIFIED');
                return;
            end

            locHis=[];
                if  staliro_opt.StrlCov_params.chooseBestSample==1
                    if staliro_opt.black_box==0
                        XPoint = results{iter}.run(1).bestSample(:,1);
                        inputModel = model;
                        if length(inputModel.init.loc)>1
                            for cloc = 1:length(inputModel.init.loc)
                                l0 = cloc;
                                actGuards = inputModel.adjList{cloc};
                                noag = length(actGuards);
                                for jLoc = 1:noag
                                    notbreak = 0;
                                    nloc = actGuards(jLoc);
                                    if staliro_opt.hasim_params(1) == 1
                                        if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b,'<')
                                            notbreak = 1;
                                            break
                                        end
                                    else
                                        if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b)
                                            notbreak = 1;
                                            break
                                        end
                                    end
                                end
                                if ~notbreak
                                    break
                                end
                            end
                        else
                            l0 = inputModel.init.loc(1);
                        end
                        h0 = [l0 0 XPoint'];
                        [ hh , locHis ]= hasimulator(model,h0,time,staliro_opt.ode_solver,staliro_opt.hasim_params);
                    else
                        [T1,XT1,YT1,IT1,locHis,CLG1,GRD1] = SimBlackBoxMdl(model,init_cond,input_range,cp_array,results{iter}.run(1).bestSample,time,staliro_opt);
                        locHis=locHis';
                    end
                else
                   sh=size(history{iter}.samples);
                   for i1=1:sh(1)
                       LT=strlCov_locationHistory{i1};
                       sLT = [LT(1); LT(1:end-1)];
                       pathLoc{1,i1} = [LT(1); LT(LT-sLT ~= 0)];
                       locHis=[locHis pathLoc{1,i1}'];
                   end
                end 
                locHis;
                LocTrace{iter,1}=locHis;
                if iter==1
                    numOfIterationsWithVisitLoc=zeros(1,locationNumbers);
                    totalNumberOfVisits=zeros(1,locationNumbers);
                end
                s=size(locHis);
                if(s(1)~=1)
                    error('STRUCTURAL_COVERAGE: location trace should be a row vector')
                end
                visited=zeros(1,locationNumbers);
                for j=1:locationNumbers
                    for k=1:s(2)
                        if locHis(1,k)==j
                            visited(1,j)=1;
                            totalNumberOfVisits(1,j)=totalNumberOfVisits(1,j)+1;
                        end
                    end
                end
                for j=1:locationNumbers
                    if  visited(1,j)==1
                        numOfIterationsWithVisitLoc(1,j)=numOfIterationsWithVisitLoc(1,j)+1;
                    end
                end
        else
            falsified=[falsified; results{iter}.run(1).falsified];
            if(results{iter}.run(1).falsified==1)
                disp('SPECIFICATION IS FALSIFIED');
                return;
            end

            if(staliro_opt.StrlCov_params.numOfParallel==1)
                if  staliro_opt.StrlCov_params.chooseBestSample==1
                    if staliro_opt.black_box==0
                        XPoint = results{iter}.run(1).bestSample(:,1);
                        inputModel = model;
                        if length(inputModel.init.loc)>1
                            for cloc = 1:length(inputModel.init.loc)
                                l0 = cloc;
                                actGuards = inputModel.adjList{cloc};
                                noag = length(actGuards);
                                for jLoc = 1:noag
                                    notbreak = 0;
                                    nloc = actGuards(jLoc);
                                    if staliro_opt.hasim_params(1) == 1
                                        if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b,'<')
                                            notbreak = 1;
                                            break
                                        end
                                    else
                                        if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b)
                                            notbreak = 1;
                                            break
                                        end
                                    end
                                end
                                if ~notbreak
                                    break
                                end
                            end
                        else
                            l0 = inputModel.init.loc(1);
                        end
                        h0 = [l0 0 XPoint'];
                        [ hh , LT ]= hasimulator(model,h0,time,staliro_opt.ode_solver,staliro_opt.hasim_params);
                    else
                        [T1,XT1,YT1,IT1,LT,CLG1,GRD1] =SimBlackBoxMdl(model,init_cond,input_range,cp_array,results{iter}.run(1).bestSample,time,staliro_opt);
                        LT=LT';
                    end
                    locHis=[locHis LT];
                else
                   sh=size(history{iter}.samples);
                   for i1=1:sh(1)
                       LT=strlCov_locationHistory{i1};
                       sLT = [LT(1); LT(1:end-1)];
                       pathLoc{1,i1} = [LT(1); LT(LT-sLT ~= 0)];
                       locHis=[locHis pathLoc{1,i1}'];
                   end
                end 

                 s=size(locHis);
                 if(s(1)~=1)
                      error('STRUCTURAL_COVERAGE: location trace should be a row vector')
                 end
                 visited=zeros(1,locationNumbers);
                 for j=1:locationNumbers
                     for k=1:s(2)
                        if locHis(1,k)==j
                             visited(1,j)=1;
                             totalNumberOfVisits(1,j)=totalNumberOfVisits(1,j)+1;
                        end
                     end
                 end
                 for j=1:locationNumbers
                     if  visited(1,j)==1
                          numOfIterationsWithVisitLoc(1,j)=numOfIterationsWithVisitLoc(1,j)+1;
                     end
                 end
            end
        end
        s=size(locHis);
        numVisitLoc=s(2);
        mx=max(numOfIterationsWithVisitLoc);
        numOfIterationsWithVisitLoc;
        precentageOfLocVisitPerIteration=100*numOfIterationsWithVisitLoc/mx;
        totalNumberOfVisits;

        numOfUnVisited=0;
        for i=1:locationNumbers
            if(visited(1,i)==1)
            else
                numOfUnVisited=numOfUnVisited+1;
            end
        end
        disp('numOfUnVisited');
        disp(numOfUnVisited);
        if strcmp(staliro_opt.StrlCov_params.locSearch, 'random')  || strcmp(staliro_opt.StrlCov_params.locSearch, 'specific') 
            if strcmp(staliro_opt.StrlCov_params.locSearch, 'random')    
                rng('shuffle');
                if numOfUnVisited>0
                    locPos=randi([1 numOfUnVisited],1,staliro_opt.StrlCov_params.numOfParallel);
                end
            end
            s=size(visited);
            j=0;
            if strcmp(staliro_opt.StrlCov_params.locSearch, 'random') && numOfUnVisited>0
                for  i=1:s(2)
                   if visited(1,i)==0
                        j=j+1;
                        if locPos==j
                             locID=i;
                        end
                   end
                end
             else
                if strcmp(staliro_opt.StrlCov_params.locSearch, 'specific')
                    locID=staliro_opt.StrlCov_params.specificLoc(iter,:);
                else
                    locID=randi([1 locationNumbers],1,1);
                end    
            end
             locID;
             nLoc_loc_pred=iter;%%%
             preds(maxPredID+iter).str=['locPred',num2str(nLoc_loc_pred)];
             preds(maxPredID+iter).A = [];
             preds(maxPredID+iter).b = [];
             preds(maxPredID+iter).loc =locID;
             disp(sprintf('Location predicate is %s and location number is %d',preds(maxPredID+iter).str,preds(maxPredID+iter).loc));
             new_phi_ID=iter;
             new_phi{iter}=['(' , phi , ')' , '\/!<>_[',num2str(staliro_opt.StrlCov_params.startUpTime),',inf)' , preds(maxPredID+iter).str];
             disp(sprintf('new phi is %s',new_phi{iter}));
             for i=1:maxPredID
                 preds(i).loc=[];
             end
        else
             disp('All the locations has been visited');
             return;
        end
        if strcmp(staliro_opt.StrlCov_params.locSearch, 'random')
            if iter==1
                numupdates=1;
                listOfCheckedLocations=locID;
            else
                numupdates=numupdates+1;
                listOfCheckedLocations=[listOfCheckedLocations;locID];
            end
        end
        seenList=[];
        unseenList=[];
        for i0=1:numupdates
            for jj=1:numVisitLoc
                found=0;
                if ~isempty( find( listOfCheckedLocations(i0,:)==locHis(jj) ) )
                   found=1;
                end
                if found==1
                    break
                end
            end
            if found==1
                seenList=[seenList; listOfCheckedLocations(i0,:)];
            else
                unseenList=[unseenList; listOfCheckedLocations(i0,:)];
            end
        end
        
        
        staliro_opt.runs=1;
        phi2=new_phi{iter};
        [results{iter+1}, history{iter+1} ]=  staliro(model,init_cond,input_range,cp_array,phi2,preds,time,staliro_opt);
    end
    
    falsified=[falsified;results{staliro_opt.StrlCov_params.nLocUpdate+1}.run(1).falsified];
    
    if  staliro_opt.StrlCov_params.chooseBestSample==1
       if staliro_opt.black_box==0
           XPoint = results{staliro_opt.StrlCov_params.nLocUpdate+1}.run(1).bestSample(:,1);
           inputModel = model;
           if length(inputModel.init.loc)>1
             for cloc = 1:length(inputModel.init.loc)
                l0 = cloc;
                actGuards = inputModel.adjList{cloc};
                noag = length(actGuards);
                for jLoc = 1:noag
                       notbreak = 0;
                       nloc = actGuards(jLoc);
                       if staliro_opt.hasim_params(1) == 1
                           if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b,'<')
                                notbreak = 1;
                                break
                           end
                       else
                           if isPointInSet(XPoint,inputModel.guards(cloc,nloc).A,inputModel.guards(cloc,nloc).b)
                               notbreak = 1;
                               break
                           end
                       end
                 end
                 if ~notbreak
                      break
                 end
             end
            else
               l0 = inputModel.init.loc(1);
            end
            h0 = [l0 0 XPoint'];
            [ hh , LT ]= hasimulator(model,h0,time,staliro_opt.ode_solver,staliro_opt.hasim_params);
       else
           [T1,XT1,YT1,IT1,LT,CLG1,GRD1] =SimBlackBoxMdl(model,init_cond,input_range,cp_array,results{staliro_opt.StrlCov_params.nLocUpdate+1}.run(1).bestSample,time,staliro_opt);
           LT=LT';
       end
       locHis=[locHis LT];
    else
       sh=size(history{staliro_opt.StrlCov_params.nLocUpdate+1}.samples);
       for i1=1:sh(1)
          LT=strlCov_locationHistory{i1};
          sLT = [LT(1); LT(1:end-1)];
          pathLoc{1,i1} = [LT(1); LT(LT-sLT ~= 0)];
          locHis=[locHis pathLoc{1,i1}'];
       end
    end 

    s=size(locHis);
    numVisitLoc=s(2);  
    
    if iscell(listOfCheckedLocations)
        seenList=cell(0);
        unseenList=cell(0);
    else
        seenList=[];
        unseenList=[];
    end
    for i0=1:numupdates
        for jj=1:numVisitLoc
           found=0;
           if ~isempty( find( listOfCheckedLocations(i0,:)==locHis(jj) ) )
               found=1;
           end
           if found==1
               break
            end
        end
        if found==1
            seenList=[seenList; listOfCheckedLocations(i0,:)];
        else
            unseenList=[unseenList; listOfCheckedLocations(i0,:)];
        end
    end

    
    
%     falsified=[falsified; results(staliro_opt.StrlCov_params.nLocUpdate+1).run(1).falsified];
elseif  staliro_opt.StrlCov_params.multiHAs==1
    pathLoc=cell(staliro_opt.runs,staliro_opt.optim_params.n_tests);
    for iter=1:staliro_opt.StrlCov_params.nLocUpdate
        disp('Iteration number is');
        disp(iter); 
        falsified=[falsified;results{iter}.run(1).falsified];
        if results{iter}.run(1).falsified
             disp('SPECIFICATION IS FALSIFIED');
             return;
        end
        if  staliro_opt.StrlCov_params.chooseBestSample==1
            [locHis,pathLoc{1,1}, numVisitLoc]=updateLocationHistory(model,init_cond,input_range,cp_array,results{iter}.run(1).bestSample,time,staliro_opt,locHis,numVisitLoc);
        else
            sh=size(history{iter}.samples);
            for i1=1:sh(1)
                [locHis,pathLoc{1,i1}, numVisitLoc]=globalLocationHistory(i1,locHis,numVisitLoc);
            end
        end
        s=size(locHis);
        
        if(numVisitLoc~=s(1))
            disp('Error on location history');
            return;
        end
        if iter==1
            state_frequency=cell(1,nHA);
            state_samples=cell(1,nHA);
            for ii=1:nHA
                state_frequency{ii}=zeros(1,staliro_opt.StrlCov_params.numOfMultiHAs(ii));
                state_samples{ii}=zeros(1,staliro_opt.StrlCov_params.numOfMultiHAs(ii));
            end
            sz=size(pathLoc);
            assignin('base','pathLoc',pathLoc);
            for i0=1:sz(1)
                for i1=1:sz(2)
                    sh=size(pathLoc{i0,i1});
                    for ii=1:sh(2)
                        LT=pathLoc{i0,i1}(:,ii);
                        assignin('base','LT',LT);
                        ss=size(LT);
                        for jj=1:ss(1)
                             state_samples{ii}(LT(jj))=state_samples{ii}(LT(jj))+1;
                        end
                        sLT = [LT(1); LT(1:end-1)];
                        stateHis = [LT(1); LT(LT-sLT ~= 0)];
                        assignin('base','stateHis',stateHis);
                        ss=size(stateHis);
                        for jj=1:ss(1)
                             state_frequency{ii}(stateHis(jj))=state_frequency{ii}(stateHis(jj))+1;
                        end
                    end
                end       
            end
            assignin('base','state_frequency',state_frequency);
        else
%             robs=[robs; bestrob];
%             falsified=[falsified; results(iter).run(1).falsified];
            sz=size(pathLoc);
            assignin('base','pathLoc',pathLoc);
            for i0=1:sz(1)
                for i1=1:sz(2)
                    sh=size(pathLoc{i0,i1});
                    for ii=1:sh(2)
                        LT=pathLoc{i0,i1}(:,ii);
                        assignin('base','LT',LT);
                        ss=size(LT);
                        for jj=1:ss(1)
                             state_samples{ii}(LT(jj))=state_samples{ii}(LT(jj))+1;
                        end
                        sLT = [LT(1); LT(1:end-1)];
                        stateHis = [LT(1); LT(LT-sLT ~= 0)];
                        assignin('base','stateHis',stateHis);
                        ss=size(stateHis);
                        for jj=1:ss(1)
                             state_frequency{ii}(stateHis(jj))=state_frequency{ii}(stateHis(jj))+1;
                        end
                    end
                end       
            end
            assignin('base','state_frequency',state_frequency);
        end

        disp('Location History');
        disp(locHis);              
        s=size(locHis);
        if   strcmp(staliro_opt.StrlCov_params.locSearch, 'random')
%             if max_possible_locs<=s(1) && strcmp(staliro_opt.StrlCov_params.locationEncoding,'combinatorial')
%                 disp('All possible location combinations are checked');
%                 max_possible_locs
%                 return;
%             end 
            nextLocation=findNextLocation(staliro_opt,nHA,max_possible_locs,listOfCheckedLocations,numVisitLoc,locHis,iter,state_frequency,state_samples);
        elseif  strcmp(staliro_opt.StrlCov_params.locSearch, 'specific')
             nextLocation=staliro_opt.StrlCov_params.specificLoc(iter,:);
        end
            
        if   strcmp(staliro_opt.StrlCov_params.locSearch, 'random')
            if iter==1
                numupdates=1;
                listOfCheckedLocations=nextLocation;
            else
                 for ii=1:numupdates
                     found=0;
                     for jj=1:nHA
                         if iscell(listOfCheckedLocations)
                             if isempty(listOfCheckedLocations{ii,jj})
                                 found=found+1;                           
                             else
                                 if ~isempty( find( listOfCheckedLocations{ii,jj}==nextLocation(1,jj) ) )
                                     found=found+1;                           
                                 end
                             end
                         else
                             if listOfCheckedLocations(ii,jj)==nextLocation(1,jj)
                                 found=found+1;
                             end
                         end
                     end
                     if found==nHA
                         disp('The location predicate' );
                         nextLocation;
                         disp('is already tested with structural coverage');
                         return;
                     end    
                 end
                numupdates=numupdates+1;
                listOfCheckedLocations=[listOfCheckedLocations;nextLocation];
            end
        end
        if iscell(listOfCheckedLocations)
            seenList=cell(0);
            unseenList=cell(0);
        else
            seenList=[];
            unseenList=[];
        end
        for ii=1:numupdates
            for jj=1:numVisitLoc
                found=0;
                for kk=1:nHA
                    if iscell(listOfCheckedLocations)
                        if isempty(listOfCheckedLocations{ii,kk})
                            found=found+1;                           
                        else
                            if ~isempty( find( listOfCheckedLocations{ii,kk}==locHis(jj,kk) ) )
                                found=found+1;                           
                            end
                        end
                    else
                        if listOfCheckedLocations(ii,kk)==locHis(jj,kk)
                            found=found+1;
                        end
                    end
                end
                if found==nHA
                    break
                end
            end
            if found==nHA
                seenList=[seenList; listOfCheckedLocations(ii,:)];
            else
                unseenList=[unseenList; listOfCheckedLocations(ii,:)];
            end
        end
        
        seenList;
        
        unseenList;
        disp('next location =');
        disp(nextLocation);              
        j=maxPredID+iter;
        disp('Location Predicate:');
        preds(j).str=['staliroStrCovPred',int2str(iter)];
        preds(j).A = [];
        preds(j).b = [];
        if  iscell(nextLocation)
            preds(j).loc=nextLocation;
        else
            preds(j).loc =cell(1,nHA);
            for ii=1:nHA
                preds(j).loc{ii}=[preds(j).loc{ii},nextLocation(ii)];

            end
        end
        disp(preds(j));
        for jj=1:maxPredID
            preds(jj).loc=cell(1,nHA);
            for ii=1:nHA
                  preds(jj).loc{ii}=[];
            end
        end
        phi2 = ['(' , phi , ')' , '\/!<>_[',num2str(staliro_opt.StrlCov_params.startUpTime),',inf)',preds(j).str];
        disp(phi2);
        staliro_opt.runs=1;
        new_phi{iter}=phi2;
        

            
        [results{iter+1} ,history{iter+1}]= staliro(model,init_cond,input_range,cp_array,phi2,preds,time,staliro_opt);

    end
    
    falsified=[falsified;results{staliro_opt.StrlCov_params.nLocUpdate+1}.run(1).falsified];

    if  staliro_opt.StrlCov_params.chooseBestSample==1
        [locHis,pathLoc{1,1}, numVisitLoc]=updateLocationHistory(model,init_cond,input_range,cp_array,results{staliro_opt.StrlCov_params.nLocUpdate+1}.run(1).bestSample,time,staliro_opt,locHis,numVisitLoc);
    else
        sh=size(history{staliro_opt.StrlCov_params.nLocUpdate+1}.samples);
        for i1=1:sh(1)
            [locHis,pathLoc{1,i1}, numVisitLoc]=globalLocationHistory(i1,locHis,numVisitLoc);
        end
    end
    if iscell(listOfCheckedLocations)
            seenList=cell(0);
            unseenList=cell(0);
    else
        seenList=[];
        unseenList=[];
    end
    s=size(locHis);
    s;
    nHA=s(2);
    for ii=1:numupdates
        for jj=1:numVisitLoc
            found=0;
            for kk=1:nHA
                if iscell(listOfCheckedLocations)
                    if isempty(listOfCheckedLocations{ii,kk})
                        found=found+1;                           
                    else
                       if ~isempty( find( listOfCheckedLocations{ii,kk}==locHis(jj,kk) ) )
                            found=found+1;                           
                       end
                    end
                else
                    if listOfCheckedLocations(ii,kk)==locHis(jj,kk)
                        found=found+1;
                    end
                end
            end
            if found==nHA
                break
            end
        end
        if found==nHA
            seenList=[seenList; listOfCheckedLocations(ii,:)];
        else
            unseenList=[unseenList; listOfCheckedLocations(ii,:)];
        end
    end


end


 disp('Stop');

end


function  [LocationHistory,pathLoc,numVisitLoc]=updateLocationHistory(model,init_cond,input_range,cp_array,samples,time,staliro_opt,locationHis,numVisitLoc)

        locHis=locationHis;
           [T1,XT1,YT1,IT1,LT1,CLG1,GRD1] = SimBlackBoxMdl(model,init_cond,input_range,cp_array,samples,time,staliro_opt);
           assignin('base','LT1',LT1);
           
           sLT1 = [LT1(1,:); LT1(1:end-1,:)];
           sub = LT1-sLT1;
           s=size(sub);
           zrs=zeros(1,s(2));
           pathLoc = LT1(1,:);
           for i=1:s(1)
             find=0;
             if isequal(sub(i,:),zrs)==0
                  find=1;    
             end
             if find==1
                 pathLoc=[pathLoc;LT1(i,:)];
             end
           end
           s=size(pathLoc);
           if isempty(locHis)
              locHis=pathLoc(1,:);
              numVisitLoc=1;
              for ii=1:s(1)
                 found=0;
                 for jj=1:numVisitLoc
                    sub=pathLoc(ii,:)-locHis(jj,:);
                    if isequal(sub,zrs)
                        found=1;
                        break;
                    end
                 end
                 if found==0
                    numVisitLoc=numVisitLoc+1;
                    locHis=[locHis;pathLoc(ii,:) ];
                 end
              end
           else    
              for ii=1:s(1)
                 found=0;
                 for jj=1:numVisitLoc
                    sub=pathLoc(ii,:)-locHis(jj,:);
                    if isequal(sub,zrs)
                        found=1;
                        break;
                    end
                 end
                 if found==0
                    numVisitLoc=numVisitLoc+1;
                    locHis=[locHis;pathLoc(ii,:) ];
                 end

              end    
           end
           LocationHistory=locHis;
end

function  [LocationHistory,pathLoc,numVisitLoc]=globalLocationHistory(sampleID,locationHis,numVisitLoc)
global strlCov_locationHistory;

        locHis=locationHis;
           LT1= strlCov_locationHistory{sampleID};
           sLT1 = [LT1(1,:); LT1(1:end-1,:)];
           sub = LT1-sLT1;
           s=size(sub);
           zrs=zeros(1,s(2));
           pathLoc = LT1(1,:);
           for i=1:s(1)
             find=0;
             if isequal(sub(i,:),zrs)==0
                  find=1;    
             end
             if find==1
                 pathLoc=[pathLoc;LT1(i,:)];
             end
           end
           s=size(pathLoc);
           if isempty(locHis)
              locHis=pathLoc(1,:);
              numVisitLoc=1;
              for ii=1:s(1)
                 found=0;
                 for jj=1:numVisitLoc
                    sub=pathLoc(ii,:)-locHis(jj,:);
                    if isequal(sub,zrs)
                        found=1;
                        break;
                    end
                 end
                 if found==0
                    numVisitLoc=numVisitLoc+1;
                    locHis=[locHis;pathLoc(ii,:) ];
                 end
              end
           else    
              for ii=1:s(1)
                 found=0;
                 for jj=1:numVisitLoc
                    sub=pathLoc(ii,:)-locHis(jj,:);
                    if isequal(sub,zrs)
                        found=1;
                        break;
                    end
                 end
                 if found==0
                    numVisitLoc=numVisitLoc+1;
                    locHis=[locHis;pathLoc(ii,:) ];
                 end

              end    
           end
           LocationHistory=locHis;
end

function  [r]=findNextLocation(staliro_opt,nHA,max_possible_locs,listOfCheckedLocations,numVisitLoc,locHis,i,state_frequency,state_samples)
% global  stateCodes;
% global  stateMinVisits;
% global  stateMinTotalVisits;
% global  stateMinChecked;
    r=zeros(1,nHA);
    if  strcmp(staliro_opt.StrlCov_params.locationEncoding,'combinatorial')
        for ii=1:nHA;
             r(ii)=randi(staliro_opt.StrlCov_params.numOfMultiHAs(ii),1,1);
        end
        % CHECK WHETEHR THE RANDOM VALUE IS IN THE LIST OF CHECKED LOCATIONS 
         zrs=zeros(1,nHA);
         % Choose the random value that is not in listOfCheckedLocations or locHis
         tempHis=[locHis;listOfCheckedLocations];
         ths=size(tempHis);
            if max_possible_locs<=ths(1) 
                disp('All possible location combinations are checked');
                max_possible_locs
                return;
            end 

             found=1;
             while found==1
                 found=0;
                 for jj=1:ths(1)
                    sub=r(1,:)-tempHis(jj,:);
%                     sub
                    if isequal(sub,zrs)
                        found=1;
                        break;
                    end
                 end
                 if found==1
                    for ii=1:nHA;
                        r(ii)=randi(staliro_opt.StrlCov_params.numOfMultiHAs(ii),1,1);
                    end
                 end
             end
    else
       if  strcmp(staliro_opt.StrlCov_params.locationEncoding ,'independent')
           for ii=1:nHA
               s=size(state_frequency{ii});
               disp(sprintf('\nHybrid Automata %d ->\n',ii));
               for jj=1:s(2)
                   disp(sprintf(' Location %d has been visited %d times and %d samples\n',jj,state_frequency{ii}(jj),state_samples{ii}(jj)));
               end
           end
           if  strcmp(staliro_opt.StrlCov_params.coverageAlgorithm , 'brute_force')
               for ii=1:nHA
                   [m,i]=min(state_frequency{ii});
                   disp(sprintf(' Minimum state is %d with frequency of %d is chosen',i,state_frequency{ii}(i)))
                   r(1,ii)=i;
               end
           end
       end
    end
end

