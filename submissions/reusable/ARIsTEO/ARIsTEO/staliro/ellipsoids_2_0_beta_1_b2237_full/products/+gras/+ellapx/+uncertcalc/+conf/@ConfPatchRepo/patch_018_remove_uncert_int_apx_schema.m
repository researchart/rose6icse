% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function SInput = patch_018_remove_uncert_int_apx_schema(~,SInput)
if isfield(SInput.ellipsoidalApxProps.internalApx.schemas,'uncert')
    SInput.ellipsoidalApxProps.internalApx.schemas=rmfield(...
        SInput.ellipsoidalApxProps.internalApx.schemas,'uncert');
end