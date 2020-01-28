% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function result=run_tests()
import mlunit2.*;
import mlunit2.src.*;
import smartdb.*;
import smartdb.disp.*;
import smartdb.disp.test.*;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case('smartdb.disp.test.mlunit_test_disp');
result=runner.run(suite);
