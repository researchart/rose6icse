This artifact is for the paper "Symbolic Verification of Message Passing Interface Programs (#662)".

The artifact is published in three forms: (1) a public docker image on Docker Hub at this [link](https://hub.docker.com/r/mpisv/mpi-sv), which is used for reproducing the evaluation results in the paper; (2) a public distribution in binary at this [link](https://github.com/mpi-sv/mpi-sv) and a [website](http://mpi-sv.github.io) our tool (i.e., MPI-SV), and the website provides the introduction, binaray installation, manual, and tutorial docuemnts for MPI-SV; (3) the source code of MPI-SV is publicly available at this [link](https://github.com/mpi-sv/mpi-sv-src). **Due to the long time and the complexity for binary installation or source installation, we suggest to reproduce our evaluation results using the docker image.** 

The artifact in the docker image form (available at this [link](https://hub.docker.com/r/mpisv/mpi-sv)) includes the symbolic verification tool (i.e., MPI-SV) developed by us, the clang-based compiler and the benchmarks used in our evaluation.

## What's inside the docker image artifact?

The following items can be found in the docker image artifact:

1. The symbolic verification tool MPI-SV in the binary form:
   * the cloud9-based underlying symbolic verification engine (/root/mpi-sv/klee)
   * the running script (/root/mpi-sv/mpisv)

2. The compiler for compiling MPI C programs:
   * clang (/bin/clang)
   * the clang wrapped compiler script (/root/mpi-sv/mpisvcc)

3. Benchmarks in our paper's evaluation:

   * the LLVM intermediate representation (IR) files of the programs used in our evaluation (/root/mpi-sv/Artifact-Benchmark)
  
   * the script for verifying benchmark programs one by one (/root/mpi-sv/reproduce.sh)

   * the script for verifying all the benchmark programs (/root/mpi-sv/Artifact-Benchmark/script-all/ALL/run.sh)

   * the script for verifying the benchmark programs that verified less than 5 minutes (/root/mpi-sv/Artifact-Benchmark/script-5min/5_min/run.sh)

## What to do with the docker image artifact and how?

One can use the docker image to verifying MPI C programs and also reproduce the main experimental results in our paper. We explain both of them in detail in the [INSTALL](INSTALL.md).


## Links

- **Website**: https://mpi-sv.github.io/

- **Binary GitHub**: https://github.com/mpi-sv/mpi-sv

- **Source Github**: https://github.com/mpi-sv/mpi-sv-src