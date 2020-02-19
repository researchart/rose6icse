# README

This document describes the artifact for the accepted version of the paper
"Tailoring Programs for Static Analysis via Program Transformation". It
comprises:

- A VM image containing our tooling, scripts, and data for reproducing major experiments that do not require a large amount of computational power or space.
- A description of limitations in the experimental procedure and data where the VM is not viable.
- Extensive documentation for `Comby`, the core tooling behind our approach.

The key idea in our paper is to perform syntactic program transformation using declarative templates to avoid certain classes of static analyzer false positives. The core tooling that enables our approach is `Comby`. `Comby` is [available](https://github.com/comby-tools/comby) and [extensively documented](https://comby.dev) for general-purpose program rewriting. For our paper's specific experiments using `Comby`, we have put together a VM with required dependencies and static analyzers already installed, so that experiments can be easily run with one-liner commands.

## VM requirements and setup

See [INSTALL.md](INSTALL.md).

## Running experiments on the VM

We include experiments to reproduce the majority of results in **Table 1** (see [VM
limitations](#vm-limitations) for an explanation of all results). **Table 1** is
our main result table showing that transformations help avoid false positive
errors in static analyzers.

We include three scripts, corresponding to our results using three analyzers.
The output of the scripts correspond to the rows of data in **Table 1**.

### PHPStan

The experiment for the first 6 rows in the table for `PHPStan` can be produced by running:

`./php-run.sh`

which is in the default directory of the VM `/home/vagrant`.

**How to interpret the output**

We have included a sample output of this script in `php-expect.txt` in the default directory `/home/vagrant`. The format starts with:

```
##### <pattern name corresponding to Column Pattern> <Project> #####
<commit hash of project>
-=-=-= Expect: FP -=-=-=-
<time data>
 [ERROR] Found XXX errors
```

Where `XXX` errors will be reported by the analyzer for this project, corresponding to **Bef** in the table. After this segment, you'll see:

```
=-=-=-=- Transforming -=-=-=-=
Templates: <descriptive names of templates>
{ 
number_of_files: ..
lines_of_code: ...
number_of_matches: ...
total_time: ...
}
```

which describes the statistics of running the experiment and `number_of_matches` corresponding to **#R** and `total_time` to **Time Rewr** data in **Table 1**. After this segment, you'll see:

```
-=-=-= Expect: NO FP -=-=-=-
<time data>
 [ERROR] Found YYY errors
############################
```

where `YYY` errors is the number of analyzer errors after the transformation is performed. **Delta FP** in **Table 1** corresponds to the number of total errors before transformation, minus the number of errors after transformation: `XXX - YYY`. The value of **Cls** was determined by manually looking through error reports.

One row of data is contained between the starting banner `### <description ###` and ending banner `########`. The above format repeats for each row of the PHP data in the table.

**Note:** it is expected that performance and analysis times will vary to those reported in the paper, due to running on different hardware.

**Note:** there is a small discrepancy for the values in row 2, **Table 1**. We report 38 errors removed, whereas the value in the experiment on the VM removes 42 errors. Thus, we actually remove more errors, i.e., do better in the experiments than originally reported in the paper. This value will be corrected in the camera ready.

### Infer

We include the experiment for row 8 in the table for `Infer`. Rows 7, 9, and 10
are excluded due to size constraints (see [VM limitations](#vm-limitations)).

You must ensure that **Java 8** is the system Java version before running this experiment (it is 8 by default). If the Java version is changed (for example, by running experiments for [Spotbugs](#spotbugs)) change it back to Java 8 like so:

```
sudo update-alternatives --config javac
# then type "3" and press enter
sudo update-alternatives --config java
# then type "3" and press enter
```

Then run the script as follows:

`./infer-run.sh`

which is in the default directory of the VM `/home/vagrant`.

**How to interpret the output**

We have included a sample output of this script in `infer-expect.txt` in the default directory `/home/vagrant`. The format is essentially the same as the output for `./php-run.sh`, with the following differences:

The `Exepct FP` error message will read : `... error: RESOURCE_LEAK: 1` before `Transforming`, and will be blank after `Transforming` (the error is removed). The error reports corresponding to **Bef** and **Cls** can be found in `/tmp/drift-bugs-infer-before.txt` and `/tmp/drif-bugs-infer-after.txt`.

### Spotbugs

We include the experiment for rows 11 and 12 in the table for `SpotBugs`. 

You must ensure that **Java 11** is the system Java version before running this
experiment (it is 8 by default). Change it like so:

```
sudo update-alternatives --config javac
# then type "1" and press enter
sudo update-alternatives --config java
# then type "1" and press enter
```

Then run the script as follows:

`./spotbugs-run.sh`

which is in the default directory of the VM `/home/vagrant`.

**How to interpret the output**

We have included a sample output of this script in `spotbugs-expect.txt` in the
default directory `/home/vagrant`. The format is essentially the same as the
output for `./php-run.sh`, with the following differences:

For the first case, the `Expect: FP` error message will read `[ERROR] Nullcheck
of ....` before `Transforming`, and will read `[INFO] BUILD SUCCESS` after.
There is only one error, and the transformation removes it, and leads to a
successful build.

For the second case, the number of errors reported by the analysis are found
under `-=-=- errors detected -=-=-` in the Before/After states, respectively
(there are 2 before, 0 after).

### Customizing

The VM is appropriate for reusing the existing static analysis tooling,
scripts, and templates. If you are interested in customizing values, please see how the
scripts are executed inside, e.g., `./php-run.sh`, and the
`/home/vagrant/MetamorphicAnalysis/VM/projects/{scripts,templates}`
directories.

## VM limitations and remaining data and experiments

The VM excludes rows in **Table 1** where data and tooling of the experiments that are simply infeasible to include due to requiring a large amount of space or computational power, or difficulty replicating the setup for large scale experiments. We mention in our paper that we ran large projects >100KLOC on a 20 core machine (L657), and this poses limitations on what can be feasibly accomplished through a VM. For completeness, we document the limitations that stop us from including the rest of the data/experimental setup in the VM.

- Omitted rows 7, 9, 10, 13, **Table 1**: These projects are large and/or have a long analyzer runtime and were run on a large server instance.

- Omitted rows 14, 15, **Table 1**: CodeSonar is proprietary software that we evaluated on using an academic license, and are not at liberty to share.

- **Table 2**: The data to reproduce this table is >35GB. Because the VM is already large at 28GB (accounting for the system, tools, and data for [running the majority of our experiments](#running-experiments-on-the-vm)), the VM does not include this data. Note that these experiments were run on a 20 core machine and may take considerably longer otherwise, and not generally viable for a VM set up.

- **Table 3**: Each entry has a corresponding issue tracker (the values in the **Ref** column in **Table 1** are hyperlinked in the PDF and can be clicked). Each entry was manually checked and entered.
