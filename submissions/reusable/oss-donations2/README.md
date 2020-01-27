# oss-donations
This is the
complete replication package for an empirical study of donations in open source. A pre-print of the paper, "How to Not Get Rich: An Empirical Study of Donations in Open Source" can be found [here](icse20donations.pdf).

## Artifact Description
This artifact contains
* [R scripts](https://github.com/CMUSTRUDEL/oss-donations/tree/master/src/statistical_analysis)
* and [Jupyter notebooks](https://github.com/CMUSTRUDEL/oss-donations/tree/master/src/jupyter_notebooks).

Both parts are needed to reproduce the results and figures within the paper.

## Requirements
### R
Make sure R and RStudio are installed. We used R version 3.5.1 and RStudio version 1.1.463.

We require the following dependencies: `readr, pscl, car, ggplot2, sqldf, lmerTest, MuMIn, texreg, xtable, effects`.

It may be necessary to change the Pandoc environment variable in [`make.R`](https://github.com/CMUSTRUDEL/oss-donations/blob/master/src/statistical_analysis/make.R). The required path can be found by running `Sys.getenv("RSTUDIO_PANDOC")` in RStudio.

### Python
Make sure you have Python version 3.3 or greater. We used Python version 3.6.8.

The following packages need to be installed:
* Jupyter Software: installation instructions can be found [here](https://jupyter.org/install)
* Pandas: `python -m pip install pandas`
* NumPy: `python -m pip install numpy`  
* Seaborn: `python -m pip install seaborn`
* Matplotlib: `python -m pip install matplotlib`

### Cloning the Repository
Clone the repository with `git clone https://github.com/CMUSTRUDEL/oss-donations.git`.

## Reproducing Paper Results
### R
The R scripts are located in `src/statistical_analysis`. An HTML file with (1) a census of donation requests on GitHub, (2) an analysis of observable characteristics of projects requesting and receiving donations, and (3) a time-series analysis of donations' effects on project activity can be generated in two ways.

#### Generate using make
You can run `make` in a terminal after navigating to `src/statistical_analysis` to generate `donations.html`.

#### Generate from R
You can also run `make.R` directly from R by setting the working directory to the `src/statistical_analysis` within the GitHub repository with `setwd('/path')` and running `source('make.R')`. These commands can be inputted within the RStudio console.

### Python
The Jupyter notebooks are located in `src/jupyter_notebooks`. The notebooks can be opened by typing `jupyter notebook` in a terminal/command prompt, navigating to the correct folder, and selecting the `.ipynb` file to open.

There are 4 notebooks in total, and they can be executed cell-by-cell with the Shift + Enter keyboard command. All cells can also be executed at once by selecting `Cell -> Run All` from the top navigation bar. The notebooks include
* `funding_adoption_over_time.ipynb`: generate Figure 1 in paper
* `quantify_saver_vs_spender.ipynb`: quantify the number of open-source projects that save or spend a majority of their money
* `saver_spender_examples.ipynb`: generate Figures 5a and 5b in paper
* `types_of_expenses.ipynb`: generate Figure 6 in paper
