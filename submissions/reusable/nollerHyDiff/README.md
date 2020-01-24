[![DOI](https://zenodo.org/badge/207993923.svg)](https://zenodo.org/badge/latestdoi/207993923)
# HyDiff: Hybrid Differential Software Analysis
This artifact provides the tool and the evaluation subjects for the paper *HyDiff: Hybrid Differential Software Analysis* accepted for the technical track at ICSE'2020.
HyDiff represents a hybrid differential analysis technique, which combines differential fuzzing and differential symbolic execution for test input generation.

The artifact includes:
* a setup script,
* the experiment subjects,
* the summarized experiment results,
* the scripts to rerun all experiments,
* and the source code for both components of Hydiff.

## Where can the artifact be obtained?
The artifact is published as GitHub repository:
https://github.com/yannicnoller/hydiff

We created a release for this arifact evaluation, which represents the current latest version:
https://github.com/yannicnoller/hydiff/releases/tag/v1.0.0

The artifact is also available under the archived DOI:
https://doi.org/10.5281/zenodo.3627893

For the simple usage we also provide a Docker image with the pre-built version of the mentioned GitHub repo:
https://hub.docker.com/r/yannicnoller/hydiff/tags

## How to reproduce our results?
After installing HyDiff and testing the installation, you can use the provided *run* scripts to replay HyDiff's evaluation, which contains three types of differential analysis.
For each of them you will find a separate run script:
* /experiments/scripts/run_regression_evaluation.sh
* /experiments/scripts/run_sidechannel_evaluation.sh
* /experiments/scripts/run_dnn_evaluation.sh

Please make sure to run the scripts from their folders to avoid problems with the relative path definitions.

In the beginning of each run script you can define the experiment parameters:
* `number_of_runs`: `N`, the number of evaluation runs for each subject (30 for all experiments)
* `time_bound`: `T`, the time bound for the analysis (regression: 600sec, side-channel: 1800sec, and dnn: 3600sec)
* `step_size_eval`: `S`, the step size for the evaluation (30sec for all experiments)
* [`time_symexe_first`: `D`, the delay with which fuzzing gets started after symexe for the DNN subjects] (only DNN)

Each run script first executes differential fuzzing, then differential symbolic execution and then the hybrid analysis.
Please adapt our scripts to perform your own analysis.

For each *subject*, *analysis_type*, and experiment repetition *i* the scripts will produce folders like:
`experiments/subjects/<subject>/<analysis_type>-out-<i>`,
and will summarize the experiments in csv files like:
`experiments/subjects/<subject>/<analysis_type>-out-results-n=<N>-t=<T>-s=<S>-d=<D>.csv`.

### Complete Evaluation Reproduction
In order to reproduce our evaluation completely, you need to run the three mentioned run scripts.
They include the generation of all statistics.
Be aware that the mere runtime of all analysis parts is more than **53 days** because of the high runtimes and number of repetitions.
So it might be worthwhile to run it only for some specific subjects or to run the analysis on different machines in parallel or to modify the runtime or to reduce the number of repetitions.
