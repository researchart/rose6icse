% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function results=run_tests(varargin)
resList{1}=gras.ellapx.uncertcalc.test.regr.run_tests(varargin{:});
resList{2}=gras.ellapx.uncertcalc.test.comp.run_tests(varargin{:});
results=[resList{:}];