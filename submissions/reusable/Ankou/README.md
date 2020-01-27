Ankou
===

Ankou is a source-based grey-box fuzzer. It intends to use a more rich fitness
function by going beyond simple branch coverage and considering the
*combination* of branches during program execution.
The details of the technique can be found in our paper "Ankou: Guiding Grey-box
Fuzzing towards Combinatorial Difference", which is published in ICSE 2020.

## Dependencies.

#### Go
Ankou is written solely in Go and thus requires its
[installation](https://golang.org/doc/install). Be sure to configure this
`GOPATH` environment variable, for example to `~/go` directory.

#### AFL
Ankou relies on [AFL](http://lcamtuf.coredump.cx/afl/) instrumentation: fuzzed
targets needs to compiled using `afl-gcc` or `afl-clang`. To install AFL:
```bash
wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz
tar xf afl-latest.tgz
cd afl-2.52b
make
# The last command is optional, but you'll need to provide the absolute path to
# the compiler in the configure step below if you don't install AFL compiler.
sudo make install
```

## Installation

Once Go and AFL are installed, you can get Ankou by:
``` bash
go get github.com/SoftSec-KAIST/Ankou   # Clone Ankou and its dependencies
go build github.com/SoftSec-KAIST/Ankou # Compile Ankou
```

##### Note: If getting Ankou from another location, this needs to be done manually:
```bash
mkdir -p $GOPATH/src/github.com/SoftSec-KAIST
cd $GOPATH/src/github.com/SoftSec-KAIST
git clone REPO  # By default REPO is https://github.com/SoftSec-KAIST/Ankou
cd Ankou
go get .    # Get dependencies
go build .  # Compile
```

## Usage

Now we are ready to fuzz. We first to compile any target we want with `afl-gcc`
or `afl-clang`. Let's take the classical starting example for fuzzing, binutils:
```bash
wget https://mirror.ibcp.fr/pub/gnu/binutils/binutils-2.33.1.tar.xz
tar xf binutils-2.33.1.tar.xz
cd binutils-2.33.1
CC=afl-gcc CXX=afl-g++ ./configure --disable-shared --prefix=`pwd`/install
make -j
make install
```

Now we are ready to run Ankou:
```bash
cd install/bin
mkdir seeds; cp elfedit seeds/ # Put anything in the seeds folder.
go run github.com/SoftSec-KAIST/Ankou -app ./readelf -args "-a @@" -i seeds -o out
# Or use the binary we compiled above:
/path/to/Ankou -app ./readelf -args "-a @@" -i seeds -o out
```

## Evaluation Reproduction

Once Ankou is installed, in order to reproduce the Ankou evaluation:
1. Compile the 24 packages mentioned in the paper at the same version or commit
   using `afl-gcc`.
2. Run the produced subjects with the commands found in
   `benchmark/configuration.json`. In `benchmark/seeds.zip` are the seeds used
   for each package.
3. Analyze Ankou output directory for results. Crashes are listed in
   `$OUTPUT_DIR/crashes-*` and found seeds in `$OUTPUT_DIR/seeds-*`. Statistics
   of the fuzzing campaign can be found in the `$OUTPUT_DIR/status*` directory
   CSV files.
