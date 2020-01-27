# Table of Contents
1. [Artifact Contents](#artifact-contents)
2. [Artifact Location](#artifact-location)
3. [File Contents](#file-contents)
4. [Tool Usage Documentation](#tool-usage-documentation)
5. [Running the Experiments](#running-the-experiments)

# Artifact Contents
This artifact contains everything necessary to reproduce the results of our ICSE 2020 Paper "ReluDiff: Differential Verification of Deep Neural Networks." This includes:
- Source code used to run the experiments on ReluDiff, ReluVal, and DeepPoly
- Neural networks used in the experiments
- Tools to produce the truncated networks and subtracted networks
- Documentation on how use our tools and re-run our experiments

# Artifact Location
We provide a VM with all of ReluDiff, ReluVal, and DeepPoly working out of the box [here](https://drive.google.com/file/d/1rKKUXIBTtHL4M_a8O2__uAJRveXtg4Cj/view?usp=sharing). The username and password are "reludiff" and " " (i.e. a single space character). In addition, we provide instructions for setting up each of the tools on a fresh Ubuntu 16.04 installation in the [INSTALL.md](INSTALL.md) file using our [artifact repo](https://github.com/pauls658/ReluDiff-ICSE2020-Artifact).

# File Contents
Here we document the contents of the files under ReluDiff-ICSE2020-Artifact in our VM (which is the same as the files found in our [artifact repo](https://github.com/pauls658/ReluDiff-ICSE2020-Artifact)). The documentation for running ReluDiff, ReluVal, DeepPoly, and our various utility scripts can be found in the [next section](#tool-usage-documentation).
### DiffNN-Code/ 
This is the source code of ReluDiff. It has the following files:
#### delta\_network\_test.c
The main entry point for ReluDiff. It handles parsing the input arguments and starting the verification process.
#### nnet.c
Contains the code for:
- loading a network (function: *load\_network*)
- loading an input property (function: *load\_inputs*)
- performing the forward pass and backward propagation (functions: *forward\_prop\_delta\_symbolic* and *backward\_prop*)
#### nnet.h
Declarations for the functions in nnet.c.
#### split.c
Contains code for:
- The main function that starts the verification process (function: *direct\_run\_check\_delta*) which does the following:
	- Performs the forward pass
	- Checks if the property is satisfied
	- If not, then calling the function to refine the analysis by splitting the input interval (see the next bullet)
- The function that determines which input property to split on, and allocating new memory for the split (function: *split\_interval\_delta*)
#### split.h
Contains the definitions for the above functions.
#### matrix.h
Contains the definition for the struct that stores our matrices and declarations of our matrix mutliplication functions.
#### matrix.c
Contains the functions that call the OpenBLAS matrix multiplication functions on our matrix structs.
#### interval.h
Contains the definition for the struct that represents the intervals during the forward pass.
#### mnist\_tests.h
Defines three data structures for the mnist properties, which are:
- A 2-D array *mnist\_test* that contains 100 test MNIST images (an image is stored as an array of 784 integers)
- An array *correct\_class* of 100 integers corresponding to the correct classification of the 100 test MNIST images
- A 3x100 2-D array *random\_pixels* to determine which pixels to perturb in the 3 pixel experiment. Each entry in this array is a triple of integers each in the range 0-783 which correspond to the three pixels to perturb
#### HAR\_tests.h
Defines two data structures for the HAR properties, which are 
- A 2-D array *HAR\_test* that contains 100 test inputs from the HAR data set
- An array *HAR\_correct\_class* of 100 integers corresponding to the correct classification of the 100 test inputs
#### python/
This directory contains python scripts for
- Create a truncated network (file: *round\_nnet.py*)
- Create a subtracted network (file: *subtract\_nnets.py*)
#### scripts/
This directory contains scripts for:
- Creating all of the truncated and subtracted networks used in our evaluation (file: *make\_all\_compressed\_nnets.sh*)
- Running all of the experiments in our paper (files: *run\_&#10033;\_exec-time\_experiments.sh* and *run\_ACAS\_prop4\_depth\_exp.sh*)
- Demonstrating example usages of ReluDiff (files: *run\_&#10033;\_artifact.sh*)
#### nnet/
This directory contains all of the neural networks used in our examples. The file format for the neural network is described [here](https://github.com/sisl/NNet/).

### ReluVal-for-comparison/
This directory contains a slightly modified version of [ReluVal](https://github.com/tcwangshiqi-columbia/ReluVal). Documentation on its contents can be found [here](https://github.com/tcwangshiqi-columbia/ReluVal).

Our modified version makes a small change to the forward pass so that it correctly handles the subtracted networks. Specifically, we change the forward pass so that the final _two_ layers of the input neural network perform only an affine transformation (as opposed to affine transform + ReLU). The original ReluVal only does this for the final layer.

In addition, we add our new input properties to ReluVal. The method for doing this is described in the original ReluVal documentation.

### eran/
This directory contains the original source code of [ERAN](https://github.com/eth-sri/eran). The documentation can be found [here](https://github.com/eth-sri/eran). It also contains some additional files for performing our experiments. We document them below.
#### eran/tf\_verify/diff\_analysis.py
This is the entry point for running our experiments.
#### eran/tf\_verify/diff\_analysis\_artifact.py
This is the entry point for running our artifact experiments.

#### eran/NNet/nnet
This directory contains all of the subtracted networks that we used in our experiments. They are in the format used by ERAN.

# Tool Usage Documentation
Here we document how to use the various scripts and tools for each of the techniques we evaluated in our paper.
## ReluDiff
### DiffNN-code/delta\_network\_test
This is ReluDiff's main executable. To get a help menu, run *./delta\_network\_test* without any parameters. We also provide the documentation below.
```console
./delta_network_test PROPERTY NNET1 NNET2 EPSILON [OPTIONS]
```
- PROPERTY: an integer value indicating which pre-defined property to verify. The value can be:
	- 1-5, 7-15, 16, 26: These values correspond to the ACAS Xu properties orginally defined by Katz et al. in their [Reluplex](https://arxiv.org/pdf/1702.01135.pdf) and Wang et al. in their [ReluVal](https://arxiv.org/pdf/1804.10829.pdf) paper. See the appendix of [this](https://arxiv.org/pdf/1804.10829.pdf) paper for desciptions. The integers 1-5 and 7-15 directly correspond to properties 1-5 and 7-15 respectively. Property 6 is broken into two parts, corresponding to 16 and 26.
	- 400-499: These values are used for the MNIST properties. Each of the 100 values corresponds to a single input image, and then a perturbation is applied to the image to generate the input property. These properties require that either '-p' or '-t' is specified as an option. If '-p' is specified (see below), a global perturbation will be applied as described in the evaluation of our paper. If '-t' is specified, then three random pixels will be perturbed (see below). 
	- 1000-1099: These values are used for the HAR properties. Each of the 100 values corresponds to a single test input, and then a perturbation is applied to the input to generate the input property. These properties require that '-p' is specified as an option.
- NNET1, NNET2: file paths to \*.nnet files to compare.
- EPSILON: A floating point value. ReluDiff will attempt to verify that NNET1 and NNET2 cannot differ by more than EPSILON over the input region defined by PROPERTY
- OPTIONS<br/>
	-p PERTURB : specifies the strength of the global perturbation to apply to the MNIST and HAR properties. For MNIST this should be an integer between 0-254. For HAR, this should be a float between -1 to 1.<br/>
	-t : Performs three pixel perturbation on the MNIST images instead of global perturbation<br/>
	-m DEPTH : (not used for our paper) forces the analysis to 2^DEPTH splits and then prints region verified at each depth<br/>

### DiffNN-Code/python/round\_nnet.py
This script takes in a neural net file in the .nnet format, truncates its weights to 16 bits, and then outputs the result.
```console
python3 round_nnet.py NNET OUTPUT-PATH
```
- NNET: the file path to the input neural network
- OUTPUT-PATH: the location to write the truncated neural net to

### DiffNN-Code/python/subtract\_nnets.py
This script takes in two neural net files in .nnet format and outputs a combined neural net in .nnet format that subtracts the two. Note that the final two layers are assumed to be affine transforms *only* (no ReLU). Our modified ReluVal handles these networks correctly, however the original ReluVal would not handle this correctly.
```console
python3 subtract_nnets.py NNET1 NNET2 OUTPUT-PATH
```
- NNET1, NNET2: the two input neural networks to subtract
- OUTPUT-PATH: the output path to write the subtracted neural net to

### DiffNN-Code/scripts/make\_all\_compressed\_nnets.sh
This script will produce all of the truncated and subtracted networks used in our experiments. It takes every network in *DiffNN-Code/nnet*, outputs the truncated network to *DiffNN-Code/compressed\_nnets*, and outputs the subtracted network to *../ReluVal-for-comparison/subbed\_nnets*.

### DiffNN-Code/scripts/run\_&#10033;\_exec-time\_experiments.sh
These four scripts correspond to the four main experiments run in our paper, namey ACAS Xu, MNIST global perturbation, MNIST 3 pixel perturbation, and HAR. They will run ReluDiff on all of the properties for the appropriate experiment and write the results to a log file beginning with *exec-time\_out*. The log file will contain a block of text for each property. The block will start with the command that was run, followed by the command's output. For example, after running ACAS property 1 on ACAS network 1\_1, the following will be written to the log file:
```console
./delta_network_test 1 nnet/ACASXU_run2a_1_1_batch_2000.nnet compressed_nnets/ACASXU_run2a_1_1_batch_2000_16bit.nnet 0.05
Initial output delta:
[-575.950135 -690.059144 -734.842591 -768.888978 -766.148133]
[578.371154 693.030029 737.171142 769.655822 767.615173]

No adv!
time: 2.422256

numSplits: 2619
```
The two arrays after "Initial output delta:" are the lower and upper bounds of the difference between the two networks computed on the _first forward pass_. "No adv!" indicates that the property was verified, followed by total time taken to verify the property. If there is no line beginning with "time:", then ReluDiff could neither verify nor disprove the property. The last line shows the total number of times the original input interval was split.

### DiffNN-Code/scripts/run\_&#10033;\_artifact.sh
These four scripts contain an example of how to run ReluDiff for a single property of each of the four different experiments.

### DiffNN-Code/scripts/run\_ACAS\_prop4\_depth\_exp.sh
This collects depth information when verifying property 4 as desribed in the evaluation of our paper. Each time the forward pass is able to ceritify a sub-interval, it outputs an integer indicating the current depth to a log file.

## ReluVal
### ReluVal-for-comparison/network\_test
This is the main executable for running ReluVal in our experiments. It's usage is identical to *delta\_network\_test* except that it takes a single subtracted neural network instead of two neural networks. It's output is also identical to *delta\_network\_test*.

### ReluVal-for-comparison/scripts
This directory contains scripts for running ReluVal's experiments as described in our paper. They are identical to ReluDiff's experimental scripts.

## DeepPoly
### eran/tf\_verify/diff\_analysis.py
This is the main entry script for running the DeepPoly experiments described in the paper. It takes a single argument indicating which of the four experiments to run.
```console
# from the eran/tf_verify directory
python3 diff_analysis.py [acas|mnist-global|mnist-3pixel|har]
```
For each property it tries to verify, the script will output a line beginning with "Result: " followed by triple of floating points. The first float is the time taken to perform the verification. The next two floats are the upper and lower bound of the target output neuron. The next line will either be "Failed" or "Verified" indicating the verification result. Note that "Failed" means that the result was inconclusive.

### eran/tf\_verify/diff\_analysis\_artifact.py
This is the main entry script for running our artifact experiments. It's usage and output is identical to the above, however it only runs a small subset of the experiements.

# Running the Experiments
Here we document how to re-run our experiments.
## Compile the Code
Both ReluDiff and ReluVal can be compiled either with or without multi-threading. If you want multithreading, you will need to specify how many threads. In the evaluation of our paper, we configured 10 threads, so if you want to reproduce our experiments, you should compile both ReluDiff and ReluVal as such.

To compile without threads, run:
```console
# from DiffNN-code/ or ReluVal-for-comparison/
make clean all
```

To compile in multi-threaded mode, run:
```console
# from DiffNN-code/ or ReluVal-for-comparison/
CFLAGS+=-DMAX_THREAD=10 make clean all
```
Replace 10 with the desired number of threads.

## Generate the Compressed Networks
```console
# from DiffNN-Code/
bash scripts/make_all_compressed_nnets.sh
```

## Run the experiments
### Artifact Experiments
We provide scripts that run a few  of our main experiments for demonstration purposes. These scripts will write the output directly to the screen. The experiments they run are (in order):
- ACAS property 6
- A single MNIST image globally perturbed on the 3x100 network
- A single MNIST image 3 pixel perturbed on the 3x100 network
- A single HAR input globally perturbed on the HAR network
```console
# from DiffNN-Code/ or ReluVal-for-comparison/
bash scripts/run_ACAS_artifact.sh
bash scripts/run_MNIST-global_artifact.sh
bash scripts/run_MNIST-3pix_artifact.sh
bash scripts/run_HAR_artifact.sh
```
ReluDiff should be able to verify all of these very quickly. ReluVal should finish ACAS and the MNIST 3 pixel, however it will take more than 30 minutes for the MNIST global, and it will throw a segmentation fault on HAR due to unbounded recursion.

```console
# from eran/tf_verify
python3 diff_analysis_artifact.py acas
python3 diff_analysis_artifact.py mnist-global
python3 diff_analysis_artifact.py mnist-3pixel
python3 diff_analysis_artifact.py har
```
DeepPoly should fail to verify all of the properties except the MNIST 3 pixel.

### Full Experiments
We also provide the scripts to re-run our full experiments. They will output the results to seperate log files beginning with *exec-time\_out*.
```console
# from DiffNN-Code/ or ReluVal-for-comparison/
bash scripts/run_ACAS_exec-time_experiments.sh
bash scripts/run_MNIST-global_exec-time_experiments.sh
bash scripts/run_MNIST-3pix_exec-time_experiments.sh
bash scripts/run_HAR_exec-time_experiments.sh
```

```console
# from eran/tf_verify
python3 diff_analysis.py acas
python3 diff_analysis.py mnist-global
python3 diff_analysis.py mnist-3pixel
python3 diff_analysis.py har
```
