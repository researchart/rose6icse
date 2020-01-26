# Installation

- We uploaded a snapshot of the tool with required 3rd-party libraries in [Zenodo](https://zenodo.org/record/3627640). Simply unzip the contents somewhere; we will refer to this location as `installation path`.
- For future updates, please check out the [homepage](https://github.com/shafiul/slemi) (advanced users only; not required for ICSE 2020 artifacts evaluation).

# Basic Usage

Please watch the 5-minute video demo from the [README.md](README.md) file before using the tool!

## Pre-processing and Analyzing

Here, we will pre-process some Simulink models as this is the first step before performing any actual EMI-based mutation. For convenience, we have provided a small corpus with some Simulink models (i.e. `seeds`) along with the pre-processed versions (which have `_pp` suffix) and cached analysis results.

- Copy the `reproduce/samplecorpus` directory somewhere in your filesystem, and set this path to two environment variables: `COVEXPEXPLORE` and `SLSFCORPUS`. Models from this corpus will be used for pre-processing and eventually generating mutants.
- **WARNING:** Environment variables must be updated before opening MATLAB. If MATLAB is already open before changing the environment variables, please restart MATLAB.
- Open MATLAB, navigate to the `installation path` and execute `covexp.covcollect()` in the MATLAB command-prompt.

Your output will look like:

```
>> covexp.covcollect()
BaseCovExp.BaseCovExp 2020-01-25 11:28:23,833 INFO     Calling BaseCovExp constructor
ExploreCovExp.generate_model_list 2020-01-25 11:28:23,938 INFO     Generating model list from THE_PATH_WHERE_YOU_COPIED_SAMPLE_CORPUS
ExploreCovExp.generate_model_list 2020-01-25 11:28:24,733 INFO     Generated list of 3 models
BaseCovExp.do_analysis 2020-01-25 11:28:24,785 INFO     Loading Simulink...
```


For complete documentation please check out: 

- The [covcfg.m](https://github.com/shafiul/slemi/blob/master/covcfg.m) configuration file itself which is well-documented.
- The [+covexp/Readme.md](https://github.com/shafiul/slemi/tree/master/%2Bcovexp) file. 


Once the script completes, you'll see overview of the experiment and a boxplot in a GUI depicting availability of zombie blocks in the model.

## Generating Mutants

After running the pre-processing phase, execute `emi.go` in the MATLAB command prompt to generate some mutants!
Currently the EMI-generation configuaration (`+emi/cfg.m`) would only create one mutant from a randomly chosen seed in our corpus. Check out the video demo and the configuration file to learn which mutation strategies would be applied and additional details.

For complete documentation please check out:

- The [+emi/cfg.m](https://github.com/shafiul/slemi/blob/master/%2Bemi/cfg.m) configuration file itself which is well documented.
- The [+emi/Readme.md](https://github.com/shafiul/slemi/tree/master/%2Bemi) file.

### Reports

- Upon completion, each of the commands introduced above will present an overview of the experiment (e.g., result of differential testing). You can also manually run `covexp.addpaths(); emi.report()` in the MATLAB command-prompt to get detailed report.

- Where are my mutants? They are saved in the `emi_results` directory, go ahead and open a generated mutant in MATLAB! Mutants have `seedmodel_1_1` suffix (the numbers after the underscore are some unique identifiers). 
- You can also open the seed model from the `sample corpus` to inspect manually. 