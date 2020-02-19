# Primers or Reminders? The Effects of Existing Review Comments on Code Review

In this document, we describe the replication package of the paper "Primers or Reminders? The Effects of Existing Review Comments on Code Review" accepted at _ICSE 2020: the 42nd International Conference on Software Engineering_.


## Download 
The replication package can be downloaded at this URL: [https://doi.org/10.5281/zenodo.3628187](https://doi.org/10.5281/zenodo.3628187)

## What to reproduce
Ours is an online controlled experiment: Each participant participated to our experiment using an online platform that we devised; we provide all the logs that the platform collected for all the participants. Using these logs, the analyzer, and the R script, the results reported in the paper can be fully reproduced.

Given that our modified online platform for the code review experiment is publicly available in our replication package, other researchers can easily reuse it to replicate our study in future work.

## Reproducing the paper's results

### Contents Of The Replication Package
The replication package contains 3 directories:

1. **experiment-tool/**: the tool we used to perform the controlled experiment. It is based on [CRExperiment](https://github.com/ishepard/CRExperiment), a system that the first author created. Inside the directory you can find a `README.md` file with the instructions on how to run it.
2. **result-analyzer/**: contains (1) `analyzer.py`, the tool we used to parse the logs and create the final CSV file, and (2) `regression.R`, the R script we used to load the CSV file and perform some statistical analysis.
3. **logs/**: all the logs of the participants. There are 257 logs.

### How To Reproduce The Results

To reproduce the results we do not run the experiment tool (this is only provided for future replications and repurposing), rather we use the provided logs of our users.

First, we have to parse the logs. To this aim, we need to go inside the directory `result-analyzer/` and run the script `analyzer.py` with python:

```
$ python3 analyzer.py
```

This command will generate two files: `comments.txt` and `results.csv`. In the same folder, you see two files with similar names: `comments-as_expected.txt` and `results-as_expected.csv`. If the script run correctly, there should be no difference between the files that you generated and the "`-as_expected`" versions (you can check this running `diff comments.txt comments-as_expected.txt` in Linux/Mac).

The `comments.txt` file contains all the code review comments that the participants made during the experiment. The `results.csv` file contains all the logs of the participants in CSV format (the CSV only contains the result of 92 participants: this because we only considered participants that completed the code review in further analyses).

Once the `results.csv` file is generated, we can run the R script `regression.R`. The script is documented extensively: we explain the purpose of each line. For example, with the following we reduce the number of considered participants from 92 to 85, by filtering on the minimum number of remarks:

```
# We only consider reviews in which there is at least 1 comment.
# This command excludes 7 participants.
results <- results %>% filter(Number.of.Comments > 0)
```

After having run the entire `regression.R` script, you should have been able to replicate all the results of the paper.
