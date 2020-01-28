% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function isOk = iscellofstringconst(mCMat, isDiscrete)
    if nargin < 2
        isDiscrete = false;
    end
    %
    if isDiscrete
        k = sym('k');
    else
        t = sym('t');
    end
    %
    mSMat = cellfun(@eval, mCMat, 'UniformOutput', false);
    isConstMat = cellfun(@(x) ~isa(x, 'sym'), mSMat);
    isOk = all(isConstMat(:));
end