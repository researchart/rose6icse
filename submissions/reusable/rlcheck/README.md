# RLCheck: Artifact Evaluation

This document has the following sections:
- **Download information + getting started** (approx. 10 human-minutes): Download a Docker container containing RLCheck's code, as well as pre-baked data from the paper. Make sure it runs on your system.
- **Part one: Validating claims in the paper** (approx. 10 human-minutes): Analyze pre-baked results of the full experiments. Run scripts to produce the figures used in the paper. 
- **Part two: Running fresh experiments** (approx. 10 human-minutes + approx. 15 compute-hours): Run a short version of the experiments to get a fresh-baked subset of the evaluation results. You can use the instructions from part one to produce figures for your own fresh-baked experiments, which should approximate the figures in the paper. *Optional*: Add approx. 30-60 compute-hours for a better quality approximation. The full evaluation takes 150 compute-hours. 
- **Details on the code**: Additional documentation explaining the structure of the core RLCheck code.


## Getting-started (same as INSTALL.md)

### Requirements 

* You will need **Docker** on your system. You can get Docker CE for Ubuntu here: https://docs.docker.com/install/linux/docker-ce/ubuntu. See links on the sidebar for installation on other platforms.

### Load image or download code

To load the artifact on your system, pull the image from the public repo.
```
docker pull carolemieux/rlcheck-artifact
```

