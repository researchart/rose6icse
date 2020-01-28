% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function df = ipoptgp_callback_df(x,model)

global latest_x_f
global latest_df

x = x(:);
if isequal(x,latest_x_f)
    df = latest_df;
else
    [f,df] = fmincon_fungp(x,model);
end


