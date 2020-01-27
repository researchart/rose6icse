### Introduction 

The artifact is a Docker image which contains the *source code*, the *pre-compiled binary* and the *benchmark* of _XRust_.

XRust is  a new technique that mitigates the security threat of
unsafe Rust by ensuring the integrity of data flow from unsafe Rust code to
safe Rust code.
It is composed of a heap allocator that isolates the memory of unsafe Rust from that
accessed only in safe Rust and an extended Rust Compiler.

### Instructions
+ Install `docker`: a complete guide can be found via https://docs.docker.com/install
+ Pull XRust docker image: the docker image can be found via https://hub.docker.com/repository/docker/geticliu/xrust-icse2020.
using `docker pull geticliu/xrust-icse2020` command to pull the docker image into your local machine.
+ Run the docker image using `docker run -it geticliu/xrust-icse2020`
+ All related files (including source code and binaries) are under `/ICSE` folder
+ To run the benchmark, navigate to `/ICSE/RustBench/` folder, and execute `sh run_all_bench.sh`.
+ The result is stored into `/ICSE/RustBench/result` folder.

If you want to play with the XRust compiler, it is pre-compiled in the docker and can be used just as regular rust compiler but 
with additional features such as `unsafe_box` and `unsafe_alloc` to allocate heap objects into a different memory regions.

For more information about how to use Rust toolchains, please refer to https://doc.rust-lang.org/cargo/getting-started/index.html

### Paper Abstraction
  Rust is a promising system programming language that embraces both
  high-level memory safety and low-level resource manipulation.
  However, the dark side of Rust, unsafe Rust, leaves a large
  security hole as it bypasses the Rust type system in order to
  support low-level operations. Recently, several real-world memory corruption
  vulnerabilities have been discovered in Rust's standard libraries.

  We present XRust, a new technique that mitigates the security threat of
  unsafe Rust by ensuring the integrity of data flow from unsafe Rust code to
  safe Rust code.
  The cornerstone of XRust is a novel
  heap allocator that isolates the memory of unsafe Rust from that
  accessed only in safe Rust, and prevents any cross-region memory corruption.
  Our extensive experiments on real-world Rust
  applications and standard libraries show that XRust is both highly efficient
  and effective in practice.
