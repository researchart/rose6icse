% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function SInput = patch_001_remove_garbage(~,SInput)
if isfield(SInput,'dim_max')
    SInput=rmfield(SInput,'dim_max');
end
if isfield(SInput,'cdim_max')
    SInput=rmfield(SInput,'cdim_max');
end
if isfield(SInput,'cdim')
    SInput=rmfield(SInput,'cdim');
end