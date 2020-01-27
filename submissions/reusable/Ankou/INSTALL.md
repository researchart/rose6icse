# Ankou Installation

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
