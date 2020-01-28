% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% newSample - returns a new sample for monteCarloTaliro

% (C) 2010, Sriram Sankaranarayanan, University of Colorado
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2013, Bardh Hoxha, Arizona State University
% (C) 2015, C. Erkan Tuncali, Arizona State University

function newSample = getNewSampleConstrained(varargin)

global staliro_opt;
global staliro_SimulationTime;
global temp_ControlPoints;
global staliro_dimX;
global staliro_ParameterIndex;

if ~isempty(temp_ControlPoints)
    %the dimensions of total control points array
    m = temp_ControlPoints(end);
    
    %the dimensions of the first control points array
    k = temp_ControlPoints(1);
else
    m = 0;
    k = 0;
end

%the dimensions of the initial conditions
n = staliro_dimX;

%p > 0 for parameter estimation, 0 otherwise
p = size(staliro_ParameterIndex,2);

%% Read Inputs
if nargin == 0
    error(' getNewSampleConstrained : Not enough inputs!');
end

if nargin == 1
    isFirstSample = 1;
    inpRangeOrig = varargin{1};
    dispL = 0;
    epsilon = 0.0001;
else
    % In this case 1st input becomes curSampleOrig and 2nd input
    % becomes inpRangeOrig. This is done in order to maintain
    % backward compatibility with earlier versions of s-TaLiRo.
    isFirstSample = 0;
    curSampleOrig = varargin{1};
    inpRangeOrig = varargin{2};
    if nargin > 2
        dispL = varargin{3};
    else
        dispL = 1;
    end
    if nargin > 3
        epsilon = varargin{4};
    else
        epsilon = 0.0001;
    end
end

%%
% GF: Temporary fix
if (staliro_opt.varying_cp_times==2) && nargin>1
    m = length(curSampleOrig)-n;
end
    

