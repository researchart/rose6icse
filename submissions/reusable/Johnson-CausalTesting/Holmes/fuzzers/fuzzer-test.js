var fuzzer = require('fuzzer');
//var bigInt = require('big-integer')


 for (i=0; i < 200; i++){

	fuzzer.seed(i);


	// fuzzed value = index 2
	process.argv.forEach(function (val, index, array) {
		var generator = fuzzer.mutate.string(val);
		if (index == 2) {
  			console.log(generator);			
		}

	});

	
 }

