% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function SInput = patch_014_internal_external_apx_params(~,SInput)
SInput.ellipsoidalApxProps.extIntApx.isEnabled=false;
SInput.ellipsoidalApxProps.extIntApx.schemas.uncert.isEnabled=false;
SInput.ellipsoidalApxProps.extIntApx.schemas.uncert.props.selectionMethodForSMatrix='volume';