%% Get Sample
if isa(inpRangeOrig, 'Polyhedron') %Input space is given as a polyhedron.
    P = inpRangeOrig;
    
    % Check Polyhedron properties
    if ~P.isBounded
        error(' getNewSampleConstrained : input polyhedron is not bounded !');
    end
    
    %if dispL <= staliro_opt.optim_params.dispStart
    %    dispLForSampler = 0;
    %else
        dispLForSampler = abs((dispL - staliro_opt.optim_params.dispStart) / staliro_opt.optim_params.maxDisp);
    %end
    % Sampling will be retried until input constraints are satisfied
    % Normally, sample is taken so that it satisfies the constraints so the
    % inputConstraintsSatisfied check is defensive code. (against rounding
    % errors etc.)
    inputConstraintsSatisfied = 0;
    while inputConstraintsSatisfied == 0
        if isFirstSample == 1
            % when only one input with the ranges is provided to the function return a random uniform valid vector.
            limits = getLimitsOfPolyhedron(P);
            midPoint = mean(P.V)';
            centroid = computeRandomVectorCentroid( 0, midPoint, 'uniform', P );
            randomUnitVector = getRandomUnitVector( length(centroid), 'uniform', centroid, limits );
            
            shootRange = P.shoot(randomUnitVector, centroid);
            randomLength = shootRange.alpha * rand(1,1);
            newSample = centroid + (randomLength*randomUnitVector);

            if P.contains(newSample)
                inputConstraintsSatisfied = 1;
                % in the case we have to generate control point times for the initial
                % sample generation, we return evenly distributed control points
                if staliro_opt.varying_cp_times == 1
                    % get equidistant time distribution for control points
                    % and insert between control points and parameters
                    newSample = [newSample(1:m+n); (0 : staliro_SimulationTime/(k-1) : staliro_SimulationTime)'; newSample(m+n+1:end)];
                end
            end
        else
            curSample = [curSampleOrig(1:m+n);curSampleOrig(end+1-p:end)]; %without time 
            limits = getLimitsOfPolyhedron(P);
            centroid = computeRandomVectorCentroid( dispLForSampler, curSample, 'uniform', P );
            randomUnitVector = getRandomUnitVector( length(centroid), 'uniform', centroid, limits );

            %search for specific parameter direction
            if strcmp(staliro_opt.optimization_solver,'SDA_Taliro')
                %update parameter related part of the random vector to [1,..,1]
                %direction without affecting the random vector in other
                %directions.
                parVector = randomUnitVector(m+n+1:m+n+p);
                newParVector = ones(size(staliro_ParameterIndex,2), 1)';
                if strcmpi(staliro_opt.optimization, 'min') %negative
                    newParVector = -1 * newParVector;
                end
                newParVector = newParVector / norm(newParVector); %unit size
                newParVector = newParVector * norm(parVector); %size made equal to size of old par vector.
                randomUnitVector(m+n+1:m+n+p) = newParVector; %put the parameter vector back random vector
                randomUnitVector = randomUnitVector / norm(randomUnitVector); %to correct rounding errors
            end

            shootRange = P.shoot(randomUnitVector, curSample);
            posDirRange = shootRange.alpha;
            shootRange = P.shoot(-randomUnitVector, curSample);
            negDirRange = shootRange.alpha;
            totRange = posDirRange + negDirRange;
            
            % When acceptance is too high or too low, give more possibility
            % to the direction towards the center of polyhedron.
            posNegDir = rand(1,1) - 0.5 + dispLForSampler * (0.5 - negDirRange/totRange);
            if posNegDir < 0
                randomUnitVector = -randomUnitVector;
            end
                
            %randomLength = (posDirRange - (posDirRange + negDirRange) * rand(1,1)) * dispL;
            %randomLength = (posDirRange + negDirRange) * rand(1,1);
            %randomLength = randomLength - negDirRange;
            %newSample = curSample + (randomLength.*randomUnitVector);            
            
            
            shootRange = P.shoot(randomUnitVector, curSample);
            randomLength = dispL * shootRange.alpha * rand(1,1);
            newSample = curSample + (randomLength*randomUnitVector);
            
            if P.contains(newSample)
                inputConstraintsSatisfied = 1;
                if staliro_opt.varying_cp_times == 1
                    %insert samples for time
                    curTimeSample = curSampleOrig(m+n+1:end-p);

                    %deals with the distribution of the control times
                    %forst and last time point will not chage
                    curSampleTimeTemp = curTimeSample(2:end-1);

                    rUnitVectorForTime = randn(length(curSampleTimeTemp), 1);
                    rUnitVectorForTime = rUnitVectorForTime/norm(rUnitVectorForTime);

                    %get the beta and alpha endpoints for the hit and run algorithm
                    beta = findTimeEndPoints(curSampleTimeTemp, rUnitVectorForTime, 'beta', epsilon);
                    alpha = findTimeEndPoints(curSampleTimeTemp, rUnitVectorForTime, 'alpha', epsilon);

                    %random number for the time distribution
                    weightVector = mcGenerateRandomNumber(alpha, beta, dispL);

                    % !!!
                    % Time samples have fixed range from start time to end time of
                    % simulation !!!
                    timeRange = [0, staliro_SimulationTime];

                    % Do not change first and last values for time. Update
                    % other values.
                    newTimeSample = curTimeSample;
                    newTimeSample(2:end-1) = (curSampleTimeTemp + (weightVector.*rUnitVectorForTime)) ...
                        .* (timeRange(:,2)-timeRange(:,1)) + timeRange(:,1);

                    % insert the time samples between control points and parameters
                    newSample = [newSample(1:m+n); newTimeSample; newSample(m+n+1:end)];
                end
            end
        end
    end
else % Range of sample space is given as lower and upper bounds
    if isFirstSample == 1
        % in the case we have to generate control point times for the initial
        % sample generation, we return evenly distributed control points
        if staliro_opt.varying_cp_times == 1
            %get random vector for control points
            newSample(1:m+n,1) = (inpRangeOrig(1:m+n,1)-inpRangeOrig(1:m+n,2)).*rand(m+n,1)+inpRangeOrig(1:m+n,2);
            
            %get equidistant time distribution for control points
            newSample(m+n+1:m+n+k,1) = (0:staliro_SimulationTime/(k-1):staliro_SimulationTime)';
            
            %handle case for parameter estimation
            if staliro_opt.parameterEstimation == 1
                newSample(end+1:end+p) = (inpRangeOrig(m+n+1:end,1)-inpRangeOrig(m+n+1:end,2)).*rand(1,1)+inpRangeOrig(m+n+1:end,2);
            end
        else
            newSample = (inpRangeOrig(:,1)-inpRangeOrig(:,2)).*rand(m+n+p,1)+inpRangeOrig(:,2);
        end
    else
        if staliro_opt.varying_cp_times == 1
            %%This section deals with the control point values
            
            %get indices of inputs for the control point values(m+n) whose range is nonzero
            Ix_nonzero =  find(inpRangeOrig(1:size(curSampleOrig(1:m+n),1),1) - inpRangeOrig(1:size(curSampleOrig(1:m+n),1),2));
            %scale the curSampleOrig to be between 0 and 1
            curSample = (curSampleOrig(:)-inpRangeOrig(:,1))./(inpRangeOrig(:,2)-inpRangeOrig(:,1));
            %get indices of inputs whose range is 0. The value for these inputs
            %will remain the same
            Ix_Nan = find(isnan(curSample));
            curSample(Ix_Nan) = 1;
            
            %First get a random unit vector
            %Second find the max/min offsets along this vector
            %choose a point
            rUnitVector = randn(m+n+k+p, 1);
            
            %search or specific parameter direction
            if strcmp(staliro_opt.optimization_solver,'SDA_Taliro')
                direction = ones(size(staliro_ParameterIndex,2),1)';
                
                if strcmpi(staliro_opt.optimization, 'min')
                    direction = -1 .* direction;
                end
                
                direction = direction/sum(direction);
                rUnitVector(m+n+k+1:m+n+k+p) = direction';
            end
            
            rUnitVector = rUnitVector/norm(rUnitVector);
            
            %set random vector values for begin time and end time to 0
            rUnitVector(m+n+1) = 0;
            rUnitVector(end-p) = 0;
            inpRange = repmat([0 1], m+n, 1);
            
            %get values of the control points
            curSampleState = curSample(Ix_nonzero);
            
            lam1=(inpRange(Ix_nonzero,1)-curSampleState)./rUnitVector(Ix_nonzero);
            lam2=(inpRange(Ix_nonzero,2)-curSampleState)./rUnitVector(Ix_nonzero);
            
            if staliro_opt.parameterEstimation ==1
                lam1(end+1) = (0 - curSample(end))./rUnitVector(end);
                lam2(end+1) = (1 - curSample(end))./rUnitVector(end);
            end
            
            for i=1:size(lam1,1)
                if (lam1(i,1)> lam2(i,1))
                    tmp=lam2(i,1);
                    lam2(i,1)=lam1(i,1);
                    lam1(i,1)=tmp;
                end
                assert(lam1(i,1) <= 0);
                assert(lam2(i,1) >= 0);
            end
            
            % Handle case where inpRange restricts some dimension to one point
            % In this case lam1 and lam2 will each contain a 0 at that dimension, forcing r to be
            % 0, and the newSample to equal the curSample. So we ignore these
            % restricted dimensions from the range computation
            l1=max(lam1(:));
            l2=min(lam2(:));
            
            %% This section deals with the distribution of the control times
            curSampleTime = curSample(m+n+2:m+n+k-1);
            
            %get the beta and alpha endpoints for the hit and run algorithm
            beta = findTimeEndPoints(curSampleTime, rUnitVector, 'beta', epsilon);
            alpha = findTimeEndPoints(curSampleTime, rUnitVector, 'alpha', epsilon);
            %% This section generates the newsample with the endpoints collected
            
            %generate one random number for control pointa values and one
            %random number for the control point time distribution
            r=mcGenerateRandomNumber([l1;alpha],[l2;beta],dispL);
            
            %set weight vector with random numbers generated
            weightVector = zeros(m+n+k+p,1);
            weightVector(1:m+n,1) = r(1,1);
            weightVector(m+n+1:m+n+k,1) = r(2,1);
            
            % Transform new point back to original search hypercube
            if staliro_opt.parameterEstimation ==1
                weightVector(end+1,1) = r(1,1);
            end
            newSample = (curSample+weightVector.*rUnitVector).*(inpRangeOrig(:,2)-inpRangeOrig(:,1))+inpRangeOrig(:,1);
            
        else
            %% This is the case where the control points are distributed equally in time
            Ix_nonzero =  find(inpRangeOrig(:,1) - inpRangeOrig(:,2));
            inpRange = ones(m+n+p,2);
            inpRange(Ix_nonzero,1) = 0;
            curSample = ones(m+n+p,1);
            curSample(Ix_nonzero) = (curSampleOrig(Ix_nonzero)-inpRangeOrig(Ix_nonzero,1))./(inpRangeOrig(Ix_nonzero,2)-inpRangeOrig(Ix_nonzero,1));
            %First get a random unit vector
            %Second find the max/min offsets along this vector
            %choose a point
            rUnitVector = randn(m+n+p,1);
            
            %search for specific parameter direction
            if strcmp(staliro_opt.optimization_solver,'SDA_Taliro')
                direction = ones(size(staliro_ParameterIndex,2),1)';
                
                if strcmpi(staliro_opt.optimization, 'min')
                    direction = -1 .* direction;
                end
                
                direction = direction/sum(direction);
                rUnitVector(m+n+1:m+n+p) = direction';
            end
            
            rUnitVector = rUnitVector/ norm(rUnitVector);
            lam1=(inpRange(:,1)-curSample)./rUnitVector;
            lam2=(inpRange(:,2)-curSample)./rUnitVector;
            for i=1:1:m+n+p
                if (lam1(i,1)> lam2(i,1))
                    tmp=lam2(i,1);
                    lam2(i,1)=lam1(i,1);
                    lam1(i,1)=tmp;
                end
                assert(lam1(i,1) <= eps('single'));
                assert(lam2(i,1) >= -eps('single') );
            end
            
            % Handle case where inpRange restricts some dimension to one point
            % In this case lam1 and lam2 will each contain a 0 at that dimension, forcing r to be
            % 0, and the newSample to equal the curSample. So we ignore these
            % restricted dimensions from the range computation
            l1=max(lam1(Ix_nonzero));
            l2=min(lam2(Ix_nonzero));
            
            r=mcGenerateRandomNumber(l1,l2,dispL);
            weightVector = zeros(m+n+p,1);
            weightVector(Ix_nonzero) = r;
            
            % Transform new point back to original search hypercube
            newSample = (curSample+weightVector.*rUnitVector).*(inpRangeOrig(:,2)-inpRangeOrig(:,1))+inpRangeOrig(:,1);
        end
    end
end

%% Auxiliary Functions
    function rBool = validCP(testSample)
        %this function returns 1 if the testSample is a valid time
        %distribution for control points, 0 otherwise
        if testSample == sort(testSample)
            if all((testSample>=0)==1) && all((testSample<=1)==1)
                rBool = 1;
            else
                rBool = 0;
            end
        else
            rBool = 0;
        end
    end

    function returnVal = findTimeEndPoints(curSampleTime, rUnitVector, whichEnd, epsilon)
        %this functions returns the end points for the alpha and beta of
        %the hit and run algorithm
        coefMax = 1;
        coefMin = 0;
        if isequal(whichEnd,'beta')
            currBeta = 0;
            while abs(coefMax-coefMin) > epsilon
                curr = (coefMax+coefMin)/2;
                testSample = curSampleTime + curr * rUnitVector(m+n+2:m+n+k-1);
                check = validCP(testSample);
                if check == 1
                    currBeta = curr;
                    coefMin = coefMin + (coefMax-coefMin)/2;
                else
                    coefMax = coefMax - (coefMax-coefMin)/2;
                end
            end
            %beta
            returnVal = currBeta;
            
        elseif isequal(whichEnd,'alpha')
            currAlpha = 0;
            while abs(coefMax-coefMin) > epsilon
                curr = (coefMax+coefMin)/2;
                testSample = curSampleTime - curr * rUnitVector(m+n+2:m+n+k-1);
                check = validCP(testSample);
                if check == 1
                    currAlpha = curr;
                    coefMin = coefMin + (coefMax-coefMin)/2;
                else
                    coefMax = coefMax - (coefMax-coefMin)/2;
                end
            end
            %alpha
            returnVal = -currAlpha;
        end
    end
end