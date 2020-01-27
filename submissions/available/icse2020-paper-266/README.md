

# Artifact of "Lazy Product Discovery in Huge Configuration Spaces"

## Description

This artifact documents an experimental comparison of the following three tools:
 * `pdepa` [[link]](https://github.com/gzoumix/pdepa): this tool is the implemented contribution of this artifact's paper. The goal of the comparison is to identify the advantages and weaknesses of this tool.
   `pdepa` is a *dependency solver* for portage.
   [Portage](https://wiki.gentoo.org/wiki/Portage) is the package manager of the [gentoo](https://www.gentoo.org/) linux distribution.
   A dependency solver for a package manager solves a dependency problem, i.e., deciding, given a set of package the user wants to install, which other packages to install so all dependencies between packages are satisfied.
   In the context of portage, which is a source-based package manager, the dependency problem also includes deciding how packages must be configured.
 * `standard`: this tool implements the standard product-discovery algorithm for portage repositories. We implemented this tool to compare `pdepa` with state of the art formal approaches for feature model analysis.
   This tool is part of the [`pdepa` repository](https://github.com/gzoumix/pdepa).
 * `emerge` [[doc]](https://wiki.gentoo.org/wiki/Portage#emerge): this tool is the official dependency solver of portage and is distributed with portage itself  [[link]](https://gitweb.gentoo.org/proj/portage.git/).
   `emerge` uses many heuristics to be efficient but fails finding a solution to the dependency problem quite often.
   Our comparison focused on analysing the failure rate of `emerge` as well as how efficient it is (both in term of time and memory) compared to `pdepa` and `standard`.


## Running an Experimental Comparison

In this section, we explain how to setup a comparison environment and perform an experiment.
This is done in 4 steps.

### 1. Execution Environment Setup

While it is possible to run an experiment on the local machine, it is recommended for a realistic sized experiment to be executed on several remote locations, e.g., using a cloud provider.
We consider a master-slave architecture where the master generates the experiment, the slaves runs it, and the master retrieves the slaves' results and combine them.
We will discuss alternative execution environment later.

The experiment scripts are implemented in `python3` and `bash`: both interpreters must be installed on all locations.
They also use [docker](https://www.docker.com/): it must be installed and running on all locations.
In this document, we will use the same docker image that was used to run the experiments discussed in this artifact's paper: [`gzoumix/pdepa:icse2020`](https://hub.docker.com/r/gzoumix/pdepa/tags).

Finally, the master must download the experiment scripts.
The simplest way to do so is to clone the pdepa repository:
```
git clone https://github.com/gzoumix/pdepa.git
```
This way, the bench scripts will be available in the folder `./pdepa/src/test/bench/`.


### 2. Generation of experiments

To generate an experiment, we use the `bench_gen.py` script available in the `gzoumix/pdepa:icse2020` docker image and documented [here](https://github.com/gzoumix/pdepa/tree/master/src/test/bench#bench_genpy).
Hence, to generate an experiment of 1000 random dependency problems, each of them requiring between 1 and 10 packages to install, and store it in the file `experiment.txt`, run on the master location the following command line:
```
docker run gzoumix/pdepa:icse2020 bash -c "python /opt/pdepa/src/test/bench/bench_gen.py 1000 1 10" > experiment.txt
```


### 3. Performing the experiments

To send the experiment on the slave location, we first need to fill, on the master location, a `remote.txt` file that describe how to connect to the locations, like documented in [here](https://github.com/gzoumix/pdepa/tree/master/src/test/bench#remotetxt).
Note that these remote locations must have an ssh daemon running.
Once this file is created, we can run the following command line to distribute the generated experiment on the slave locations:
```
bash ./pdepa/src/test/bench/bench_send.sh -s -d remote.txt experiment.txt
```
This will create a `experiment.txt` file in every slave location specified in `remote.txt` with about 1000/nb_remote_location dependency problems to run.
This will additionally copy the scripts `./pdepa/src/test/bench/bench_run.sh` and `./pdepa/src/test/bench/bench_data.sh` to the slave locations, since these scripts must be run there.

Finally, to actually run the experiment, we execute the following command line on every slave node:
```
nohup bash bench_run.sh -k gzoumix/pdepa:icse2020 -l experiment.txt bench_1 &
```
This command line will run the experiment once for each `bench_?` folder specified in the command line.
Hence, here the experiment will be run only once, but adding more folders will execute the experiment more times: e.g., adding `bench_2 bench_3 bench_4 bench_5` to the command line will run the experiment 5 times.

The `bench_run.sh` script runs (within the `gzoumix/pdepa:icse2020` docker image) `pdepa`, `standard` and `emerge` on every dependency problem described in the file `experiment.txt`
 and stores their output messages (together with their time and memory consumption) in dedicated files; e.g., `bench_1/test_0/emerge.out` contains the output of `emerge`'s first execution of the first dependency problem.
Running the experiment can take a while, so we provide a command line that tells how many dependency problems still need to be tested:
```
NB=$(ls -d bench_? | wc -w); echo $(( ($(wc -l experiment.txt | cut -f1 -d' ')+1) * NB - $(ls bench_? | wc -w)  + $([ `ps aux | grep bench_run | wc -l` -gt 1 ] && echo 1 || echo 0) ))
```

Once the computation is finished, we run the `bench_data.sh` script on every slave location to analyse the outputs:
```
bash bench_data.sh bench_1
```
This will create in every `bench_?` folder in parameer a `table.csv` file that collects all the relevant information about the run tests, as documented [here](https://github.com/gzoumix/pdepa/tree/master/src/test/bench#tablecsv).
Note that if the experiment was run in several folders, these folders must also be given in parameter of the `bench_data.sh` script.



### 4. Collecting the results

Once all the `table.csv` files are generated on the slave locations, we can collect them in the master and combine them to extract statistics and graphs.
Collecting the `table.csv` files is done with the following command line (run on the master location):
```
bash ./pdepa/src/test/bench/bench_wget.sh -d remote.txt bench_1
```
This will create locally the `bench_?` bench folder specified in parameter, each of them containing the data from the correponding bench folder on every slave location.

Finally, running the following command line will generate some files about the statistics of the bench together with some graphs as can be seen in the artifact's paper:
```
python ./pdepa/src/test/bench/bench_data.py bench_1
```
Note however that the generated images will be slightly different from the ones in the paper, since these last ones were generated using LaTeX.
The generated files and images are documented [here](https://github.com/gzoumix/pdepa/tree/master/src/test/bench#analyse-and-compare-pdepa).




## Experiments in the artifact's paper


The concrete experiments reported in this artifact's paper were done using the following versions of the tools and data, all of them available in the [`gzoumix/pdepa:icse2020`](https://hub.docker.com/r/gzoumix/pdepa/tags) docker image:
 * `pdepa` and `standard` [[github link]](https://github.com/gzoumix/pdepa/tree/330c37a9b4a0f9878e6bfea4f5ba6995fe97c54d):
   we used this version of the tools to run our experiments.
 * `emerge` [[docker image link]](https://hub.docker.com/layers/gentoo/stage3-amd64/20190301/images/sha256-0aa11d9559f0d952f23d8ba7518f9fe78e9426b4854aa697141f30cd3fe07870):
   we used the March 1st 2019 version of `emerge` contained in the base gentoo system.
   We retrieved this version from a docker image.
 * `portage repository` [[docker image link]](https://hub.docker.com/layers/gentoo/portage/20190301/images/sha256-ca1689647b18fa65168e8ebb508077c23c7bf5e1dbba9dfbd699f7f255cdf5e2):
   we used the March 1st 2019 version of the official gentoo package repository to generate and test our experiment.
   We retrieved this version from a docker image.


To generate, run and analyse the experiment, we used the same workflow as previously described:
 * the experiment we generated is stored in the `tests.txt` file distributed within this artifact
 * the experiment was run on 18 slave locations with 8GB of RAM, 2 vCSPUs (Intel Haswell processors, 2.5 GHz), and was running an Ubuntu 19.04 operating system
 * the experiment was run 5 times, and the resulting 5 `table.csv` files are stored in the file `results.tar.bz2`, distributed within this artifact




## Alternative Experiment Workflow

In this section, we discuss alternative workflow to run a comparion experiment.
For simplicity, in this Section, we call *test* a dependency problem.

### Running locally a single test using docker

To compare in a reasonable amount of time `pdepa`, `standard` and `emerge` on a standard hardware,
 it is possible to run a single random test with no repetitions by using the Docker image available at [gzoumix/pdepa:icse2020 docker image](https://hub.docker.com/r/gzoumix/pdepa/tags)
 and the two scripts `bench_run.sh` and `bench_data.sh`.
As with the normal workflow, [docker](https://www.docker.com/) must be installed and running, and the experiment scripts must be installed (we still suppose they are available in the folder `./pdepa/src/test/bench/`.).

The command line to run such a random test and analyse it in the `bench` folder is as follows:
```
docker run gzoumix/pdepa:icse2020 bash -c "python /opt/pdepa/src/test/bench/bench_gen.py 1 1 10" | bash ./pdepa/src/test/bench/bench_run.sh -k gzoumix/pdepa:icse2020 bench; bash ./pdepa/src/test/bench/bench_data.sh bench
```
This command line is structured in three parts:
 * `docker run gzoumix/pdepa:icse2020 bash -c "python /opt/pdepa/src/test/bench/bench_gen.py 1 1 10"` generates one test, called `test_0`, containing between 1 and 10 packages to install and writes it to the standard output.
 * `bash ./pdepa/src/test/bench/bench_run.sh -k gzoumix/pdepa:icse2020 bench` takes the test in input, runs it, and stores the output of the different tested tools in the `bench/test_0` folder.
   `bench` is the name of the folder specified in the command line, while `test_0` is the name of the test
 * `bash ./pdepa/src/test/bench/bench_data.sh bench` analyses the tests stored in the `bench` folder and generate a csv file `bench/table.csv` stating for each tested tool, among other information, if that tool failed and how much time and memory it took to complete.

Note that this command line does not call `bench_data.py` to generate statistics and graphs from the experiment, since only one test was executed.
Note that this command can take up to 30 minutes.
It is of course possible to modify the command line to perform more tests and replicate them, but this can quickly take a lot of time to run.


### Running locally several test using docker

It is possible to run in parallel several tests on the same machine, with the `-c` option of the `bench_run.sh` script.
Note however that the `standard` tool takes about 4Gb of memory: this must be taken in account when running several tests in parallel.
Another option is to disable testing the standard approach with the `-no standard` option of the `bench_run.sh` script: `emerge` and `pdepa` respectively take in average 77 and 400Mb of memory.
Disabling the standard approach also reduces the computation time by a factor of 10 or more.

So, running the tests stored in the `experiment.txt` file locally on 16 core while disabling the standard approach can be done with the following command line:
```
bash bench_run.sh -k gzoumix/pdepa:icse2020 -l experiment.txt -c 16 -no standard bench_1 bench_2 bench_3 bench_4 bench_5
```

### Running without docker

It is possible to run the experiment without docker.
To do so, we need to locally create an environment in which `pdepa` and `standard` can be executed.
These two tools depend on
 * [`portage`](https://gitweb.gentoo.org/proj/portage.git/): provides a useful API to retrieve information from available portage repositories
 * Any portage repository
 * [`z3`](https://github.com/Z3Prover/z3) with its python bindings: provides a user-friendly SAT solver
 * [`lrparsing`](https://pypi.org/project/lrparsing/): provides a grammar parser generator that we use to parse packages constraints and dependencies

The easiest way to create such an environment is to install `pdepa` on a gentoo system.
This can be done with the following command line on the gentoo system:
```
emerge -qv dev-vcs/git dev-python/pip sys-process/time && pip install --user z3-solver lrparsing && git clone https://github.com/gzoumix/pdepa.git
```

Once `pdepa` is installed, we can directly run the scripts available in the folder `./pdepa/src/test/bench/`.
Note that for the `bench_run.sh` not to use a docker image, we just need to skip the `-k gzoumix/pdepa:icse2020` option.







