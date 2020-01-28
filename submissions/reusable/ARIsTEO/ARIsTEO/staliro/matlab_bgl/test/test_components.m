% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function test_components

%%
msgid = 'matlab_bgl:test_components';

%% biconnected_components
load('../graphs/tarjan-biconn.mat');
[a C] = biconnected_components(A);