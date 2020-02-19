This document provides detailed instructions on how to install our artifact and how to test if the installation was successful. This information is also publicly available as part of our [repository](https://github.com/alebugariu/StringSolversTests/blob/master/README.md).

# Setup
We provide a [Docker](https://www.docker.com/) image, as well as step by step instructions on how to install the dependencies and build our tool. 

## Using Docker
Download our Docker image:
```
docker pull alebugariu/string_solvers_tests:1.0
```
Start the container and go to the folder of our project (StringSolversTests):
```
docker run -it alebugariu/string_solvers_tests:1.0
cd StringSolversTests
```

## Without Docker

The tool has been tested on Ubuntu 16.04 with Java 8. Building [Z3](https://github.com/Z3Prover/z3) version 4.7.1 requires Python 2.7 and building [ABC](https://github.com/vlab-cs-ucsb/ABC) requires autotools, [Flex](https://github.com/westes/flex) and [Bison](https://www.gnu.org/software/bison/). To install the prerequisites:

```
sudo apt-get install -y openjdk-8-jdk python build-essential autoconf automake libtool intltool flex bison
```

Clone our repository:

```
git clone https://github.com/alebugariu/StringSolversTests.git StringSolversTests
cd StringSolversTests
chmod +x install.sh
```

Set the directory where the solvers should be downloaded, by changing the default value for ```ROOT=~/icse513``` in install.sh.

Run the script install.sh (requires sudo access for installing [ABC](https://github.com/vlab-cs-ucsb/ABC)): 
```
./install.sh
```
The script runs for **~25 min** and performs the following steps:
* creates a folder ROOT/SMTSolvers in which:
  + it downloads [Z3](https://github.com/Z3Prover/z3) version 4.7.1, applies a patch for supporting the operations int.to.str and str.to.int from the Java API and 
  builds the solver from sources with the Java bindings.
  + it downloads [Z3](https://github.com/Z3Prover/z3) version 4.8.6.
  + it downloads [CVC4](https://cvc4.github.io/) version 1.6.
  + it downloads [CVC4](https://cvc4.github.io/) version 1.7.
* creates a config.txt file in our project, containing the paths to the SMT solvers previously downloaded. The config file follows
the [template](https://github.com/alebugariu/StringSolversTests/blob/master/src/config_template.txt). 
* creates a folder ROOT/AutomataBasedSolvers in which it downloads and builds the automata-based solver 
[ABC](https://github.com/vlab-cs-ucsb/ABC) (the [commit](https://github.com/vlab-cs-ucsb/ABC/commit/86b00141fddd183de7b9ae5c92c240e19dda1950) used in our experiments) 
and its dependencies. This step requires sudo access.
* compiles our project.

# Usage
To check that [ABC](https://github.com/vlab-cs-ucsb/ABC) was successfully installed:
```
abc -h
```
This command will list the available options.

To run our tool:
```
chmod +x run.sh
./run.sh -help
```
This command will list the options supported by our tool.
