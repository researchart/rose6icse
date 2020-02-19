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