Alternatively, you can clone the the code from the [public github repo](https://github.com/sameerreddy13/rlcheck). If you clone the code instead, run the following to set up the code:
```
cd /path/to/rlcheck
cd jqf
mvn package 
cd ..
```
replace `rlcheck-artifact` with `/path/to/rlcheck` in the instructions below instead. 

### Run container

Run the following to start a container and get a shell in your terminal:

```
docker run --name rlcheck -it carolemieux/rlcheck-artifact
```

The remaining sections of this document assume that you are inside the container's shell, within the default directory `/rlcheck-artifact`. You can exit the shell via CTRL+C or CTRL+D or typing `exit`. This will kill running processes, if any, but will preserve changed files. You can re-start an exited container with `docker start -i rlcheck`. Finally, you can clean up with `docker rm rlcheck`.

### Container filesystem

The default directory in the container, `/rlcheck-artifact`, contains the following contents:
- `README.md`: This file. 
- `rlcheck`: this is the rlcheck implementation
	- `jqf`: This is the main rlcheck implementation used in the evaluation on top of the the Java fuzzing platform JQF (cloned from https://github.com/rohanpadhye/jqf). 
	- `bst_example`: python implementation used for the case studies in Section 4 of the paper.
- `scripts`: Contains various scripts used for running experiments and generating figures from the paper.
The following are only present in the container distribution, not in the public github repo:
- `pre-baked`: Contains results of the experiments that were run on the authors' machines. 
    - `java-data`: data for the main evaluation
    - `python-data`: data for the evaluation of Section 4. 
- `example_figs`: examples of Figures 6-10 with fewer reps, on the author's machine. 
- `fresh-baked`: This will contain the results of the experiments that you run, after following Part Two.

## Part One: Validating claims in paper (10 minutes human time)

This section explains how to analyze the results in `pre-baked`, which have been provided with the artifact, to produce the figures in the paper. You can follow the same steps with the results of your own `fresh-baked` experiments, which you will conduct in part two.

1. Generate plots for Figures 4-5:
```
python3 scripts/gen_fig4_fig5.py pre-baked
```
2. Generate plots for Figures 6-8:
```
python3 scripts/gen_fig6_fig7_fig8.py pre-baked
```
3. Generate plots for Figures 9-10:
```
python3 scripts/gen_fig9_fig10.py pre-baked
```

Once you run any of the above commands, do `ls pre-baked/figs` to list the generated PDFs for the `pre-baked` results. You can copy the PDF files from the docker container to your host machine to open them in a PDF viewer. Assuming you started the container with `docker run --name rlcheck ...`, you can run the following command on your host: 

```
docker cp rlcheck:rlcheck-artifact/pre-baked/figs TARGET-DIR-NAME
```

`TARGET-DIR-NAME` on your local machine will now contain the figures you generated. These should show the same data as the figures in the paper. 


## Part Two: Running fresh experiments (10 minutes human time + 15+ hours compute time)

### Section 4 Evaluation (5 minutes human time + 2+ minutes compute time)
The evaluation of the data from Section 4 involes experiments with **4 fuzzing techniques** on **1 benchmark program**. You can run the experiments with the script:
```
./scripts/run_python_exps.sh RESULTS_DIR REPS
```
Where `RESULTS_DIR` is the name of the directory where results will be saved, and `REPS` is the number of repetitions to perform. 

The results will be put in `RESULTS_DIR/python-data`. If the script finds output for rep `i` it will skip that rep to avoid data loss. Thus, if you run `./scripts/run_python_exps.sh fresh-baked 3` for the first time three reps will be executed. However, if you run `./scripts/run_python_exps.sh fresh-baked 3` *after* having run `./scripts/run_python_exps.sh fresh-baked 1`, only 2 reps will be executed, since the first rep results already exist. 

Each rep takes around 1-2 minutes to execute. In the paper we ran 10 reps; you can run a smaller number (we recommend at least 3-5) depending on your resource constraints

### Main Evaluation (5 minutes human time + 15+ hours compute time)

The main evaluation of this paper involves experiments with **4 fuzzing techniques** on **4 benchmark programs**. The experiments can be launched via `scripts/run_java_exps.sh`, whose usage is as follows:

```
./scripts/run_java_exps.sh RESULTS_DIR REPS
```

Where `RESULTS_DIR` is the name of the directory where results will be saved, and `REPS` is the number of repetitions to perform. The file `experiments.log` will be generated during execution of this script; you can examine it to monitor the progress of the data generation. 

Again, if the script finds output for rep `i` it will skip that rep to avoid data loss. Thus, if you run `./scripts/run_java_exps.sh fresh-baked 3` for the first time three reps will be executed. However, if you run `./scripts/run_java_exps.sh fresh-baked 3` *after* having run `./scripts/run_java_exps.sh fresh-baked 1`, only 2 reps will be executed, since the first rep results already exist. 

Running the above script produces `24 x REPS` sub-directories in `fresh-baked/java-data`, with the naming convention `$TECHNIQUE-$BENCH-$ID(-replay)`, where:
- `BENCH` is one of `ant`, `maven`, `closure`, `rhino`. 
- `TECHNIQUE` is one of `rl`, `rl-blackbox` (symlink to `rl`), `rl-greybox`, `quickcheck`, or `zest`.
- `replay` exists for `rl`, `rl-blackbox` (symlink to `rl-...-replay`), and `quickcheck`
- `ID` is a number between 0 and `REPS-1`, inclusive.


One rep takes around *14-15 hours* on our machine. The base runtime for each rep is (4 techniques) x (4 benchmarks) x 5 minutes = 80 minutes. The two blackbox techniques (RLCheck + QuickCheck) are run without instrumentation. While this allows us to fairly compare them to the greybox techniques (in terms of the speedup blackbox provides), this means we lack data for Figures 6-10. Thus, to collect data for Figures 6-10, we *replay* RLCheck (with the same random seed) and QuickCheck with instrumentation, stopping them after they generate the number of inputs generated in 5 minutes without instrumentation. For the closure benchmark, this replay can take nearly 3 hours. 

For the paper we ran 10 reps. Depending on your resource contraints, you can run a smaller number (at least 1; 3-5 will give results with less variance). 

### Plotting fresh-baked results

You can use the commands from Part One to generate Figures 4-10 for your fresh-baked data. Depending on your number of reps and the specs of your machine, these may look somewhat different from the graphs in the paper. However, the trends should be similar. For your reference of how the graphs may look different, see `example_figs` in the Docker container, which show results for a fewer number of reps, run on a machine with 16GB RAM and an AMD Ryzen 7 1700 CPU.
*Note: if you run a single rep, no confidence intervals are plotted.*

## Details on the code

### Directory structure

Inside the `rlcheck` directory, we have the two main subdirectories:
* `jqf`: the main RLCheck implementation built on top of JQF
* `bst_example`: a python implementation of RLCheck for a BST example

### RLCheck Changes to JQF

The implementation of RLCheck on top of JQF is a prototype. Most of the code, including the base class for the generators as well as the learners, can be found in the `jqf/fuzz/src/main/java/edu/berkeley/cs/jqf/fuzz/rl` directory. The core classes are:
* `RLLearner`: implementation of a MCC learner, as described in the paper
* `RLOracle`: an oracle (called a *guide* in the paper) which groups together several learners in order to act as a source of "randomness".
* `RLGenerator`: interface which an RL-guided generator must satisfy
* `RLGuidance`: instance of JQF's guidance, which acts as a glue between the RLGenerator and the unit test. Handles dispatching the proper reward to the generator's guide (oracle), and pulls a new input from the generator.
* `RLDriver`: main driver which loads the test class/method, as well as the RLGenerator used to generate inputs, and starts up an instance of RLGuidance. 
* `RLParamParser`: helper class to parse a json file into parameters for the RLGenerators

In this prototype implementation, RLCheck generators are not proper JQF generators. This is because (at the time of writing) JQF's Guidance interface only supported providing guidance at the bytestream level. RLCheck, on the other hand, provides guidance directly at the SourceOfRandomness (replaced by the RLOracle). As such, specialized generators need to be built. The implementation on top of JQF in this repo provides two, notably:
```jqf/examples/src/main/java/edu/berkeley/cs/jqf/examples/xml/XmlRLGenerator.java```
and
```jqf/examples/src/main/java/edu/berkeley/cs/jqf/examples/js/JavaScriptRLGenerator.java```

### Build + Run RLCheck

To build the main RLCheck go to the jqf folder and run
```mvn package```
(the docker container comes with a pre-built version of RLCheck). 

You should then be able to run the following command:
```$JQF_DIR/bin/jqf-rl -c CLASSPATH TEST_CLASS TEST_METHOD RL_GENERATOR CONFIG_FILE [OUTPUT_DIR]```

Where $JQF_DIR is the location of the `jqf` subdirectory of RLCheck. For example, to run 
```$JQF_DIR/bin/jqf-rl -c $($JQF_DIR/scripts/examples_classpath.sh) edu.berkeley.cs.jqf.examples.maven.ModelReaderTest testWithInputStream edu.berkeley.cs.jqf.examples.xml.XmlRLGenerator $JQF_DIR/configFiles/mavenConfig.json [OUTPUT_DIR]```

**Note**: these commands run the *instrumented* version of RLCheck. While this results in a nice status screen, it also can cause substantial slowdowns on some benchmark. Add the `-n` flag to run an uninstrumented session (no status on increases in coverage, but faster execution), e.g.: `$JQF_DIR/bin/jqf-rl -n -c [CLASSPATH] ...`




