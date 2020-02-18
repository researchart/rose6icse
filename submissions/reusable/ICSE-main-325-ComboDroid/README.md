# Artifact evaluation for ComboDroid

## DOI of repositories

Source code repository: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3666313.svg)](https://doi.org/10.5281/zenodo.3666313)

Virtual machine repository: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3673079.svg)](https://doi.org/10.5281/zenodo.3673079)

## Overview

ComboDroid is a prototype tool to generate effective test inputs for Android apps.
we introduce its basic usage,
how to use it to reproduce the evaluation results in the paper,
and how to reuse it for additional purposes.

## Obtain the artifact

We have uploaded the source code of ComboDroid to Zenodo:  [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3666313.svg)](https://doi.org/10.5281/zenodo.3666313).
Moreover, to ease the reuse and reproduction, we also upload an ova file of a virtual machine containing the pre-built artifact, all test subjects used in our experiments, and all required dependencies to Zenodo:  [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3673079.svg)](https://doi.org/10.5281/zenodo.3673079)

Please follow the instructions in `INSTALL.md` to complete the installation.

## Basic usage

The basic usage of ComboDroid is explained in detail in the `INSTALL.md` file.

## Reproduce results in the paper

The results can be reproduced within our provided virtual machine.
Since two testing scenarios are presented in the paper,
we introduce steps to reproduce the results, respectively.
The `INSTALL.md` file also contains detailed instructions.

### Running Alpha variant of ComboDroid

In the `/home/combodroid` directory, run

```bash
./runComboDroid SUBJECT alpha 
```

where *SUBJECT* is an integer in [1,17] representing a test subject used in our evaluation.
The order of subjects is the same as the one in Table 1 of our paper.

The statement coverage result will be in the file `/home/workspace/result_SUBJECT_alpha_TIMESTAMP/Coverage.xml`.

### Running Beta variant of ComboDroid

In the `/home/combodroid` directory, run

```bash
./runComboDroid SUBJECT beta 
```

where *SUBJECT* is an integer in [1,17] representing a test subject used in our evaluation. 
The order of subjects is the same as the one in Table 1 in our paper.

The statement coverage result will be in the file `/home/workspace/result_SUBJECT_beta_TIMESTAMP/Coverage.xml`.

## Reuse ComboDroid for further Android app testing research

ComboDroid is well structured with many functionalities that can be reused for other activities.
We name a few and describe them in detail.

### Testing other Android apps.

Naturally, besides test subjects we used for evaluation, ComboDroid can be used to generate test inputs and test other Android apps.

In `INSTALL.md` file we describe in-depth how to do so.

### Reuse of generated combos

In the execution log of ComboDorid, we record all generated combos, which are long, and meaningful test inputs.
Such inputs can explore functionalities of Android apps hidden deep, or/and exercise complex combinations of such functionalities, and thus can be reused for other testing or analyzing purposes.

Currently, the combos are recorded in a format that can be translated into monkey events by ComboDroid.
In the short future, we plan to add an interface to ComboDroid to support combo replaying, further enhancing its reusability.

### Reuse of startup scripts and manual inputs

As described in the paper and the `INSTALL.md` file, ComboDroid records manually provided inputs and startup scripts.
To ease the reusability of these inputs and scripts, ComboDroid records them in the combination of GUI layout XML files, and sequence of adb command (for GUI events, they are recorded in `adb shell input` commands, and for system events, they are `adb shell` command).
For each event the tester sends, ComboDroid records the current GUI layout of the app, the event in the form of adb command, and the time of the clock of the Android device (in milliseconds) when receiving the event.
The format is well organized and self-explaintory and can be reused for other purposes.
Therefore, ComboDroid can serve as a recording tool.

To achieve so, one can run the **beta_record** variant of ComboDroid. 
The startup script will be stored in the `startup.txt` file at the working directory,
 and the recorded traces will be stored in the `trace` directory at the working directory.
 
 ### Reuse of the instrumented apk file
 
 ComboDroid instruments the apk file to get API call trace during the execution.
 Such an instrumented apk file is stored in the specified directory and can be reused for other activities concerning execution trace analysis.
 
Currently, ComboDroid instruments the apk file to log API calls through the Android logging system.
For each API call that is likely to access shared resources, such as database or network, a log in the following format will be printed in the `info` channel of the logging system:
- The log tag is `ComboDroid.TAG`;
- The message is in the form of `CALLER_FULL_CLASS_PATH.CALLER_METHOD_NAME->CALLEE_FULL_CLASS_PATH.CALLEE_METHOD_NAME#ID TYPE_OF_ACCESS`
where
    * `ID` is a unique identifier of this API call, and
    * `TYPE_OF_ACCESS` specifies the type of the accessed resource and how it is accessed, which can be
        - `network access`: this API call is likely to contribute to a network resource accessing;
        - `database read`: this API call is likely to contribute to a database reading;
        - `database write`: this API call is likely to contribute to a database writing;
        - `shared preference read`: this API call is likely to contribute to a shared preference reading;
        - `shared preference write`: this API call is likely to contribute to a shared preference writing;
        - `local read`: this API call is likely to contribute to a local variable reading; and
        - `local write`: this API call is likely to contribute to a local variable writing.

For the local variables accessing, please refer to our paper to see how it is identified.

Furthermore, for standard APIs provided by the Android system to access database and shared preference, 
logs recording the corresponding arguments used to call them are also logged in the following format:
- The log tag is `ComboDroid.TAG-CALLEE_FULL_CLASS_PATH.CALLEE_METHOD_NAME#ID`; and
- The message of each log is one of the arguments.

The arguments are logged in the same order as the one they are specified.
