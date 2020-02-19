# CPC

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3660028.svg)](https://doi.org/10.5281/zenodo.3660028)

## Start

1. Use ubuntu 16.04, 64bit version or ubuntu 18.04, 64bit version
2. Install [Docker](https://www.docker.com)

   ```bash
   curl -fsSL https://get.docker.com/rootless | sh
   ```

   The script will show the environment variables that are needed to be set.

3. Pull our image

   ```bash
   docker pull xiangzhex/cpc:release
   ```

4. start the container

   ```bash
   systemctl --user start docker
   docker run -ti xiangzhex/cpc:release zsh
   ```

5. Now you're in the container. Enter the following commands to get the result

   ```bash
   cd ~
   ./start.sh
   ```

The script will run for around 2 hours. If everything goes well, the results are stored in the directory `~/result`.

## how to interpret the results

### Table4

#### What and Property

The `property` and `what` parts of table4 has been printed out at the end of the script. You can also `cd` to the `CPC-what-property` directory and run `python2 table4.py` in that directory.

We've improved the distance model and the system a bit, so the results are expected to be slightly better than that in our paper.

##### Output sample

Take the following output as an example. `zero` means this table is the statistics for the propagated comments whose distance to the existing comments are zero. Similarly, `<0.5` and `>=0.5` means the distance are less than 0.5 and larger than or equal to 0.5, respectively. Also, the label `number` means all the comments regardless of the distance.

`category` means the category of comments. This script only generates statistics for `property` and `what`.

`source` means the projects where the propagated comments come from.

```
                         zero
category source
property apacheDB-trunk   844
         collections     1373
what     apacheDB-trunk   178
         collections      115
```

#### How

The output of `how` propagation are excel files. We manually count the statistics of `how`.

### Table 6

The `#N` columns of table 6 are calculated from table 4.
(For each project and category, `#N` = `#pc` - (`#cmt dist=0` + `#cmt dist<0.5` + `#cmt dist>=0.5`)

Other tables are not directly related to the artifact.

## About

This artifact is a prototype of the idea conveyed in the CPC paper. We propagate comments based on rules abstracted from the syntax of the Java programming language. This project implements Method-level propagation rules.

We provide all the source code and a pre-configured Docker image with necessary scripts for reproducing the results presented in the paper. Besides that, even though the configuration is tedious, we'll still provide a brief instruction about how to configure it.

## Configure the project manually

1. Clone our [code](https://github.com/XZ-X/CPC-artifact-release/tree/master/submissions/available/CPC)
1. `python2`, `tensorflow`, `keras`, `gensim`, `numpy`, `nltk`, `pandas`, `xlwt`, `jdk-8` and `maven` are required.

2. Clone [wmd4j](https://github.com/crtomirmajer/wmd4j)
3. `cd` to `wmd4j` and run `mvn install`
4. run `getData.sh` to download other data and dependencies. (We tried to upload these but failed due to the file size limitation of Github).
5. run the following commands in the `CPC` directory.

    ```bash
    cd CPC-what-property
    ./run.sh
    cd ..
    cd how-it-is-done
    ./propagate.sh
    cd ..
    mkdir -p result
    cp CPC-what-property/n_distance_uniq.csv result/property-what.csv
    cp how-it-is-done/*.xlsx result/
    ```
