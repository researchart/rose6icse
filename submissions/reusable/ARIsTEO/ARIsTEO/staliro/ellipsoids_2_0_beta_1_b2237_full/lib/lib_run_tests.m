% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function results=lib_run_tests(varargin)
resList{1}=modgen.test.run_public_tests(varargin{:});
resList{2}=mlunitext.test.run_tests(varargin{:});
resList{3}=smartdb.test.run_public_tests();
%
results=[resList{:}];