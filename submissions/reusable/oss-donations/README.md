# OSS Donations
These installation instructions accompany the replication package for the ICSE 2020 paper 
"How to Not Get Rich: An Empirical Study of Donations in Open Source" 
([preprint here](icse20donations.pdf)) 
by Cassandra Overney, Jens Meinicke, Christian Kästner, and Bogdan Vasilescu.

```
Cassandra Overney, Jens Meinicke, Christian Kästner, Bogdan Vasilescu. 2020. 
How to Not Get Rich: An Empirical Study of Donations in Open Source. 
In Proceedings of 42nd International Conference on Software Engineering, 
Seoul, Republic of Korea, May 23–29, 2020 (ICSE ’20), 13 pages. DOI: 10.1145/3377811.3380410
```

## Artifact Overview

The artifact is organized in two publicly available [Docker](https://www.docker.com) containers (via Docker Hub), making it as easy as possible to interact with, without the need for complicated system setup.

The first container (`cmustrudel/oss-donations:jupyter`) starts a [Jupyter Notebook](https://jupyter.org) pre-loaded with the necessary packages and data. There are 4 notebook files inside the container, that reproduce Figures 1, 5, and 6 in the paper.

The second container (`cmustrudel/oss-donations:rstudio-regression`) starts [RStudio](https://rstudio.com/products/rstudio/) pre-loaded with the necessary packages and data. The R script that loads inside the container on startup reproduces all the regression modeling and time series analysis results in the paper.


## Usage

See detailed instructions for how to access and use the artifact [here](INSTALL.md).
In a nutshell, you only need to install [Docker](https://docs.docker.com/v17.12/install/) and interact independently with either/both of the two Docker containers.


## Repository
The documentation explaining how to access and interact with the artifact is available in our [GitHub repository](https://github.com/CMUSTRUDEL/oss-donations), as well as here.


## License

The artifact is availble under [MIT License](LICENSE.md).