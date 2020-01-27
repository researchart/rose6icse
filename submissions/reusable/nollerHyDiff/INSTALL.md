### How to install the HyDiff and make a test run
Be aware that the instructions have been tested for Unix systems only.

#### 1. First you need to clone our repository and retrieve our tool and the subjects.
```
git clone https://github.com/yannicnoller/hydiff.git --branch v1.0.0
```
The README in our repository provides more technical information about the tool.
We recommend to use the provided Docker image, which includes a pre-built variant.
```
docker pull yannicnoller/hydiff:v1.0.0
docker run -it --rm yannicnoller/hydiff:v1.0.0
```
Alternatively, you can build HyDiff on your own.
Therefore, we provide a script in our repository: *hydiff/setup.sh* to simply build everything.
Note: the script may override an existing site.properties file, which is required for JPF/SPF.


#### 2. Test the installation: the best way to test the installation is to execute the evaluation of our example program (cf. Listing 1 in our paper).

You can execute the script: hydiff/experiments/scripts/run_example.sh

Please make sure to run the script from its folder to avoid problems with the relative path definitions.

As it is, it will run each analysis (just differential fuzzing, just differential symbolic execution, and the hybrid analysis) **once**.
The values presented in our paper in Section 2.2 are averaged over 30 runs.
In order to perform 30 runs each, you can easily adapt the script, but for some first test runs you can leave it as it is.

The script should produce three folders:
* experiments/subjects/example/fuzzer-out-1: results for differential fuzzing
* experiments/subjects/example/symexe-out-1: results for differential symbolic execution
* experiments/subjects/example/hydiff-out-1: results for HyDiff (hybrid combination)
    
It will also produce three csv files with the summarized statistics for each experiment:
* experiments/subjects/example/fuzzer-out-results-n=1-t=600-s=30.csv
* experiments/subjects/example/symexe-out-results-n=1-t=600-s=30.csv
* experiments/subjects/example/hydiff-out-results-n=1-t=600-s=30-d=0.csv

The script run_example.sh will run ~30min, 10min for each analysis.
But if you want to reduce the time, you can modify the `time_bound` variable in the beginning of the script, e.g. to 60, i.e. 60sec=1min runtime per analysis.
Of course the results will not show the same results as presented in the paper, but you can check whether the tool is running.

To further check the results you can check the results of each component of Hydiff:
* for fuzzing you can check the folder `experiments/subjects/example/hydiff-out-1/afl`, it should contain the results summary `path_costs.csv` and the `queue` folder, which contains the generated test inputs
* for symbolic execution you can check the folder `experiments/subjects/example/hydiff-out-1/spf`, it should contain the results summary `export-statistic.txt`and the `queue` folder, which contains the generated test inputs
* additionally, there should be a folder `experiments/subjects/example/hydiff-out-1/spf-replay`, which includes the results for replaying the inputs by symbolic execution, and
* there should be a folder `experiments/subjects/example/hydiff-out-1/afl-spf`, which includes the merged results from SPF and AFL.


