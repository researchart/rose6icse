% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function SInput = patch_015_internal_external_apx_addparams(~,SInput)
SInput.ellipsoidalApxProps.extIntApx.schemas.uncert.props.minQSqrtMatEig=0.1;