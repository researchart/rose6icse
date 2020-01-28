## Installation

### Prerequisites

HeteroRefactor has been tested on Ubuntu 16.04.5 LTS. The following packages are required to be installed. We list them as Ubuntu package names. If you are using another operating system, please check the these package names accordingly.

```bash
sudo apt-get install gawk git wget tar bzip2 gcc automake autoconf \
    libhpdf-dev libc6-dev autotools-dev bison flex libtool libbz2-dev \
    libpython2.7-dev ghostscript libhpdf-dev libmpfrc++-dev
```

To get the resource utilization results for the original and refactored kernels, a valid Xilinx Vivado license is required to do the FPGA synthesis and implementation. Please make sure they are in your `PATH` environment variable, and you can run `vivado` and `vivado_hls` in your terminal.

We made some modifications on the library that is shipped with your Vivado installation to get / reproduce the results for floating-point kernels. Due to copyright issues, we cannot release the modified code in public. This library will be available upon request if you have a valid license. Please send an email to Jason Lau \<<lau@cs.ucla.edu>\> along with a screenshot of the license screen of your Vivado installation. We will reply with the code and instructions as soon as possible we receive and verify the request.

### Installation

Once all prerequisites are installed, you can get and build HeteroRefactor by:

```
git clone https://github.com/UCLA-VAST/icse2020-artifacts
cd icse2020-artifacts
make
```

You can add `-j 16` option to the `make` command for faster building. Adjust the number `16` to match your core numbers on your system.

### Usage and More

See [https://github.com/UCLA-VAST/icse2020-artifacts](https://github.com/UCLA-VAST/icse2020-artifacts).
