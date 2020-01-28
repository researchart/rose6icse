% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function SInput = patch_013_disable_uncertainty_regime_by_default(~,SInput)
SInput.ellipsoidalApxProps.internalApx.schemas.uncert.isEnabled=false;