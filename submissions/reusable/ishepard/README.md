# Primers or Reminders? The Effects of Existing Review Comments on Code Review

In this document, we describe the replication package of the paper "Primers or Reminders? The Effects of Existing Review Comments on Code Review" accepted at _ICSE 2020: the 42nd International Conference on Software Engineering_.


## Download 
The replication package can be downloaded at this URL: [https://doi.org/10.5281/zenodo.3676517](https://doi.org/10.5281/zenodo.3676517)

## What to reproduce
Ours is an online controlled experiment: Each participant participated to our experiment using an online platform that we devised; we provide all the logs that the platform collected for all the participants. Using these logs, the analyzer, and the R script, the results reported in the paper can be fully reproduced.

Given that our modified online platform for the code review experiment is publicly available in our replication package, other researchers can easily reuse it to replicate our study in future work.

## Reproducing the paper's results

### Contents Of The Replication Package
The replication package contains 4 directories:

1. **experiment-tool/**: the tool we used to perform the controlled experiment. It is based on [CRExperiment](https://github.com/ishepard/CRExperiment), a system that the first author created. Inside the directory you can find a `README.md` file with the instructions on how to run it.
2. **result-analyzer/**: contains (1) `analyzer.py`, the tool we used to parse the logs and create the final CSV file, and (2) `regression.R`, the R script we used to load the CSV file and perform some statistical analysis.
3. **logs/**: all the logs of the participants. There are 257 logs.
4. **code patches**: the 2 code patches we used in the experiment. Inside each code patch, you can find the version with and without the manually inserted bugs. 

### How To Reproduce The Results

To reproduce the results we do not run the experiment tool (this is only provided for future replications and repurposing), rather we use the provided logs of our users.

First, we have to parse the logs. To this aim, we need to go inside the directory `result-analyzer/` and run the script `analyzer.py` with python:

```
$ cd replication-package/
$ cd result-analyzer/
$ python3 analyzer.py
Finished parsing 257 logs. Total number of users that completed the review experiment: 92
```

This command will generate two files: `comments.txt` and `results.csv`. In the same folder, you see two files with similar names: `comments-as_expected.txt` and `results-as_expected.csv`. If the script run correctly, there should be no difference between the files that you generated and the "`-as_expected`" versions (you can check this running `diff comments.txt comments-as_expected.txt` in Linux/Mac).

The `comments.txt` file contains all the code review comments that the participants made during the experiment. The `results.csv` file contains all the logs of the participants in CSV format (the CSV only contains the result of 92 participants: this because we only considered participants that completed the code review in further analyses).

### Data analysis with R

Once the `results.csv` file is generated, we run the analysis with R, which is stored in the `regression.R` script file.

Our recommendation is to use [RStudio](https://en.wikipedia.org/wiki/RStudio) for opening and inspecting the file (we commented every meaningful line, hence it should be quite straightforward to understand what we are doing). However, it is also possible to directly run the file as in the following and just obtain the output (models are printed to the console and figures are saved as a single PDF file named: `distribution.pdf`, which should match the `expected-distribution.pdf` already in the folder):

```
$ cd result-analyzer/
$ Rscript regression.R
```

The `regression.R` script also installs any required package dependency in an automatic fashion.

After having run the entire `regression.R` script, you should have been able to replicate all the results of the paper.
