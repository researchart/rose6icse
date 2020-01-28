
## Running the Python Jupyter Notebook container

### Installation

After installing Docker (following the [instructions](https://docs.docker.com/v17.12/install/)), run the following command in a terminal:

```docker run -p 8888:8888 cmustrudel/oss-donations:jupyter```

If all goes well, the terminal output should look like this (note, the download only happens once; Docker will store the image locally afterward):

```
Executing the command: jupyter notebook
...
    To access the notebook, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/nbserver-6-open.html
    Or copy and paste one of these URLs:
    ...
    or http://127.0.0.1:8888/?token=...
...
```

Copy the URL with the token into a browser window.

### Reproducing the results in the paper

Within the Jupyter server, the actual notebooks are located in `oss-donations/src/jupyter_notebooks`. Click on either file to open.

There are 4 notebooks in total, and they can be executed cell-by-cell with the Shift + Enter keyboard command. All cells can also be executed at once by selecting `Cell -> Run All` from the top navigation bar. The notebooks include

- `funding_adoption_over_time.ipynb`: generate Figure 1 in paper
- `quantify_saver_vs_spender.ipynb`: quantify the number of open-source projects that save or spend a majority of their money
- `saver_spender_examples.ipynb`: generate Figures 5a and 5b in paper
- `types_of_expenses.ipynb`: generate Figure 6 in paper


## Running the RStudio container

### Installation

After installing Docker (following the [instructions](https://docs.docker.com/v17.12/install/)), choose a password for the RStudio server user account (replace `<your-password-here>` by your chosen password) and run the following command in a terminal:

```docker run -e PASSWORD=<your-password-here> -p 8787:8787 cmustrudel/oss-donations:rstudio-regression```

If all goes well, the terminal output should look like this (note, the download only happens once; Docker will store the image locally afterward):

```
Unable to find image 'cmustrudel/oss-donations:rstudio-regression' locally
rstudio-regression: Pulling from cmustrudel/oss-donations
16ea0e8c8879: Pull complete 
7ce39da2c1e2: Pull complete 
e7408bd3a47d: Pull complete 
...
[cont-init.d] done.
[services.d] starting services
[services.d] done.
```

Leave the terminal open and start a brower window pointing to `http://localhost:8787`. Log in using `rstudio` as user and the password you chose earlier. The editor should open with the `donations.Rmd` file.


### Reproducing the results in the paper

The R markdown file reproduces all the regression modeling and time series analysis results in the paper (Figures 3 and 4, and Tables 1, 2, and 3), plus some additional related analyses we did not report in the paper. Overall, you can find (1) a census of donation requests on GitHub, (2) an analysis of observable characteristics of projects requesting and receiving donations, and (3) a time-series analysis of donations' effects on project activity.

To see all these analyses, within RStudio open in the `donations.Rmd` file, press the "Knit - Knit to HTML" button and wait for an output HTML notebook-style file to be created and displayed (if you get a "popup blocked" message, press "Try again").

As a sanity check, compare the bar plots in Section 2 ("Census") of the HTML file to those in Figure 3 in the paper -- they should be identical.

#### Correspondence between the output HTML and the paper

- HTML Section 3 (Which projects ask for donations within npm?) subsection 3.1 (Compare to random projects) maps to Table 1 (Characteristics of npm projects asking for donations) in the paper.
- HTML Section 5 (Which projects get donations?) subsection 5.1 (Within npm) maps to Table 2 (Characteristics of npm projects receiving donations via Patreon and OpenCollective) in the paper.
- HTML Section 6 (How do project metrics change with funding?) subsection 6.1 (Number of commits) maps to the left-hand side of Table 3 (Commits model) in the paper.
- HTML Section 6 (How do project metrics change with funding?) subsection 6.3 (Issue closing speed) maps to the right-hand side of Table 3 (Issue speed model) in the paper.

Note: some additional manual steps needed to generate the exact format of the tables in the paper are missing from the container.
