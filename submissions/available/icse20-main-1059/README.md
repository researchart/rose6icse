The artifact can be downloaded [here](https://docs.google.com/document/d/12G_h6recZ4nhAh6VllhnmoIKUoofmKPaAIcRJE9XJvY).
For installation instructions, see the [Install](INSTALL.md) document.
# ReadMe

This artifact was used to obtain the results that are presented in the paper.
It includes the lexical and syntactic *DDMax* algorithm, the *ddmin* algorithm, an ANTLR parser for our presented input formats and the test infrastructure that was used to obtain the results from the paper.

All our algorithms and infrastructure were implemented in a single `Java` program, it automatically generates the CSV files and `GNU Plot` data files to re-generate the tables and graphs from the paper.
To generate the plots from the paper, `GNU Plot` is needed, the GNU plot scripts are also provided with the artifact.

The basic usage of our program is shown below.

## Command-Line Arguments

### Usage

#### Replicate the results from the paper
Note: The results depend heavily on the test system - the system itself, the programs running in the background, etc. - The full test run of all 50 files takes a very long time.

The test directory (named `testfiles`) is expected to be located inside the working directory and expects the following folder structure:

```
working directory
|
|- testfiles
|  |
|  |- dot-invalid-mult
|  |- dot-invalid-single
|  |- dot-invalid-realworld
|  |- dot-valid
|  |- json-invalid-mult
|  |- json-invalid-single
|  |- json-invalid-realworld
|  |- json-valid
|  |- obj-invalid-mult
|  |- obj-invalid-single
|  |- obj-invalid-realworld
|  |- obj-valid
```

1. `cd` into the directory of the artifact that contains the jar file (`debug-inputs.jar`), which must also contain a folder named `testfiles` that contains the mutated files and the working original files. An appropriate folder containing test files from the evaluation is provided in the artifact. On the provided VM, this folder is `~/Artifact/`.
4. Run the program using the following command line arguments:
`java -jar debug-inputs.jar -R <n>`, replacing `<n>` with the number of test files that you want to run consecutively. If you run the program multiple times, the test results are merged automatically.
5. To generate the results files, i.e. the CSV files and GNU Plot files from the paper evaluation, run `java -jar debug-inputs.jar -S`. This will create the test results inside the `results` folder.

The program includes a command-line switch to filter out corrupted files in a directory of crawled files.
To run this filter, use `java -jar debug-inputs.jar -F -i <crawled-files-directory> -o <copy-to>`.
The program will automatically test every file in the `crawled-files-directory` and copy all corrupted files into the specified `copy-to` directory.
It also stores the reason why a file was rejected in `failinfo.json`.
The mutated and real-world corrupted files used in the paper's evaluation are already included, so you do not need to run this.

The execution of `-R` will take a very long time, so we recommend to use small values for `n`. On our test system, running the program with `-R 3` took about 1h30min in average.
On the VM, the tests will take even longer.
To speed things up, you might want to increase the CPU cores and speeds and the memory of the VM or run the tests on a physical machine.

If you run `-R n` multiple times, the test results are automatically merged, so running `-R 10` should give you the same results as running `-R 1` 10 times.

##### FAQ: I see "NaN" values in a table, what is wrong here?

If you see "NaN" in the `diagnostic_quality.csv` table, you might need to run more tests using `-R n`. 
Only real-world files are considered in the `disgnostic_quality.csv` table, so you need at least one real-world JSON file that passed `DDMax`.

#### Repair a file using a specific algorithm

To repair a single file using a single algorithm, you may run the following command line:

> `java -jar debug-inputs.jar -r -i <inputfile> [-o <outputdir>] -a <algorithm>`

A more detailled example on how to run this and how to examine the results is shown in the [Install](INSTALL.md) document.

`DDMin` may also be run on a file by specifying `ddmin` as algorithm.

#### Mutate all files in directory

The artifact includes the mutation driver that was used to mutate the files used in the evaluation.

For a list of mutation algorithms, see the CLI help text (`java -jar debug-inputs.jar --help`).

> `java -jar debug-inputs.jar -M -i <inputdir> -o <outputdir> [-t <times>] [-a <algorithm>]`

This will mutate all files in the input directory and store them to the output directory using `t` mutations.
If no algorithm is given with `-a`, a random mutation algorithm is used.

#### Run a subject program on a given file

> `java -jar debug-inputs.jar -O <subject> -i <inputfile> [-o <outputfile>]`

This will run a subject program with an input file and output whether the file has been accepted by the program.

#### Store the results in the results/ folder

> `java -jar debug-inputs.jar -S`

The paper evaluation contains the following files:

File Name | Content | Figure
:-----------------------------|:--------|:-------
`ddmax_effectiveness.csv`     | Number of repaired files for each algorithm            | Table 4
`ddmax_efficiency.csv`        | Run time and number of subject runs for each algorithm | Table 5
`diagnostic_quality.csv`      | Diagnostic quality of the DDMax algorithm              | Table 6
`all_data_recovery.dat`       | Recovered data in Bytes                                | Figure 8
`all_repairs.dat`             | Number of repaired files                               | Figure 7
`avg_runtime_per_file.dat`    | Average run time per file                              | Figure 13
`data_loss.dat`               | Average Data Loss                                      | Figure 12

### Arguments
Argument               | Description                           | Alternative
:--------------------|:--------------------------------------|-------------:
`-R <n>`               | Run all available algorithms on up to n files (or all files, if n <= 0) in the given directory. Save the results to the database and to an output folder, if specified. Automatically skips all files that have already been tested. | `--run`
`-r`                   | Repair a file and store the result to the given directory. | `--repair`
`-O <subject>`         | Run a subject program on the given file. | `--run-oracle`
`-i <inputfile>`       | Specify an input file or directory    | `--input-file`
`-o <outputfile>`      | Specify an output file or directory   | `--output-file`
`-a <algorithm>`       | Specify an algorithm                  | `--algorithm`
`-t <n>`               | Specify a maximum number of mutations. The default value is 1. | `--times`
`-M`                   | Mutate all files in the given directory. | `--mutate`
`-F`                   | Filter out all corrupted files from a set of crawled files | `--find-corrupted-files`
`-S`                   | Store the test results in the test results folder. | `--output-summary`
`-h`                   | Print help | `--help`
`-p <python executable>` | Set the path of the python executable used for Appleseed | `--python`
`-w <directory>`       | Set the directory that contains the working (unmutated) files. Must be set when using -r to save statistics. | `--working-directory`
`-T <timeouts>`        | Set the timeout per file in ms.     | `--timeouts`

For a list of all available algorithms and subjects, read the help page of the program.

## Subject Programs
Some subject programs are included inside the following folders inside the working directory of the program:

Path | Program
:----|:--------
`appleseed/bin/appleseed.cli` | Appleseed 1.9.0-Beta
`blender/blender` | Blender 2.79
`jq-linux64` | JQ 1.6-1

`Graphviz 2.40.1-14` is not included and must be installed on the system to be used as oracle.

All other subject programs are included as Java library inside the `lib/` folder.
