# FPGen Artifact  
The artifact accompanying the submission icse20-main-171 "Efficient Generation of Error-Inducing Floating-Point Inputs via Symbolic Execution"
is available on `https://github.com/ucd-plse/FPGen.git`.

Note: The original results are produced on a workstation with Intel(R) Xeon(R) Gold 6238 CPU (8 cores, 2.10GHz), 32GB RAM, and the operating system
is Ubuntu 14.04.5 LTS. To reproduce the results, a machine with similar CPUs(~2.10GHz and at least 8 cores), 32GB or larger RAM is 
required. Running the artifact on a different machine could possibly diverge the execution and lead to different results. Moreover, all 
the experiments have to be run sequentially.  

## Getting Started

  #### 1. Pull the docker image of FPGen artifact and creat, run the FPGen container  
  ```
  $ docker pull ucdavisplse/fpgen-artifact:icse20   
  $ docker run -ti --name=FPGen --cpus=8 --memory=32g ucdavisplse/fpgen-artifact:icse20   
  ```
  Notes:  
  when inside the FPGen container,  
  (1) to exit the FPGen docker container and terminate all running jobs inside the container, use:   
  ```
  $ exit
  ```
  (2) to detach from the running FPGen container without stopping it, 
  ```
  press CTRL+P followed by CTRL+Q
  ```
  when outside the FPGen container and looking to start/attach to it, run: 
  ```
  $ docker start -ai FPGen 
  ```
  #### 2. Clone FPGen github repo. and rename it
  Inside FPGen container, navigate to home directory, clone this repo. and rename it,
  ```
  $ cd
  $ git clone https://github.com/ucd-plse/FPGen.git
  $ mv FPGen FPTesting
  ```
  
  ## Run FPGen or baseline tools on selected benchmarks 
  navigate to _benchmarks_
  ```
  $ cd /home/fptesting/FPTesting/benchmarks; ls 
  ``` 
  The benchmarks are divided into three parts:  
   (1) **summations** (3 summation tests):
   ```
    recursive-summation pairwise-summation compensated-summation
   ```
   (2) **matrix** (9 meschach tests): 
   ```
    sum 1norm 2norm dot conv mv mm lu qr
   ```
   (3) **gsl** (15 gsl tests): 
   ```
    wmean wvariance wsd wvariance-w wsd-w wtss wtss-m wvariance-m wsd-m wabsdev wskew wkurtosis wabsdev-m wskew-m wkurtosis-m
   ```
   
  In each part, there is a README file (click the link below) that describes the detailed steps to replicate the results of FPGen or the 3 baseline tools RANDOM, S3FP and KLEE-FLOAT for one, some or all tests in that part.
  
  
  * __summations__ https://github.com/ucd-plse/FPGen/tree/master/benchmarks/summations
  * __matrix__ https://github.com/ucd-plse/FPGen/tree/master/benchmarks/matrix
  * __gsl__ https://github.com/ucd-plse/FPGen/tree/master/benchmarks/gsl
  
  ## Run FPGen or baseline tools on all benchmarks 
  navigate to _benchmarks_
  ```
  $ cd /home/fptesting/FPTesting/benchmarks 
  ``` 
  To replicate the results of FPGen for all 27 tests at one time, use _fpgen\_all.sh_, and the run will take approximately 54-60 hours:
  ```
  $ nohup ./fpgen_all.sh & 
  ```
 The FPGen results will be collected in file _result-fpgen.txt_. 
 You can either inspect the results manually by comparing them to _reference/result-fpgen-all.txt_ or use our utility script 
 to compare the results automatically by running:
 ```
 $ ../scripts/cmp_to_ref.sh -a result-fpgen.txt reference/result-fpgen-all.txt
 ```
 The comparison script will report "check pass" or "check failed" for each test.
 
 To replicate the results of RANDOM/S3FP/KLEE-FLOAT for all tests at one time, use _baselines\_all.sh_, and the run will take approximately 108-120 hours:  
 ```
  $ nohup ./baselines_all.sh &  
 ```
The RANDOM/S3FP/KLEE-FLOAT results will be collected in file 
_result-baselines.txt_. Inspect the results by comparing them to _reference/result-baselines-all.txt_. 

## Discussion 
FPGen starts with a random search that provides the base values of the input data for the algorithm to further improve. The random search, however, is performed with a time threshold which we found is unstable across machines even with similar hardware specifications. To increase the chance of replication/reproduction, we provide the base values in the artifact and skip this step, which is obsereved to be helpful in replicating/reproducing the FPGen results in other machines. To ignore the base values we provide and start FPGen from scratch, use _fpgen-from-scratch.sh_ for __gsl__ and __matrix__ tests, and the same _fpgen.sh_ for __summations__ tests.
