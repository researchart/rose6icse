# SLEMI

We present SLEMI - a novel open source tool to automatically find compiler bugs in Simulink, the widely used cyber-physical system development tool chain.

## Requirements

- Matlab with Simulink (version R2018a) with all default tollboxes
- Tested in Windows 10

## Installation

- Please see the [INSTALL.md](INSTALL.md) file

## Video Demo

- Checkout a 5-minute introductory [demo](https://www.youtube.com/watch?v=oliPgOLT6eY&feature=youtu.be) of the tool which presents the various tool components, and also covers basic configuration.

## Running SLEMI and Other Scripts

- Open MATLAB and navigate to the directory where you have installed the tool.

## Reproduce Results

### Runtime Analysis Evaluation

Following steps would help recreating the runtime analysis (RQ1 in the paper):

- Unzip the `reproduce/runtime-plot-data.zip` file and copy the `.mat` files to the `workdata` folder
- Run `covexp.addpaths(); covexp.r.scaling()` in a MATLAB prompt 

### Models Finding Bugs

The `reproduce/ModelFindingBugs.zip` file contains various Simulink models used to discover the bugs reported in the paper. We have included the models here so that interested readers can manually inspect the models.