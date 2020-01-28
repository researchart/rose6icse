% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function nDistrib = tiltBernoulliDistribution(oldDistrib,samples,lo, hi, n)

%% build an histogram by binning the samples.

discountFactor = 0.5;

delta = (hi-lo)/n;
nSamples = length(samples);
nDistrib = zeros(size(oldDistrib));
for i = 1:nSamples
    j = 1+floor( (samples(i) - lo)/delta);
    assert( j >= 1);
    assert( j <= n);
    nDistrib(1,j) = nDistrib(1,j) + 1;
end

nDistrib = nDistrib ./ nSamples;

nDistrib = discountFactor .* nDistrib  + (1 - discountFactor) .* oldDistrib;

end