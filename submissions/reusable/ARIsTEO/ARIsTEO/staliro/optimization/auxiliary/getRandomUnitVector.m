% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ randomUnitVector ] = getRandomUnitVector( numOfDimensions, distribution, centroid, limits, dispL )
%GETRANDOMUNITVECTOR Returns a unit vector with a random direction.
% INPUTS:
%   numOfDimensions :   Number of dimensions of sample space
%   distribution    :   (optional) 'normal'/'uniform'. Default is 'normal'
%   centroid        :   (optional) The sampled point from the space will be accepted 
%                       as the head of the vector and centroid will be accepted as the tail of
%                       the vector. This input is used to give a bias towards a direction in
%                       the sample space. Centroid must be (numOfDimensions x 1).
%   limits          :   (optional) lower and upper bounds of the sample
%                       space in every dimension (numOfDimensions x 2). 
%                       Default: [0, 1] in every dimension.
%
% (C) 2015, C. Erkan Tuncali, Arizona State University

randomUnitVector = 0;

if nargin > 0
    
    % --- Validate inputs ---
    assert(numOfDimensions > 0, ' getRandomUnitVector : numOfDimensions must be larger than 0!');
    if nargin > 1
        assert(any(strcmpi(distribution, {'normal', 'uniform'})), ' getRandomUnitVector : distribution must be normal or uniform!');
    else
        distribution = 'normal';
    end
    if nargin > 2
        [nDimCentroid, ~] = size(centroid);
        assert(numOfDimensions == nDimCentroid, ' getRandomUnitVector : Number of centroid dimensions does not match number of sample space dimensions!');
    else
        if strcmpi(distribution, 'normal')
            centroid = zeros(numOfDimensions, 1); % Center for normal distribution
        else % uniform
            centroid = 0.5 * ones(numOfDimensions, 1); % Center of a unit polytope.
        end
    end
    if nargin > 3
        [nRowsLimits, nColLimits] = size(limits);
        assert(nRowsLimits == numOfDimensions, ' getRandomUnitVector : Dimensions of limits does not match number of sample space dimensions!');
        assert(nColLimits == 2, ' getRandomUnitVector : limits must be n x 2 (must give lb and ub)!');
    else
        limits = zeros(numOfDimensions, 2);
        limits(:, 2) = ones(numOfDimensions, 1);
    end
    
    % --- Get a random number from unit polyhedron ---
    if strcmpi(distribution, 'normal')
        r = randn(numOfDimensions, 1);
        r = r / norm(r);
    else % uniform
        r = rand(numOfDimensions, 1);
        r = r - 0.5 * ones(numOfDimensions, 1);
        r = r / norm(r); %Sampled from unit hypersphere
    end
    
    % --- Map the random number to actual space ---
    % Make sampling space an ellipsoid
    rangeLimits = range(limits, 2);
    r = r .* rangeLimits;
    %r = r + limits(:, 1);
    
    % Create the vector so that the sampled "r" will be the head and "centroid" be the tail of the random vector
    %r = r - centroid;
    
    % Normalize the vector to unit size
    randomUnitVector = r / norm(r);
end

end

