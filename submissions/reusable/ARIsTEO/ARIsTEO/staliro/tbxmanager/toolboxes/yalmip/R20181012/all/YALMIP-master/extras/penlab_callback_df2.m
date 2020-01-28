% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [H,model] = penlab_callback_df2(x,model)

global latest_x_f
global latest_df

H = speye(2);