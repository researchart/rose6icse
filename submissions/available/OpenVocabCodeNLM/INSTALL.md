## Quick Demonstration with Docker

Since installation on the user's machine might potentially be difficult and running the original experiment 
requires a lot of computational resources (including GPUs) and days to run, 
we provide a docker image to briefly show the functioning artefacts. 

See the next sections for installation on the local machine and original study replication.

The docker image contains: 
- pre-installed [codeprep](https://github.com/giganticode/codeprep) and [OpenVocabCodeNLM](https://github.com/mast-group/OpenVocabCodeNLM) libraries and their dependencies;
- a small fraction of the dataset on which the study was conducted;
- one of the trained NLMs (Neural Language Models) for demonstration;
- scripts to run demonstrations.
 
### Installing Docker

- On Ubuntu please run:
```shell script
sudo apt-get install docker.io
```

- On OSx (taken from the [comprehensive guide](https://medium.com/@yutafujii_59175/a-complete-one-by-one-guide-to-install-docker-on-your-mac-os-using-homebrew-e818eb4cfc3) by Yuta Fujii. Please refer to it for more details on installation for OSx.):
```shell script
$ brew install docker docker-machine
$ brew cask install virtualbox
-> need password
-> possibly need to address System Preference setting
$ docker-machine create --driver virtualbox default
$ docker-machine env default
$ eval "$(docker-machine env default)"
$ docker run hello-world
$ docker-machine stop default
```


For more details and for other operating systems, please refer to Docker documentation: [https://docs.docker.com/install/](https://docs.docker.com/install/)

### Running demonstration:

##### Pulling the docker image and running a docker container

```shell script
docker run -it hlib/open-vocab-code-nlm
```

##### (Inside the docker container) Running vocab-study on a tiny subset of projects

```shell script
scripts/vocab_study.sh
```

##### (Inside the docker container) Running testing of the pre-trained NLM

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

Pretrained language models can be downloaded from (TODO):
https://zenodo.org/...

The structure of the archives can be seen below (all three archives for java, c and python models are identical). 
The names of the sub-directories correspond to the rows of the tables 2 and 3 of the paper:

```


java
 └───token        # Closed NLM
 └───sub          # Heuristic NLM 
 └───bpe_10000             # Open vocab models (BPE with 10k merges)
 │   └───small                 # Trained on the small training set
 │   │   └───2048feats               #  NLMS with 2048 hidden layers
 │   │   │ ...                       #  NLMs with 512 hidden layers
 │   │   
 │   └───large                 # Trained on the large training set
 │       └───2048feats               #  NLMS with 2048 hidden layers
 │       │ ...                       #  NLMS with 512 hidden layers 
 │   
 └───bpe_5000              # Open vocab models (BPE with 5k merges) 
 │   └───small                 # Trained on the small training set
 │   └───large                 # Trained on the large training set
 │       
 └───bpe_2000              # Open vocab models (BPE with 2k merges)
     │   ...
 
```




Each sub-directory contains neural network weigths (lm.ckpt.\<id\>.data-00000-of-00001), vocabulary file (vocab.txt) and files with metadata.

To run inference on these models, you can use the OpenVocabCodeNLMS library (See the previous section).


## Full study replication
 
#### Vocabulary study

Download the Java corpus from (TODO)

##### Download and run the script

Run the script
```shell script
curl -L https://raw.githubusercontent.com/giganticode/icse-2020/master/scripts/vocab_study.sh > vocab_study.sh
chmod +x vocab_study.sh
./vocab_study $PATH_TO_DATASET   
```

#### NLMs training

##### Download the pre-processed datasets from

Java: https://zenodo.org/record/3628665
C:
Python:

For each training scenario change the path to the training file and test files (TODO add details)
