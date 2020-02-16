[![DOI](https://zenodo.org/badge/235884734.svg)](https://zenodo.org/badge/latestdoi/235884734)

Our artifact is publicly available on Github: https://github.com/alebugariu/StringSolversTests 

The tool synthesizes input formulas in SMT-LIB 2.6 format that are satisfiable or unsatisfiable by construction, together with a model, or with the minimal unsat core, respectively. These inputs are then used for testing the implementation of 
SMT and automata-based string solvers.

 This document provides an overview of our benchmarks and details on how to use our tool to rerun our experiments. 
 All this information is also publicly available as part of our [repository](https://github.com/alebugariu/StringSolversTests/blob/master/EXPERIMENTS.md).
 
 # Our Benchmarks - Overview

The test cases that we synthesized can be found in the folder [generatedTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests). They are grouped 
by the expected status, i.e., *sat* or *unsat*. Note that we have separate folders for the random seeds 0 and 1465 (the two values used
in our experiments for running the SMT solvers), to facilitate error reporting. However, our tool is *deterministic*, so 
our generated tests are the same for both random seeds, they only differ in the option line ```(set-option :random-seed <value>)```.

### Sat formulas
The sat formulas are grouped by the category/transformation used to generate them into the following three folders:
* [operation](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_sat/seed0/operation): contains formulas generated in step 1, 
by testing each operation in isolation (see Section 2.1).
* [const](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_sat/seed0/const): contains formulas generated in step 2, 
by applying the constant assignment transformation (see Section 3.1).
* [termSyn](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_sat/seed0/termSyn): contains formulas generated in step 2, 
by applying the term synthesis transformation (see Section 3.1).

All these formulas are quantifier-free. For each sat formula, we also synthesize a possible model, written as a comment at
the end of each test file. Note that we omit the enclosing "" for String values. For example, the lines: 
```
;tmp_str1 = 
;tmp_str2 = a
``` 
from the [test file](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/examples/listing1/z3_seq/test1558798332234_replace_const_2_12.smt2) for the replace operation correspond to the model ```tmp_str1 = ""``` and ```tmp_str2 = "a"```.

### Unsat formulas
The unsat formulas are grouped by the category/transformation used to generate them into the following folders:
* [eqForm](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_unsat/seed0/eqForm): contains formulas generated in step 1, 
by testing each operation together with its equivalent formula from Table 2 (see Section 2.2).
* [unsatCore](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_unsat/seed0/unsatCore): contains formulas with larger unsat cores,
generated in step 2 by applying the variable and constant replacement transformations (see Section 3.2).
* [redundant](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_unsat/seed0/redundant): contains formulas generated in step 2, 
by applying the redundancy introduction transformation (see Section 3.2).

All the quantified formulas from these folders **do not** contain patterns (triggers) for quantifiers. The corresponding 
formulas with the patterns specified in Table 2 can be found in the folders [eqFormTriggers](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_unsat/seed0/eqFormTriggers),
[unsatCoreTriggers](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_unsat/seed0/unsatCoreTriggers) and [redundantTriggers](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests/expected_unsat/seed0/redundantTriggers), 
respectively. For each unsat formula, we also generate the minimal unsat core, written as a comment at the end of each test file. For example, the expected minimal unsat core for the replace formula from the [test file](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/examples/figure7/z3_str3/test1563370927043_replace_unsatCore_3_7_0.smt2) consists of the assertions: ```a0```, ```a1``` and ```a2```:
```
;unsat core: a0 a1 a2
```

### MT-ABC tests
The folder [abcTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/abcTests) contains a modified subset of our benchmarks, including only the features supported by MT-ABC (see Section 4.3).

# StringFuzz Benchmarks

The folder [stringFuzzTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/stringFuzzTests) contains the StringFuzz [generated benchmarks](http://stringfuzz.dmitryblotsky.com/suites/generated/) used in our evaluation (see Section 4.2), i.e., the benchmarks for which the expected result (sat/unsat) was specified. The folder also includes the [results](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/stringFuzzTests/statistics) we obtained for Z3-seq 4.7.1, Z3str3 4.7.1 and CVC4 1.6 on these benchmarks.

# Examples

The folder [examples](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/examples) contains the test cases that correspond to the examples from the listings and 
the figures of the paper. At the end of each file, we also include the actual status returned by the solver, and the model or the unsat core it produced, if available.

# Results

All the tests that passed or failed for each version of the solvers considered in our experiments (i.e., 4.7.1 and 4.8.6 for the Z3-based solvers, 1.6 and 1.7 for CVC4, and [commit](https://github.com/vlab-cs-ucsb/ABC/commit/86b00141fddd183de7b9ae5c92c240e19dda1950) for MT-ABC) can be found in the corresponding folders: [passingTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/passingTests) and [failingTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/failingTests), respectively.
The results presented in Tables 4, 6 and 7 are based on the values from the folder [statistics](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/statistics).

# Experiments - Step by Step Instructions

In the following, we describe the steps required to reproduce our experimental results:

#### 1. To generate our benchmarks:

```./run.sh -gen```

This command will generate all our 7036 benchmarks in **~1 min**, in the folder StringSolversTests/generatedTests. Note that all the tests will include ```(set-option :random-seed 0)```, as the default random seed is 0. This parameter can be changed by using the option ```-seed <value>``` when running our tool. The generated input formulas should be the same as in our experiments (see [generatedTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/generatedTests)). Note that for some tests, the names of the variables might differ, as we changed the naming algorithm since the submission. Moreover, the let expressions are automatically generated by the Z3 4.7.1 parser that we use to write the .smt files and we observed that it sometimes chooses different names for the temporary variables it introduces. 

#### 2. To test Z3-seq 4.7.1, Z3str3 4.7.1 and CVC4 1.6 on all our benchmarks, i.e., to reproduce the results from Table 4: 

```./run.sh -testSMT -prior```

This experiment will run for **~6h**, as it uses the default timeout of 15s per test case and the default value for the random seed 0 used in our evaluation. These parameters can be changed by using the options ```-seed <value> -timeout <value>``` when running our tool. All the failing tests and the corresponding actual status will be printed to the console. Moreover, all the tests that passed will be stored in the folder StringSolversTests/passingTests and all the ones that failed in the folder StringSolversTests/failingTests. At the end of the experiment, three results files will be generated for each solver, corresponding to the results for the sat formulas, unsat formulas without patterns and unsat formulas with patterns (unsat [+p] in Table 4). For example, the file StringSolversTests/statistics\<current_time\>_z3_seq_unsat_triggers.txt will contain the results for Z3-seq tested on all the unsat formulas, using patterns for the quantified ones. The numbers from the results files should be the same as those from Table 4 for CVC4 and may be slighlty different for the Z3-based solvers; as discussed in the paper, these solvers may have non-deterministic behavior. 

To further test the robustness of the solvers and to reproduce the results discussed in Section 4.1 (Subsection Other issues): ```./run.sh -testSMT -prior -seed 1465```. This experiment will also run for **~6h**. Note that for a very small number of tests (1-4), the actual status in the results file might be bigModel. This status is *not* included in Table 4. Those cases (discussed in Section 4.1, Subsection Soundness issues) occur when the models generated by the solvers contain mathematical integers larger than the bounded integers supported by our executable semantics. We manually inspected those models and as they were all valid, they are *not* reported as errors in Table 4.

#### 3. To test Z3-seq 4.8.6, Z3str3 4.8.6 and CVC4 1.7 on all the benchmarks that failed on the "prior" version (4.7.1 for Z3-seq and Z3str3 and 1.6 for CVC4), i.e., to reproduce the results from Table 6: 

```./run.sh -testSMT -latest``` 

This experiment will take **~4h**. It uses the same experimental setup and produces the output in the same format as experiment 2.

#### 4. To *partially* reproduce the results from Tables 4 and 6, by testing a specific version of *an* SMT solver only on the sat formulas, only on the unsat formulas without patterns or only on the unsat formulas with patterns: 

```./run.sh -testSolver <Z3-seq/Z3str3/CVC4> -latest/-prior -sat/-unsat [-triggers]```

For example, the command ```./run.sh -testSolver CVC4 -prior -unsat -triggers``` will test CVC4 1.6 on all the unsat formulas, using the patterns specified in Table 2 for the formulas with quantifiers.

#### 5. To test a specific version of *an* SMT solver on *an* individual file from our test suite: 

```./run.sh -testSolver <Z3-seq/Z3str3/CVC4> -latest/-prior -file <path to file>``` 

For example, the command ```./run.sh -testSolver Z3str3 -prior -file experiments/examples/figure9/z3_str3/test1558798332234_indexOf_const_1_012.smt2``` will test Z3str3 4.7.1 on the [example from Figure 9](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/examples/figure9/z3_str3/test1558798332234_indexOf_const_1_012.smt2). The solver returns sat, but produces an incorrect model.

#### 6. To test Z3-seq 4.7.1, Z3str3 4.7.1 and CVC4 1.6 on the StringFuzz benchmarks considered in our experiments, i.e., to reproduce the results discussed in Section 4.2: 

```./run.sh -testStringFuzz``` 

This experiment will run for **~1.5h**, as it uses the same experimental setup as experiments 2 and 3, and will output to the console the status of every test (pass/fail). The tests will be also stored in the folders StringSolversTests/passingTests and StringSolversTests/failingTests, respectively, grouped by their initial category (see Section 4.2). At the end of the experiment, two results files will be generated for every solver, for the sat and for the unsat formulas. The numbers should be the same as in our experiments (see [stringFuzzStatistics](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/stringFuzzTests/statistics/seed0)). It is possible to observe small differences (±1 test case) for Z3str3; as discussed in the paper, this solver may have non-deterministic behavior. 

#### 7. To generate the subset of our benchmarks used to test MT-ABC: 

```./run.sh -genABC``` 

This command will generate 5172 transformed benchmarks in **<1 min**, in the folder StringSolversTests/abcTests. The generated input formulas should be the same as in our experiments (see [abcTests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/abcTests)), but the names of the variables might be different for some tests.

#### 8. To test MT-ABC on the modified benchmarks, i.e., to reproduce the results from Table 7: 

```./run.sh -testABC```

This experiment will run for **~10min** and will output to the console the status of every test (pass/fail), as well as the error messages generated by the solver. The tests will be also stored in the folders StringSolversTests/passingTests/abc and StringSolversTests/failingTests/abc, respectively. At the end of the experiment, two results files will be generated, i.e., StringSolversTests/statistics\<current_time\>_abc_sat.txt and StringSolversTests/statistics\<current_time\>_abc_unsat.txt, for the sat and for the unsat formulas. The numbers should be the same as the ones reported in Table 7.

Note that we cannot provide an automated way to reproduce the results from Table 5. As explained in Section 4.1 (Subsection Known bugs), we manually matched some of the [failing tests](https://github.com/alebugariu/StringSolversTests/blob/master/experiments/failingTests) against the confirmed bug reports for [Z3](https://github.com/Z3Prover/z3/issues) and [CVC4](https://github.com/CVC4/CVC4/issues).
