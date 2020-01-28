# HeteroRefactor

Refactoring for Heterogeneous Computing with FPGA

## Abstract

Heterogeneous computing with field-programmable gate-arrays (FPGAs) has demonstrated orders of magnitude improvement in computing efficiency for many applications. However, the use of such platforms so far is limited to a small subset of programmers with specialized hardware knowledge. High-level synthesis (HLS) tools made significant progress in raising the level of programming abstraction from hardware programming languages to C/C++, but they usually cannot compile and generate accelerators for kernel programs with pointers, memory management, and recursion, and require manual refactoring to make them HLS-compatible. Besides, experts also need to provide heavily handcrafted optimizations to improve resource efficiency, which affects the maximum operating frequency, parallelization, and power efficiency.

HeteroRefactor is a new dynamic invariant analysis and automated refactoring tool. HeteroRefactor monitors FPGA-specific dynamic invariants—the required bitwidth of integer and floating-point variables, and the size of recursive data structures and stacks. Second, using this knowledge of dynamic invariants, it refactors the kernel to make traditionally HLS-incompatible programs synthesizable and to optimize the accelerator’s resource usage and frequency further. Third, to guarantee correctness while leveraging both CPU and FPGA, it generate guard checks to selectively offloads the computation from CPU to FPGA, only if an input falls within the dynamic invariant.


## Prerequisites

HeteroRefactor has been tested on Ubuntu 16.04.5 LTS. The following packages are required to be installed. We list them as Ubuntu package names. If you are using another operating system, please check the these package names accordingly.

```bash
sudo apt-get install gawk git wget tar bzip2 gcc automake autoconf \
    libhpdf-dev libc6-dev autotools-dev bison flex libtool libbz2-dev \
    libpython2.7-dev ghostscript libhpdf-dev libmpfrc++-dev
```

To get the resource utilization results for the original and refactored kernels, a valid Xilinx Vivado license is required to do the FPGA synthesis and implementation. Please make sure they are in your `PATH` environment variable, and you can run `vivado` and `vivado_hls` in your terminal.

We made some modifications on the library that is shipped with your Vivado installation to get / reproduce the results for floating-point kernels. Due to copyright issues, we cannot release the modified code in public. This library will be available upon request if you have a valid license. Please send an email to Jason Lau \<<lau@cs.ucla.edu>\> along with a screenshot of the license screen of your Vivado installation. We will reply with the code and instructions as soon as possible we receive and verify the request.

## How to build the HeteroRefactor tool

Simply `git clone` and `make`!

```
git clone https://github.com/UCLA-VAST/icse2020-artifacts
cd icse2020-artifacts
make
```

See [our repository](https://github.com/UCLA-VAST/icse2020-artifacts) for details.

## How to Use HeteroRefactor

After building the system, the tool `heterorefactor` is available at `heterorefactor/refactoring/build/heterorefactor`. Please note that we hardcoded a relative path to avoid you explicitly specifying the root path of this project. Therefore, please do not move the binary file. Optionally, you can add `heterorefactor/refactoring/build/` to your `PATH`.

To use the tool, please type

```bash
heterorefactor [-int/-fp/-rec/-instrument] \
    -I path/your/include/files [...and other GCC compiler options] \
    -u refactored_output_code.cpp \
    input_code.cpp
```

For example, if you want to refactor the linked list kernel using HeteroRefactor and output to `output.cpp`:

```bash
heterorefactor -rec -u output.cpp experiments/Recursive/ll/src/kernel.cpp
```
Please check `heterorefactor -h` for a detailed manual.

## How to Reproduce Paper Results

- [General information](https://github.com/UCLA-VAST/icse2020-artifacts)
- [Recursive data structure kernels](https://github.com/UCLA-VAST/icse2020-artifacts/tree/master/experiments/Recursive)
- [Floating-point kernels](https://github.com/UCLA-VAST/icse2020-artifacts/tree/master/experiments/FP)
- [Integer kernels](https://github.com/UCLA-VAST/icse2020-artifacts/tree/master/experiments/Integer)

---

![SEAL](http://web.cs.ucla.edu/~miryung/seal-logo.jpg)

![VAST](http://vast.cs.ucla.edu/sites/default/themes/CADlab_cadlab/images/logo.png)
