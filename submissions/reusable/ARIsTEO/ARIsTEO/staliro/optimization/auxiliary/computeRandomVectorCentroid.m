% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [ centroid ] = computeRandomVectorCentroid( biasWeight, curSample, distribution, P )
%COMPUTERANDOMVECTORCENTROID Returns the vector to be used as a bias in
%generating random unit vector.
%INPUTS:
%   biasWeight  :   Weight for applying a bias. 0 means no bias will be
%                   applied.
%   curSample   :   Current sample from the sample space.
%   distribution:   (optional) 'normal'/'uniform'. Default is 'normal'
%                   For normal distribution center for the distribution is
%                   0. For uniform distribution, center is equal to the
%                   center of the sample space.
%   P           :   (optional) Polyhedron sample space. Default: unit Polyhedron.
%
% (C) 2015, C. Erkan Tuncali, Arizona State University

if nargin > 0
    % --- Validate inputs ---
    assert(abs(biasWeight) <= 1, ' computeRandomVectorCentroid : Magnitude of biasWeight must be less than or equal to 1');
    
    if nargin > 1
        [nRows, nColumns] = size(curSample);
        assert(nColumns == 1, ' computeRandomVectorCentroid : curSample must be n x 1');
%        assert(~any(lt(curSample, zeros(nRows,1)) | gt(curSample, ones(nRows,1))), ...
%            ' computeRandomVectorCentroid : every sample in curSample must be in range [0,1]');
    else
        error(' computeRandomVectorCentroid : curSample must be given');
    end
    
    if nargin > 2
        assert(any(strcmpi(distribution, {'normal', 'uniform'})), ' computeRandomVectorCentroid : distribution must be normal or uniform!');
    else
        distribution = 'normal';
    end
    if nargin < 4
        lb = zeros(nRows, 1);
        ub = ones(nRows, 1);
        P = Polyhedron('lb', lb, 'ub', ub);
    end
    if nargin > 4
        centerP = mean(P.V)';
    else
        centerP = P.chebyCenter.x;
    end
    [nCenter, ~] = size(centerP);
    assert(nRows == nCenter, ' computeRandomVectorCentroid : num of dimensions of polyhedron must be equal to num of samples in curSample');
    
    % --- Find the vector from the center to the current sample ---
    v = curSample - centerP;
    
    % --- Apply the biasWeight ---
    v = v * biasWeight;
    
    % --- Get the coordinates of the centroid ---
    if strcmpi(distribution, 'normal')
        centroid = v;
    else % uniform
        centroid = v + centerP;
    end
else
    centroid = 0;
end

end

