# Setup

To get the artifact, run
```bash
git clone --recursive https://github.com/theosotr/fsmove-eval ~/fsmove-eval
```
The artifact contains the instructions and scripts
to re-run the evaluation of our paper.
Furthermore, it also provides (as a git submodule)
the tool used in our paper,
which we call `FSMoVe` (File System Model Verifier).

Note that `FSMoVe` is available as
open-source software under
the GNU General Public License v3.0.

Repository URL: https://github.com/AUEB-BALab/fsmove
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3627890.svg)](https://doi.org/10.5281/zenodo.3627890)


The source code of `FSMoVe` is located inside
the `fsmove` directory. Enter this directory
by running
```bash
cd ~/fsmove-eval/fsmove
```

## Docker Image

To facilitate the use of `FSMoVe`,
we provide a `Dockerfile` that builds an image
with the necessary environment for
applying and analyzing Puppet modules.
This image consists of the following elements:

* An installation of `FSMoVe`.
  The image installs the OCaml compiler
  (version 4.0.5) and all the packages required for
  building `FSMoVe` from source. 
* An installation of [Puppet](https://puppet.com/).
* An installation of [strace](https://strace.io/).
* A user named `fsmove` with `sudo` privileges.

To build a Docker image named `fsmove`, run a command of
the form
```bash
docker build -t fsmove --build-arg IMAGE_NAME=<base-image> .
```
where `<base-image>` refers to the base image
from which we set up the environment.
In our evaluation, we ran Puppet manifests on Debian Stretch,
so we used `debian:stretch` as the base image.
So please run the following command:
```bash
docker build -t fsmove --build-arg IMAGE_NAME=debian:stretch .
```
This will take roughly 10-15 minutes.
After building the Docker image successfully,
please go to the root directory of the artifact
```bash
cd ~/fsmove-eval
```

# Getting Started

See [README.md](./README.md)
