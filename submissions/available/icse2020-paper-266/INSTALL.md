
# Artifact Installation

The main part of the artifact can be obtained from the pdepa github repository, with the following command:

```
git clone https://github.com/gzoumix/pdepa.git
```

## Installation and execution using Docker

`pdepa` with a valid execution environment is available in a Docker image,
available at [pdepa docker hub
repository](https://hub.docker.com/r/gzoumix/pdepa). The benchs presented in
this artifact's paper were produced with the `gzoumix/pdepa:icse2020` docker
image, which includes the March 1st 2019 version of portage and of the [default
gentoo repository](https://gitweb.gentoo.org/repo/gentoo.git/). `pdepa` can be
executed from all the machines running Docker. For example, checking if `cssh`
can be installed can be done by running the following command:
   
```
$ docker run gzoumix/pdepa:icse2020 pdepa -U -C -M -p -v -- net-misc/clusterssh
```
   
The documentation on how to use `pdepa` is in the [pdepa repository README](https://github.com/gzoumix/pdepa).

## Relevant Directories

The `pdepa` repository contains several relevant directories:
 * `src/main/pdepa.py` is the main file of this repository.
   It implements the algorithm described in this artifact's paper.
 * `src/test/bench/` is the folder containing the scripts used to generate the benchs presented in this artifact's paper.
   Among these scripts, `bench_gen.py` (used to generate a random set of tests to execute) and `standard.py` have the same installation restriction as `pdepa`.
   These tools are however also available in the docker image, as documented in the `src/test/bench/README.md` file.
      
## Installation on a Gentoo OS

`src/main/pdepa.py` file can only be executed with python3, with
[portage](https://gitweb.gentoo.org/proj/portage.git/) and a valid portage
repository installed. Moreover, this executable depends on two python3 packages:
lrparsing and z3-solver. The simplest way to install it is to clone the pdepa
git repository in a [gentoo](https://gentoo.org/) system where the two python
packages were installed using `pip`. If the repository was cloned in a valid
environment, `pdepa` can simply be run from the `src/main/` folder. For
instance, to check if `cssh` can be installed and how, one can run:
   
```
$ python pdepa.py -U -C -M -p -v -- net-misc/clusterssh
```

