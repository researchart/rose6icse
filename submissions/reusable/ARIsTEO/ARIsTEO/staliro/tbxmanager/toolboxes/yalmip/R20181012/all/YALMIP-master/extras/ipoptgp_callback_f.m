% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function f = ipoptgp_callback_f(x,model)

global latest_x_f
global latest_df

x = x(:);
[f,latest_df] = fmincon_fungp(x,model);
latest_x_f = x;
