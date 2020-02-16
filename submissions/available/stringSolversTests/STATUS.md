We are applying for the ```Reusable``` and ```Available``` badges. 

Our artifact is functional, it was used to automatically synthesize input formulas in SMT-LIB 2.6 format that are satisfiable 
or unsatisfiable by construction, together with a model, or with the minimal unsat core, respectively. These inputs were then 
used for testing the implementation of the SMT and automata-based string solvers considered in the evaluation of our paper. 
Several test cases have been reported to the developers of these solvers, and the corresponding bugs have been confirmed or 
fixed.

Our tool is publicly available on Github: https://github.com/alebugariu/StringSolversTests and it has a DOI [![DOI](https://zenodo.org/badge/235884734.svg)](https://zenodo.org/badge/latestdoi/235884734).
We also [provide](https://github.com/alebugariu/StringSolversTests/tree/master/experiments)
all our generated test cases, the SMT-LIB encoding of the examples from the paper and all the results we obtained for the 
solvers under test, to enable subsequent research studies.

The code is well-structured and detailed instructions on how to use our tool to rerun our experiments are also 
[publicly available](https://github.com/alebugariu/StringSolversTests/blob/master/EXPERIMENTS.md).
