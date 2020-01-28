% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [dG,model] = penlab_callback_matrixdG(x,k,i,model)

global latest_x_g
global latest_G
global latest_g
x = x(:);

vecG = model.vecF{k}(:,i+1);
dG = reshape(vecG,model.K.s(k),model.K.s(k));
