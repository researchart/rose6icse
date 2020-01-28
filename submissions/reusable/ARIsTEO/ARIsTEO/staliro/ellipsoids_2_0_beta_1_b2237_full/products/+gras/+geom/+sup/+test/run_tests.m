% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'gras.geom.sup.test.mlunit.SuiteBasic');
%
resList{1}=runner.run(suite);
results=[resList{:}];