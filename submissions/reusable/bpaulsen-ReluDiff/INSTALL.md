# ReluDiff Setup Instructions
*These instructions assume a fresh instance of Ubuntu 16.04. We also provide a VM with ReluDiff, ReluVal, and DeepPoly working out-of-the-box here*

## Install necessary packages
```console
sudo apt install make git gcc g++ python3 python3-pip
pip3 install numpy tensorflow
```

## Setup a directory to install header and library files
On my installation, my home directory is */home/reludiff*, so I used */home/reludiff/.local* as my installation directory. To set this up, in a shell run:
```console
export INSTALL_PREFIX=/home/reludiff/.local
mkdir $INSTALL_PREFIX
mkdir $INSTALL_PREFIX/lib
mkdir $INSTALL_PREFIX/include
```

Then setup the library and include paths so the compiler and runtime know where to find the installed headers and libraries:
```console
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$INSTALL_PREFIX/lib"
export LIBRARY_PATH="$LIBRARY_PATH:$INSTALL_PREFIX/lib"
export C_INCLUDE_PATH="$LD_LIBRARY_PATH:$INSTALL_PREFIX/include"
```

*_Note_*: The above *export* commands only affect the _current_ shell session. I recommend adding at least the above three commands to the appropriate .\*rc file (e.g., .basrc) so the compiler and runtime paths are persistent.

## Clone the artifact repo
```console
git clone https://github.com/pauls658/ReluDiff-ICSE2020-Artifact
```

## Build the dependencies
First, install OpenBLAS for ReluDiff and ReluVal. In the home directory run:
```console
cd ReluDiff-ICSE2020-Artifact
bash install_OpenBLAS.sh
```

Then install the dependencies for DeepPoly. From the home directory, run
```console
cd ReluDiff-ICSE2020-Artifact/eran
./install.sh $INSTALL_PREFIX
```

# Build ReluDiff
From the home directory
```console
cd DiffNN-Code
make all # compiles single threaded
# or run "make bench all" to compile with multithreading
```

# Build ReluVal
From the home directory
```console
cd ReluVal-for-comparison
make all # compiles single threaded
# or run "make bench all" to compile with multithreading
```

# Build DeepPoly
DeepPoly will already have been built by the install.sh script run previously.
