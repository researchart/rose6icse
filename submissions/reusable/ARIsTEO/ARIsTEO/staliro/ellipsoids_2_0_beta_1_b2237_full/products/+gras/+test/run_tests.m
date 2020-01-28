% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function results=run_tests(varargin)
resList{1}=gras.ellapx.test.run_tests(varargin{:});
resList{2}=gras.la.test.run_tests();
resList{3}=gras.geom.test.run_tests();
resList{4}=gras.gen.test.run_tests();
resList{5}=gras.interp.test.run_tests();
resList{6}=gras.ode.test.run_tests();
resList{7}=gras.mat.test.run_tests();
results=[resList{:}];