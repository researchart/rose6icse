## Quick Demonstration with Docker

Since installation on the user's machine might potentially be difficult and running the original experiment 
requires a lot of computational resources (including GPUs) and days to run, 
we provide a docker image to briefly show the functioning artefacts. 

See next sections for installation on the local machine and original study replication.

The docker image contains: 
- pre-installed [codeprep](https://github.com/giganticode/codeprep) and [OpenVocabCodeNLM](https://github.com/mast-group/OpenVocabCodeNLM) libraries and their dependencies;
- a small fraction of the dataset on which the study was conducted;
- one of the trained NLMs (Neural Language Models) for demonstration;
- scripts to run demonstrations.
 
### Installing Docker

On Ubuntu please run:
```shell
sudo apt-get install docker.io
```
For more details and for other operating systems, please refer to Docker documentation: [https://docs.docker.com/install/](https://docs.docker.com/install/)

### Running demonstration:

##### Pulling the docker image and running a docker container

```shell script
docker run -it hlib/open-vocab-code-nlm
```

##### (Inside docker continer) Running vocab-study on a tiny subset of projects:

```shell script
scripts/vocab_study.sh
```

##### (Inside docker container) Running testing of the pre-trained NLM:

```shell script
scripts/nlm.sh
```


## Installation of artifacts

This section describes the installation of the artefacts on the local machine.

### A. Codeprep library:

- Make sure you have python >=3.6 installed
- Optionally create and activate a virtual environment
- Make sure **pip**, **setuptools**, **wheel** are up-to-date: `pip install --upgrade pip setuptools wheel`
- Run `pip3 install codeprep==1.0.0`

Please see https://github.com/giganticode/codeprep for usage examples or run `codeprep --help` to see available pre-processing options.
Alternatively, you may want to check carefully documented [CLI](https://github.com/giganticode/codeprep/blob/v1.0.0/codeprep/cli/spec.py) and [Python API](https://github.com/giganticode/codeprep/blob/v1.0.0/codeprep/api/text.py).

### B. OpenVocabCodeNLM library:

- Clone the OpenVocabCloneNLM repository: `git clone https://github.com/mast-group/OpenVocabCodeNLM`
- `cd OpenVocabCodeNLM`
- Optionally create and activate a virtual environment
- Run `pip3 install -r requirements.txt`

Please see https://github.com/mast-group/OpenVocabCodeNLM for usage options or a [script example](https://github.com/mast-group/OpenVocabCodeNLM/blob/master/example.sh) for running different evaluation scenarios.

### C. Pretrained NLMs:

Pretrained language models can be downloaded form Zenodo:
https://zenodeo.org/...<TODO>

The structure of the archive can be seen below. The names of the sub-directories are correspond to the rows of the tables 2 and 3 of the paper:

+ java
+ c 
+ python
  + token (Closed NLM)
  + sub (Heuristic NLM)
  + bpe_2000
     + small
     + large
  + bpe_5000
     + small
     + large
  + bpe_10000
     + small
     + large
        + 2048feats

Each sub-directory contains neural netwok weigths (lm.ckpt.\<id\>.data-00000-of-00001), vocabulary file (vocab.txt) and files with metadata.


To run inference on these models, you can use OpenVocabCodeNLMS scripts (See the previous section).


## Full study replication.
 
