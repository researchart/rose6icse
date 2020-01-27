[![DOI](https://zenodo.org/badge/DOI/10.1145/3377811.3380438.svg)](https://doi.org/10.1145/3377811.3380438) 

# Heapster & DroidMacroBench

This is the artifact for the paper "Heaps'n Leaks: How Heap Snapshots Improve Android Taint Analysis". 

## Artifact Description

Our artifact comprises
1. the tool _Heapster_ which can be used to run taint analysis experiments augmented with heap-snapshots in various possible setups.
2. _DroidMacroBench_ a taint analysis benchmark comprising 12 of the 200 most downloaded Android applications with labeled taint analysis findings.
3. the results of our experiments for all partial steps. This allows reproducing the exact results for each step but also omit specific steps at will. E.g, the taint-analysis for all apps might be omitted, since this takes a weeks to produce all results described in the paper. 
4. A preprint of the paper located in this folder under [preprint.pdf](preprint.pdf).

## Reproducing the experiment

We describe the setup and steps to reproduce our experiments in the [INSTALL.md](INSTALL.md) file located in the same folder as this readme. 
The artifact can be downloaded from the following [zenodo repository](https://zenodo.org/record/3627973#.Xi6jnxNKhTY). 

The artifact is rather big since it contains the heap snapshots for the _DroidMacroBench_ benchmark. We could have provided the code for _Heapster_ in a separate GitHub repository. However, we felt that the artifact would make more sense as a whole for artifact evaluation.

Go on reading in [INSTALL.md](INSTALL.md) for further instruction.

