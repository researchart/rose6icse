% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function SInput = patch_019_add_reg_props(~, SInput)
SInput.regularizationProps.isEnabled = false;
SInput.regularizationProps.isJustCheck = false;
SInput.regularizationProps.regTol = 1e-5;