## OpenVocabCodeNLM Artefact Submission

This is a submission of the artefacts for the paper accepted to ICSE 2020: **"Big Code != Big Vocabulary:Open-Vocabulary Models for Source Code"**.

We provide 3 artefacts:

##### [Codeprep](https://pypi.org/project/codeprep/) - a library for code pre-processing.
 
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3627130.svg)](https://doi.org/10.5281/zenodo.3627130)

###### We use **codeprep** for our vocabulary study (chapter 4. Vocabulary Modeling of the paper) to evaluate different vocabulary modeling choices.  
###### The library can be used outside of the context of the study whenever code pre-processing is needed. **Codeprep** supports a number of pre-processing options starting from simple tokenization to Byte Pair Encoding, with optional filtering of different token types such as comments and string literals. The library can be easily extended with more pre-precessing options if necessary.

##### [OpenVocabCodeNLM](https://github.com/mast-group/OpenVocabCodeNLM) - scripts for training and evaluation of Neural Language Models (NLMs)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3629271.svg)](https://doi.org/10.5281/zenodo.3629271)


###### We use OpenVocabCodeNLM to train a whole range of different NLMs: closed-vocabulary (token, subtoken) ones, open-vocabulary ones (using bpe with different number of merges) on multiple datasets and evaluate them in different scenarios (see tables 2 and 3 of the paper). 
###### Researchers can use **OpenVocabCodeNLM** to train their own models using other datasets or further train or fine-tune the models we provide (see the next section).  

##### [Pre-trained neural language models (NLMs) for code](https://zenodo.org/record/3628628)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628628.svg)](https://doi.org/10.5281/zenodo.3628628)

###### We provide NLMs for Java, Python, and C which can be downloaded and used as they are (e.g. for code completion), for further training on a specific corpus or project, or fine-tuning on additional tasks.


## Artifact reuse

We provide [instructions](INSTALL.md) on how to download and install the libraries and the models, and list the steps needed to reproduce the study. Additionally, we provide a docker image which in a few minutes demonstrates the usage of the artifacts.

## Arfifacts used in the study

### 'Raw' corpora

[Github Java Corpus](https://doi.org/10.7488/ds/1690) (DOI: https://doi.org/10.7488/ds/1690)

[C Corpus](https://doi.org/10.5281/zenodo.3628775)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628775.svg)](https://doi.org/10.5281/zenodo.3628775)

[Python Corpus](https://doi.org/10.5281/zenodo.3628784)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628784.svg)](https://doi.org/10.5281/zenodo.3628784)

### Pre-processed corpora

[Pre-processed C Corpus](https://doi.org/10.5281/zenodo.3628638)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628638.svg)](https://doi.org/10.5281/zenodo.3628638)

[Pre-processed Python Corpus](https://doi.org/10.5281/zenodo.3628636)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628636.svg)](https://doi.org/10.5281/zenodo.3628636)

[Pre-processed Java Corpus](https://doi.org/10.5281/zenodo.3628665)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3628665.svg)](https://doi.org/10.5281/zenodo.3628665)

