## OpenVocabCodeNLM Artefact Submission

This is a submission of the artefacts for the paper accepted to ICSE 2020: **"Big Code != Big Vocabulary:Open-Vocabulary Models for Source Code"**.

We provide 3 artefacts:

##### [Codeprep](https://github.com/giganticode/codeprep) - a library for code pre-processing which support a number of pre-processing options
 
 [![DOI](https://zenodo.org/badge/179685171.svg)](https://zenodo.org/badge/latestdoi/179685171)

###### We use the library for our vocabulary study (chapter 4. Vocabulary Modeling of the paper) to evaluate different vocabulary modeling choices. *Codeprep* can be used for starting from simple code tokenization to learning and applying custom bpe codes. Codeprep is also easibly extensible if support for more pre-processing options is needed. 

##### [OpenVocabCodeNLM](https://github.com/mast-group/OpenVocabCodeNLM) - library for training and evaluation of Neural Language Models (NLMs)

 [![DOI](https://zenodo.org/badge/999.svg)](https://zenodo.org/badge/latestdoi/179685171)

###### We use OpenVocabCodeNLM to train a whole range of different NLMs: token, subtoken one, the ones using bpe with different number of merges on multiple datasets and evaluaet them in different scenarios (see tables 2 and 3 of the paper). Researchers can use the library to to train their own models on other datasets or further train or fine-tune existing models.  

##### Pre-trained Language models

 [![DOI](https://zenodo.org/badge/999.svg)](https://zenodo.org/badge/latestdoi/179685171)

###### The pre-trained models can be downloaded and used as they are (e.g. for code completion) or for further training/fine-tuning.

## Artifact reuse

[Here](INSTALL.md) we provide instructions on how to download and install the libraries and the models. Besides, we provide a docker image which demonstrates in a few minutes the usage of the artifacts. In addition to that, we list the steps needed to reproduce the study.
