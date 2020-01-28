% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function result = run_tests(varargin)
    runner = mlunitext.text_test_runner(1, 1);
    loader = mlunitext.test_loader;
    % 
    suiteLinSys = loader.load_tests_from_test_case(...
        'elltool.linsys.test.mlunit.LinSysTestCase',varargin{:});
    %
    suite = mlunitext.test_suite(suiteLinSys.tests);
    result = runner.run(suite);
end
