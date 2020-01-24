# POSIT
This artefact submission includes all novel code written for the ICSE Technical Track, submission 984: "Posit: Simultaneously TaggingNatural and Programming Languages".
The paper describes an approach to simultaneously provide language ID tags and Part-Of-Speech 
or compiler tags (which are taken from CLANG compilations of C and C++ code).

This artefact allows recreating the corpora presented in the paper and training the neural network.

It does not contain artefacts or software used from third-parties that were used in the downstream evaluation of the POSIT tool, such as TaskNav, though it does include the RPC Server code that allows external tools to interact with the model.

We also include output and utility scripts used for manual investigations, including for TaskNav related investigations.

The tool can be obtained from the public repository: https://github.com/PPPI/POSIT/

Additionally, archived versions from 21.01.2020 (release:`0.3.1`) can be found at:
- [![DOI](https://zenodo.org/badge/233908281.svg)](https://zenodo.org/badge/latestdoi/233908281)
- [![SWH](https://archive.softwareheritage.org/badge/origin/https://github.com/PPPI/POSIT.git/)](https://archive.softwareheritage.org/browse/origin/https://github.com/PPPI/POSIT.git/)

The repository [README.md](https://github.com/PPPI/POSIT/blob/master/README.MD) includes details on how to run the tool. We also include these details in INSTALL.md.