Android app testing# Artifact evaluation for ComboDroid

## Overview

ComboDroid is a prototype tool to generate effective test inputs for Android apps.
we introduce its basic usage,
how to use it to reproduce the evaluation results in the paper,
and how to reuse it for further Android app testing.

## Obtain the artifact

We have upload a ova file of a virtual machine containing all necessary files and subjects.
[HERE](https://github.com/skull591/ComboDroid-Artifact.git)

The ova file should be imported in VirtualBox of version 6.1.2 or later, 
which supports nested virtualization. 

Please follow the instructions in `INSTALL.md` to complete the installation.

## Reproduce results in the paper

Since two testing scenarios are presented in the paper,
we introduce steps to reproduce the results, respectively.

### Running Alpha variant of ComboDroid

In the `/home/combodroid` directory, run

```bash
./runComboDroid SUBJECT alpha 
```

where *SUBJECT* is an integer in [1,17] representing a test subject used in our evaluation<sup>1</sup>. 
The order of subjects is the same as the one in Table 1 of our paper.

The statement coverage result will be in the file `/home/workspace/result_SUBJECT_alpha_TIMESTAMP/Coverage.xml`.

### Running Beta variant of ComboDroid

In the `/home/combodroid` directory, run

```bash
./runComboDroid SUBJECT beta 
```

where *SUBJECT* is an integer in [1,17] representing a test subject used in our evaluation<sup>1</sup>. The order of subjects is the same as the one in Table of in our paper.

The statement coverage result will be in the file `/home/workspace/result_SUBJECT_beta_TIMESTAMP/Coverage.xml`.

<sup>1</sup> Due to the recent update of GitHub, its account authorization page no longer supports the browser of Android 6.0, and this makes it impossible to test most of the functionalities of PocketHub [#8] by ComboDroid's current implementation. We plan to deal with this in the short future.
