## OpenVocabCodeNLM Artefact Submission

This is a submission of the artefacts for the paper accepted to ICSE 2020: **"Big Code != Big Vocabulary:Open-Vocabulary Models for Source Code"**.

We provide 3 artefacts:

##### [Codeprep](https://pypi.org/project/codeprep/) - a library for code pre-processing.
 
 [![DOI](https://zenodo.org/badge/179685171.svg)](https://zenodo.org/badge/latestdoi/179685171)

###### We use **codeprep** for our vocabulary study (chapter 4. Vocabulary Modeling of the paper) to evaluate different vocabulary modeling choices.  
###### The library can be used outside of the context of the study whenever code pre-processing is needed. **Codeprep** supports a number of pre-processing options starting from simple tokenization to Byte Pair Encoding, with optional filtering of different token types such as comments and string literals. The library can be easily extended with more pre-precessing options if necessary.

##### [OpenVocabCodeNLM](https://github.com/mast-group/OpenVocabCodeNLM) - scripts for training and evaluation of Neural Language Models (NLMs)

 [![DOI](https://zenodo.org/badge/999.svg)](https://zenodo.org/badge/latestdoi/179685171)

###### We use OpenVocabCodeNLM to train a whole range of different NLMs: closed-vocabulary (token, subtoken) ones, open-vocabulary ones (using bpe with different number of merges) on multiple datasets and evaluate them in different scenarios (see tables 2 and 3 of the paper). 
###### Researchers can use **OpenVocabCodeNLM** to train their own models using other datasets or further train or fine-tune the models we provide (see the next section).  

##### [Pre-trained neural language models (NLMs) for code]()

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628628.svg)](https://doi.org/10.5281/zenodo.3628628)

###### We provide NLMs for Java, Python, and C which can be downloaded and used as they are (e.g. for code completion) or for further training or fine-tuning.

## Artifact reuse

We provide [instructions](INSTALL.md) on how to download and install the libraries and the models, and list the steps needed to reproduce the study. Additionally, we provide a docker image which in a few minutes demonstrates the usage of the artifacts.