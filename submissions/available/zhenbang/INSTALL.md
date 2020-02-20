Please follow the following steps to install the docker image of MPI-SV, verify the example program, and reproduce the results in our paper.

# Install and start docker

We suppose that **the host OS** is **Linux** or **Mac OS X** on which docker can be installed. We suppose that you have installed the **docker** environment; otherwise, please go to [this link](https://docs.docker.com/install/) for help. 


# Download MPI-SV's docker image

```
docker pull mpisv/mpi-sv:v1.0
```

If the image downloading succeeds, you can use the following command to have a check.

```
docker images
```

You should see that an image named **mpisv/mpi-sv** exists. We have tested the docker image on the following three platforms. 

OS | Version | Result of "uname -a" | Result of "docker --version"
---- | --- | --- | ---
Mac OS X | Mojave 10.14.6 | Darwin 192.168.0.100 18.7.0 Darwin Kernel Version 18.7.0: Sun Dec  1 18:59:03 PST 2019; root:xnu-4903.278.19~1/RELEASE_X86_64 x86_64 | Docker version 19.03.5, build 633a0ea
Debian | 10.3 | Linux test-vm 4.19.0-8-amd64 #1 SMP Debian 4.19.98-1 (2020-01-26) x86_64 GNU/Linux | Docker version 19.03.6, build 369ce74a3c
Ubuntu | 14.04 | Linux ubuntu 4.4.0-31-generic #50~14.04.1-Ubuntu SMP Wed Jul 13 01:07:32 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux | Docker version 1.6.2, build 7c8fca2

# Run the test

We use a demo program to test the installation.

The source code of the demo program (/root/mpi-sv/examples/demo.c) is as follows.
```c
#include <stdio.h>
#include "mpi.h"

int main(int argc, char **argv) {
    int nprocs = -1;
    int rank = -1;
    char processor_name[128];
    int namelen = 128;

    MPI_Status status;
    MPI_Request req;

    /* init */
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(processor_name, &namelen);
    printf("(%d) is alive on %s\n", rank, processor_name);
    fflush(stdout);

    if (rank == 0) {
        char c;
        klee_make_symbolic(&c, sizeof(c), "c");
        int v1, v2;
        if (c != 'a') {
            MPI_Recv(&v1, 1, MPI_INT, 1, 0, MPI_COMM_WORLD, &status);
        } else {
            MPI_Irecv(&v1, 1, MPI_INT, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &req);
        }
        MPI_Recv(&v2, 1, MPI_INT, 3, 0, MPI_COMM_WORLD, &status);
    } else {
        MPI_Isend(&rank, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &req);
    }

    MPI_Finalize();

    return 0;
}
```

The first process (i.e., the one with rank 0, denoted by P0) gets an input character **c** first. Then, P0 will receive v1's value from P1 if **c** is *not* equal to **'a'**; otherwise, P0 will use a non-blocking wildcard receive to receive the value. Finally, P0 receives v2's value from P3. For the other processes, each sends its rank value to P0 and terminates. Suppose that we run this MPI program in four processes. An error will happen if **c** is equal to **'a'** and the MPI_Irecv receives the message from P3. Then, the last blocking receive blocks P0 because the message from P3 is already received by the MPI_Irecv, which results in a deadlock, i.e., the program does not terminate but cannot progress.

You can run the docker image to verify this program.

```
docker run -it mpisv/mpi-sv
```

The following command compiles the demo program in /root/mpi-sv/examples. 

```
cd /root/mpi-sv/examples
mpisvcc demo.c -o test.bc
```

If this command succeeds, you should find **test.bc** in your current directory.

The following command uses MPI-SV to verify the demo program in 4 processes **in pure symbolic execution**. 

```
mpisv 4 test.bc
```

If everything is okay, you will see many output messages and find the following messages in the last.

```
MPI-SV: totally 4 iterations
MPI-SV: find a violation in the 4 iterations
Different Pcs: 2
```

It indicates that MPI-SV finds the deadlock at the 4th iteration. MPI-SV outputs the execution contexts of the four processes when the deadlock occurs as follows.

```
E0106 21:26:11.599409    29 ExecutionState.cpp:644] ***********************************************************
I0106 21:26:11.599431    29 ExecutionState.cpp:646] Call:    MPI_Recv(/root/mpi-sv/examples/demo.c,30)
I0106 21:26:11.599510    29 ExecutionState.cpp:646] Call:    usermain(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/azqmpi/src/private/main.c,74)
I0106 21:26:11.599678    29 ExecutionState.cpp:646] Call:    node_main__(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/idsp/blk/impl/thr.c,228)
E0106 21:26:11.599757    29 ExecutionState.cpp:650] Call:    wrapper
E0106 21:26:11.599817    29 ExecutionState.cpp:651] ***********************************************************
E0106 21:26:11.599843    29 ExecutionState.cpp:644] ***********************************************************
I0106 21:26:11.599941    29 ExecutionState.cpp:646] Call:    MPI_Finalize(/root/mpi-sv/examples/demo.c,35)
I0106 21:26:11.599969    29 ExecutionState.cpp:646] Call:    usermain(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/azqmpi/src/private/main.c,74)
I0106 21:26:11.600334    29 ExecutionState.cpp:646] Call:    node_main__(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/idsp/blk/impl/thr.c,228)
E0106 21:26:11.600364    29 ExecutionState.cpp:650] Call:    wrapper
E0106 21:26:11.600386    29 ExecutionState.cpp:651] ***********************************************************
E0106 21:26:11.600406    29 ExecutionState.cpp:644] ***********************************************************
I0106 21:26:11.600431    29 ExecutionState.cpp:646] Call:    MPI_Finalize(/root/mpi-sv/examples/demo.c,35)
I0106 21:26:11.600687    29 ExecutionState.cpp:646] Call:    usermain(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/azqmpi/src/private/main.c,74)
I0106 21:26:11.600728    29 ExecutionState.cpp:646] Call:    node_main__(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/idsp/blk/impl/thr.c,228)
E0106 21:26:11.600749    29 ExecutionState.cpp:650] Call:    wrapper
E0106 21:26:11.600783    29 ExecutionState.cpp:651] ***********************************************************
E0106 21:26:11.600828    29 ExecutionState.cpp:644] ***********************************************************
I0106 21:26:11.600888    29 ExecutionState.cpp:646] Call:    MPI_Finalize(/root/mpi-sv/examples/demo.c,35)
I0106 21:26:11.600909    29 ExecutionState.cpp:646] Call:    usermain(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/azqmpi/src/private/main.c,74)
I0106 21:26:11.600927    29 ExecutionState.cpp:646] Call:    node_main__(/root/MPISE_root/MPISE_Install/CLOUD9/src/MPISE/AzequiaMPI.llvm/idsp/blk/impl/thr.c,228)
E0106 21:26:11.600941    29 ExecutionState.cpp:650] Call:    wrapper
E0106 21:26:11.600950    29 ExecutionState.cpp:651] ***********************************************************
```
So, we can see that the first process blocks at the Recv operation and the other 3 processes terminate, i.e., a deadlock occurs.

Then, we enable the model checking-based boosting in **mpisv** to verify the program also in 4 processes.

```
mpisv 4 -wild-opt -use-directeddfs-search test.bc
```

The last three output messages should be as follows.
```
MPI-SV: totally 2 iterations
MPI-SV: find a violation in the 2 iterations
Different Pcs: 2
```

It indicates that MPI-SV **only** needs 2 iterations to find the deadlock by using model checking-based boosting.


# Reproduce the experimental results in the paper

We can use docker to repoduce the experimental results in the paper. For the results in Table 2, we only reproduce two kinds of results (**whether deadlock exists**, **the numbers of the iterations**) under two modes: **pure symbolic execution** ("Symbolic execution" in Table 2) and **model checking-based boosting** ("Our approach" in Table 2). 

In the following, the [first part](#reproduce-the-result-of-one-verification-task-in-table-2) explains how to reproduce the result of one verification task; the [second part](#reproduce-the-results-only-the-ones-with-the-verification-time-that-is-less-than-5-minutes-of-the-finished-verification-tasks-in-table-2) gives how to reproduce the results of the deadlock-freedom verfication tasks (each of which needs less than 5 minutes) in Table 2; the [third part](#reproduce-the-results-of-ltl-temporal-property-verification-section-5-temporal-properties-page-10) gives how to reproduce the results of verifying temporal properties; the [last part](#reproduce-the-results-of-all-the-verification-tasks-with-a-very-long-time-in-table-2) give how to reproduce the resutls of all the deadlock-freedom verfication tasks in Table 2. 

**We suggest following the steps in the [first part](#reproduce-the-result-of-one-verification-task-in-table-2) to have a try of one verification task. Due to the long-running time of getting all the results (By running with 8 processes in parallel, it took more than 8 hours on our experimental server which has 8 cores (Intel(R) Xeon(R) CPU E5-2682 v4 @ 2.50GHz) and 64G memory), we suggest to only follow the steps of the [second](#reproduce-the-results-only-the-ones-with-the-verification-time-that-is-less-than-5-minutes-of-the-finished-verification-tasks-in-table-2) and the [third](#reproduce-the-results-of-ltl-temporal-property-verification-section-5-temporal-properties-page-10) parts for reproducing the experimental results.** 

### Reproduce the result of one verification task in Table 2

Use the following command to reproduce the result of one verification task in Table 2.
```
reproduce.sh <program_name> <mutate_flag> <process_num> <time_limit> <opt_flag>
```

**\<program_name\>** : DTG, Integrate, ...

**\<mutate_flag\>** : 0, 1, 2, ...

**\<process_num\>** : 4, 6, 8, ...

**\<time_limit\>** : 3600, ..., in seconds.

**\<opt_flag\>** : 1 or 0, where 1 represents using model-checking based boosting, 0 represents using pure symbolic execution.

The following table gives the commands for the verification tasks in Table 2.

Program name (#Procs) | T | Command (pure symbolic execution) | Command (model checking-based boosting)
---- | --- | --- | ---
DTG(5)  | o  | reproduce.sh DTG 0 5 3600 0 | reproduce.sh DTG 0 5 3600 1
DTG(5)  | m1 | reproduce.sh DTG 1 5 3600 0 | reproduce.sh DTG 1 5 3600 1
DTG(5)  | m2 | reproduce.sh DTG 2 5 3600 0 | reproduce.sh DTG 2 5 3600 1
DTG(5)  | m3 | reproduce.sh DTG 3 5 3600 0 | reproduce.sh DTG 3 5 3600 1
DTG(5)  | m4 | reproduce.sh DTG 4 5 3600 0 | reproduce.sh DTG 4 5 3600 1
DTG(5)  | m5 | reproduce.sh DTG 5 5 3600 0 | reproduce.sh DTG 5 5 3600 1
Matmat-MS(4)  | o | reproduce.sh Matmat-MS 0 4 3600 0 | reproduce.sh Matmat-MS 0 4 3600 1
Integrate(6)  | o | reproduce.sh Integrate 0 6 3600 0 | reproduce.sh Integrate 0 6 3600 1
Integrate(6)  | m1 | reproduce.sh Integrate 1 6 3600 0 | reproduce.sh Integrate 1 6 3600 1
Integrate(6)  | m2 | reproduce.sh Integrate 2 6 3600 0 | reproduce.sh Integrate 2 6 3600 1
Integrate(8)  | o | reproduce.sh Integrate 0 8 3600 0 | reproduce.sh Integrate 0 8 3600 1
Integrate(8)  | m1 | reproduce.sh Integrate 1 8 3600 0 | reproduce.sh Integrate 1 8 3600 1
Integrate(8)  | m2 | reproduce.sh Integrate 2 8 3600 0 | reproduce.sh Integrate 2 8 3600 1
Integrate(10)  | o | reproduce.sh Integrate 0 10 3600 0 | reproduce.sh Integrate 0 10 3600 1
Integrate(10)  | m1 | reproduce.sh Integrate 1 10 3600 0 | reproduce.sh Integrate 1 10 3600 1
Integrate(10)  | m2 | reproduce.sh Integrate 2 10 3600 0 | reproduce.sh Integrate 2 10 3600 1
Integrate-MS(4)  | o | reproduce.sh Integrate-MS 0 4 3600 0 | reproduce.sh Integrate-MS 0 4 3600 1
Integrate-MS(6)  | o | reproduce.sh Integrate-MS 0 6 3600 0 | reproduce.sh Integrate-MS 0 6 3600 1
Diffusion2d(4)  | o | reproduce.sh Diffusion2d 0 4 3600 0 | reproduce.sh Diffusion2d 0 4 3600 1
Diffusion2d(4)  | m1 | reproduce.sh Diffusion2d 1 4 3600 0 | reproduce.sh Diffusion2d 1 4 3600 1
Diffusion2d(4)  | m2 | reproduce.sh Diffusion2d 1 4 3600 0 | reproduce.sh Diffusion2d 2 4 3600 1
Diffusion2d(4)  | m3 | reproduce.sh Diffusion2d 1 4 3600 0 | reproduce.sh Diffusion2d 3 4 3600 1
Diffusion2d(4)  | m4 | reproduce.sh Diffusion2d 1 4 3600 0 | reproduce.sh Diffusion2d 4 4 3600 1
Diffusion2d(4)  | m5 | reproduce.sh Diffusion2d 1 4 3600 0 | reproduce.sh Diffusion2d 5 4 3600 1
Diffusion2d(6)  | o | reproduce.sh Diffusion2d 0 6 3600 0 | reproduce.sh Diffusion2d 0 6 3600 1
Diffusion2d(6)  | m1 | reproduce.sh Diffusion2d 1 6 3600 0 | reproduce.sh Diffusion2d 1 6 3600 1
Diffusion2d(6)  | m2 | reproduce.sh Diffusion2d 1 6 3600 0 | reproduce.sh Diffusion2d 2 6 3600 1
Diffusion2d(6)  | m3 | reproduce.sh Diffusion2d 1 6 3600 0 | reproduce.sh Diffusion2d 3 6 3600 1
Diffusion2d(6)  | m4 | reproduce.sh Diffusion2d 1 6 3600 0 | reproduce.sh Diffusion2d 4 6 3600 1
Diffusion2d(6)  | m5 | reproduce.sh Diffusion2d 1 6 3600 0 | reproduce.sh Diffusion2d 5 6 3600 1
Gauss_elim(6)  | o | reproduce.sh Gauss_elim 0 6 3600 0 | reproduce.sh Gauss_elim 0 6 3600 1
Gauss_elim(6)  | m1 | reproduce.sh Gauss_elim 1 6 3600 0 | reproduce.sh Gauss_elim 1 6 3600 1
Gauss_elim(8)  | o | reproduce.sh Gauss_elim 0 8 3600 0 | reproduce.sh Gauss_elim 0 8 3600 1
Gauss_elim(8)  | m1 | reproduce.sh Gauss_elim 1 8 3600 0 | reproduce.sh Gauss_elim 1 8 3600 1
Gauss_elim(10)  | o | reproduce.sh Gauss_elim 0 10 3600 0 | reproduce.sh Gauss_elim 0 10 3600 1
Gauss_elim(10)  | m1 | reproduce.sh Gauss_elim 1 10 3600 0 | reproduce.sh Gauss_elim 1 10 3600 1
Heat(6)  | o | reproduce.sh Heat 0 6 3600 0 | reproduce.sh Heat 0 6 3600 1
Heat(6)  | m1 | reproduce.sh Heat 1 6 3600 0 | reproduce.sh Heat 1 6 3600 1
Heat(6)  | m2 | reproduce.sh Heat 2 6 3600 0 | reproduce.sh Heat 2 6 3600 1
Heat(6)  | m3 | reproduce.sh Heat 3 6 3600 0 | reproduce.sh Heat 3 6 3600 1
Heat(6)  | m4 | reproduce.sh Heat 4 6 3600 0 | reproduce.sh Heat 4 6 3600 1
Heat(6)  | m5 | reproduce.sh Heat 5 6 3600 0 | reproduce.sh Heat 5 6 3600 1
Heat(8)  | o | reproduce.sh Heat 0 8 3600 0 | reproduce.sh Heat 0 6 3600 1
Heat(8)  | m1 | reproduce.sh Heat 1 8 3600 0 | reproduce.sh Heat 1 8 3600 1
Heat(8)  | m2 | reproduce.sh Heat 2 8 3600 0 | reproduce.sh Heat 2 8 3600 1
Heat(8)  | m3 | reproduce.sh Heat 3 8 3600 0 | reproduce.sh Heat 3 8 3600 1
Heat(8)  | m4 | reproduce.sh Heat 4 8 3600 0 | reproduce.sh Heat 4 8 3600 1
Heat(8)  | m5 | reproduce.sh Heat 5 8 3600 0 | reproduce.sh Heat 5 8 3600 1
Heat(10)  | o | reproduce.sh Heat 0 10 3600 0 | reproduce.sh Heat 0 10 3600 1
Heat(10)  | m1 | reproduce.sh Heat 1 10 3600 0 | reproduce.sh Heat 1 10 3600 1
Heat(10)  | m2 | reproduce.sh Heat 2 10 3600 0 | reproduce.sh Heat 2 10 3600 1
Heat(10)  | m3 | reproduce.sh Heat 3 10 3600 0 | reproduce.sh Heat 3 10 3600 1
Heat(10)  | m4 | reproduce.sh Heat 4 10 3600 0 | reproduce.sh Heat 4 10 3600 1
Heat(10)  | m5 | reproduce.sh Heat 5 10 3600 0 | reproduce.sh Heat 5 10 3600 1
Mandelbrot(6)  | o | reproduce.sh Mandelbrot 0 6 3600 0 | reproduce.sh Mandelbrot 0 6 3600 1
Mandelbrot(6)  | m1 | reproduce.sh Mandelbrot 1 6 3600 0 | reproduce.sh Mandelbrot 1 6 3600 1
Mandelbrot(6)  | m2 | reproduce.sh Mandelbrot 2 6 3600 0 | reproduce.sh Mandelbrot 2 6 3600 1
Mandelbrot(6)  | m3 | reproduce.sh Mandelbrot 3 6 3600 0 | reproduce.sh Mandelbrot 3 6 3600 1
Mandelbrot(8)  | o | reproduce.sh Mandelbrot 0 8 3600 0 | reproduce.sh Mandelbrot 0 8 3600 1
Mandelbrot(8)  | m1 | reproduce.sh Mandelbrot 1 8 3600 0 | reproduce.sh Mandelbrot 1 8 3600 1
Mandelbrot(8)  | m2 | reproduce.sh Mandelbrot 2 8 3600 0 | reproduce.sh Mandelbrot 2 8 3600 1
Mandelbrot(8)  | m3 | reproduce.sh Mandelbrot 3 8 3600 0 | reproduce.sh Mandelbrot 3 8 3600 1
Mandelbrot(10)  | o | reproduce.sh Mandelbrot 0 10 3600 0 | reproduce.sh Mandelbrot 0 10 3600 1
Mandelbrot(10)  | m1 | reproduce.sh Mandelbrot 1 10 3600 0 | reproduce.sh Mandelbrot 1 10 3600 1
Mandelbrot(10)  | m2 | reproduce.sh Mandelbrot 2 10 3600 0 | reproduce.sh Mandelbrot 2 10 3600 1
Mandelbrot(10)  | m3 | reproduce.sh Mandelbrot 3 10 3600 0 | reproduce.sh Mandelbrot 3 10 3600 1
Mandelbrot-MS(4)  | o | reproduce.sh Mandelbrot-MS 0 4 3600 0 | reproduce.sh Mandelbrot-MS 0 4 3600 1
Mandelbrot-MS(6)  | o | reproduce.sh Mandelbrot-MS 0 6 3600 0 | reproduce.sh Mandelbrot-MS 0 6 3600 1
Sorting-MS(4)  | o | reproduce.sh Sorting-MS 0 4 3600 0 | reproduce.sh Sorting-MS 0 4 3600 1
Sorting-MS(6)  | o | reproduce.sh Sorting-MS 0 6 3600 0 | reproduce.sh Sorting-MS 0 6 3600 1
Image_mani(6)  | o | reproduce.sh Image_mani 0 6 3600 0 | reproduce.sh Image_mani 0 6 3600 1
Image_mani(6)  | m1 | reproduce.sh Image_mani 1 6 3600 0 | reproduce.sh Image_mani 1 6 3600 1
Image_mani(8)  | o | reproduce.sh Image_mani 0 8 3600 0 | reproduce.sh Image_mani 0 8 3600 1
Image_mani(8)  | m1 | reproduce.sh Image_mani 1 8 3600 0 | reproduce.sh Image_mani 1 8 3600 1
Image_mani(10)  | o | reproduce.sh Image_mani 0 10 3600 0 | reproduce.sh Image_mani 0 10 3600 1
Image_mani(10)  | m1 | reproduce.sh Image_mani 1 10 3600 0 | reproduce.sh Image_mani 1 10 3600 1
DepSolver(6)  | o | reproduce.sh DepSolver 0 6 3600 0 | reproduce.sh DepSolver 0 6 3600 1
DepSolver(8)  | o | reproduce.sh DepSolver 0 8 3600 0 | reproduce.sh DepSolver 0 8 3600 1
DepSolver(10)  | o | reproduce.sh DepSolver 0 10 3600 0 | reproduce.sh DepSolver 0 10 3600 1
Kfray(6)  | o | reproduce.sh Kfray 0 6 3600 0 | reproduce.sh Kfray 0 6 3600 1
Kfray(6)  | m1 | reproduce.sh Kfray 1 6 3600 0 | reproduce.sh Kfray 1 6 3600 1
Kfray(6)  | m2 | reproduce.sh Kfray 2 6 3600 0 | reproduce.sh Kfray 2 6 3600 1
Kfray(6)  | m3 | reproduce.sh Kfray 3 6 3600 0 | reproduce.sh Kfray 3 6 3600 1
Kfray(8)  | o | reproduce.sh Kfray 0 8 3600 0 | reproduce.sh Kfray 0 8 3600 1
Kfray(8)  | m1 | reproduce.sh Kfray 1 8 3600 0 | reproduce.sh Kfray 1 8 3600 1
Kfray(8)  | m2 | reproduce.sh Kfray 2 8 3600 0 | reproduce.sh Kfray 2 8 3600 1
Kfray(8)  | m3 | reproduce.sh Kfray 3 8 3600 0 | reproduce.sh Kfray 3 8 3600 1
Kfray(10)  | o | reproduce.sh Kfray 0 10 3600 0 | reproduce.sh Kfray 0 10 3600 1
Kfray(10)  | m1 | reproduce.sh Kfray 1 10 3600 0 | reproduce.sh Kfray 1 10 3600 1
Kfray(10)  | m2 | reproduce.sh Kfray 2 10 3600 0 | reproduce.sh Kfray 2 10 3600 1
Kfray(10)  | m3 | reproduce.sh Kfray 3 10 3600 0 | reproduce.sh Kfray 3 10 3600 1
Kfray-MS(6)  | o | reproduce.sh Kfray-MS 0 6 3600 0 | reproduce.sh Kfray-MS 0 6 3600 1
Kfray-MS(8)  | o | reproduce.sh Kfray-MS 0 8 3600 0 | reproduce.sh Kfray-MS 0 8 3600 1
Kfray-MS(10)  | o | reproduce.sh Kfray-MS 0 10 3600 0 | reproduce.sh Kfray-MS 0 10 3600 1
Clustalw(6)  | o | reproduce.sh Clustalw 0 6 3600 0 | reproduce.sh Clustalw 0 6 3600 1
Clustalw(6)  | m1 | reproduce.sh Clustalw 1 6 3600 0 | reproduce.sh Clustalw 1 6 3600 1
Clustalw(6)  | m2 | reproduce.sh Clustalw 2 6 3600 0 | reproduce.sh Clustalw 2 6 3600 1
Clustalw(6)  | m3 | reproduce.sh Clustalw 3 6 3600 0 | reproduce.sh Clustalw 3 6 3600 1
Clustalw(6)  | m4 | reproduce.sh Clustalw 4 6 3600 0 | reproduce.sh Clustalw 4 6 3600 1
Clustalw(6)  | m5 | reproduce.sh Clustalw 5 6 3600 0 | reproduce.sh Clustalw 5 6 3600 1
Clustalw(8)  | o | reproduce.sh Clustalw 0 8 3600 0 | reproduce.sh Clustalw 0 6 3600 1
Clustalw(8)  | m1 | reproduce.sh Clustalw 1 8 3600 0 | reproduce.sh Clustalw 1 8 3600 1
Clustalw(8)  | m2 | reproduce.sh Clustalw 2 8 3600 0 | reproduce.sh Clustalw 2 8 3600 1
Clustalw(8)  | m3 | reproduce.sh Clustalw 3 8 3600 0 | reproduce.sh Clustalw 3 8 3600 1
Clustalw(8)  | m4 | reproduce.sh Clustalw 4 8 3600 0 | reproduce.sh Clustalw 4 8 3600 1
Clustalw(8)  | m5 | reproduce.sh Clustalw 5 8 3600 0 | reproduce.sh Clustalw 5 8 3600 1
Clustalw(10)  | o | reproduce.sh Clustalw 0 10 3600 0 | reproduce.sh Clustalw 0 10 3600 1
Clustalw(10)  | m1 | reproduce.sh Clustalw 1 10 3600 0 | reproduce.sh Clustalw 1 10 3600 1
Clustalw(10)  | m2 | reproduce.sh Clustalw 2 10 3600 0 | reproduce.sh Clustalw 2 10 3600 1
Clustalw(10)  | m3 | reproduce.sh Clustalw 3 10 3600 0 | reproduce.sh Clustalw 3 10 3600 1
Clustalw(10)  | m4 | reproduce.sh Clustalw 4 10 3600 0 | reproduce.sh Clustalw 4 10 3600 1
Clustalw(10)  | m5 | reproduce.sh Clustalw 5 10 3600 0 | reproduce.sh Clustalw 5 10 3600 1


If you run any command in the above table, MPI-SV generates the log file of the verification task in the following file.
```
/root/mpi-sv/Artifact-Benchmark/script-all/result_<program_name>/mut<mutate_flag>_process<process_num>_opt<opt_flag>.log
```

For example, if you want to reproduce the result of verifying the program DTG (original version) in 5 processes by **pure symbolic execution**. You can run the following command.
```
reproduce.sh DTG 0 5 3600 0
```
After a few seconds, when the command finishes, you can view the following result：

```
-----------------Benchmark Information------------------
Program_name: DTG
Mutate_flag: 0
process_num: 5
Time_limit: 3600
Mode: pure symbolic execution

-------------------Output Information------------------
MPI-SV: totally 3 iterations
Timecost: real 8.65 (**the time information may be different**)
Deadlock: no
```
It indicates that there are 3 iterations in total. The verification time is 8.65s, and there is no deadlock. 

You can view the detailed result by the following command.
```
cat /root/mpi-sv/Artifact-Benchmark/script-all/result_DTG/mut0_process5_opt0.log
```


### Reproduce the results (**only the ones with the verification time that is less than 5 minutes**) of the finished verification tasks in Table 2

First, run the docker image and mount your current directory as **/host** for copying the result excel file.
```
docker run -it -v $(pwd):/host mpisv/mpi-sv
```

Then, run the following commands for reproducing the results with the verification time that is less than 5 minutes (we exclude Clustalw (m3, 6, 1) because of the randomness). You can control the number of processes in parallel by providing a parameter for run.sh (e.g., 1, 2, ...), depending on your computer's configuration. **In our experience, this command needs more than 1 hour and more than 15 minutes to finish with 1 process and 8 processes (on a server that has 8 cores (Intel(R) Xeon(R) CPU E5-2682 v4 @ 2.50GHz) and 64G memory), respectively. We suggest to run it in 1 process.** 

```
cd /root/mpi-sv/Artifact-Benchmark/script-5min/5_min
./run.sh 1
```
* Some verification tasks may be killed by "ctrl-C" when running the above command, which will influence the experimental results. You can use the following commands to check whether the problem exists.
```
cd /root/mpi-sv/Artifact-Benchmark/script-5min
./ctrlC-detect.sh
```
* For those verification tasks killed "ctrl-C", you can find them in the file "/root/mpi-sv/Artifact-Benchmark/script-5min/rerun_list", which looks like:
```
DTG 0 5 3600 0
Integrate 1 8 3600 1
```
* Then, if there do exist the tasks killed unexpectedly, you can use the following commands to rerun these verification tasks after **setting the parameters "Nproc" (number of current tasks) and "total_mission" (total number of tasks that are killed by ctrl-C, i.e., the number of lines in rerun_list) in /root/mpi-sv/Artifact-Benchmark/script-5min/rerun_list**.
```
cd /root/mpi-sv/Artifact-Benchmark/script-5min
./ctrlC-rerun.sh
```

After successfully running the reproducing command (i.e., all the task are completed successfully), you can extract the information from these log files by running the following commands:
```
cd /root/mpi-sv/Artifact-Benchmark/script-5min/5_min
./collect_all.sh
```

and further obtain the excel file containing all the results by runing the following commands:
```
cd /root/mpi-sv/Artifact-Benchmark/script-5min
python3 collect-5.py
```
You can copy the generated excel file (**5-min.xls**) to your host directory. The excel file of the results (also only containing the ones with the verfication time less than 5 minutes) in the paper is avaiable at this [link](https://docs.google.com/spreadsheets/d/1y3muTvDS8adB4ug0-wfFzzhGYShJduql9x5Xkf-JY3o/edit?usp=sharing).
```
cp /root/mpi-sv/Artifact-Benchmark/script-5min/5-min.xls /host
```
The detailed log files can be found in **/root/mpi-sv/Artifact-Benchmark/script-5min**. Same as before, the template of the log file names is as follows.
```
/root/mpi-sv/Artifact-Benchmark/script-5min/result_<program_name>/mut<mutate_flag>_process<process_num>_opt<opt_flag>.log
```

### Reproduce the results of LTL temporal property verification (Section 5: Temporal properties: Page 10)

You can run the following command to verify **Integrate** in 6 processes with respect to a temproal property (/root/mpi-sv/Artifact-Benchmark/integrate/ltl) using pure symbolic execution.
```
mpisv 6 -ltl-property=/root/mpi-sv/Artifact-Benchmark/integrate/ltl /root/mpi-sv/Artifact-Benchmark/integrate/integrate_mw.o
```
The LTL property is
```
p1 = Recv(1,0)
p2 = Recv(3,0)
U ! p2 p1
```
The property requires the action of process 3 receving a meesage from process 0 should not happen before the action of process 1 receving a message from process 0. Please refer to this [link](https://mpi-sv.github.io/manual) for the format of LTL property file. 

The last few lines in the verification result of using pure symbolic execution are as follows.
```
MPI-SV: totally 120 iterations
No Violation detected by MPI-SV
Different Pcs: 1
```

Then, we use MPI-SV with model-checking based boosting to do it again by the following command.
```
mpisv 6 -use-directeddfs-search -wild-opt -ltl-property=/root/mpi-sv/Artifact-Benchmark/integrate/ltl /root/mpi-sv/Artifact-Benchmark/integrate/integrate_mw.o
```
The last few lines of the verification result is as follows.
```
I0109 04:11:22.634057  5073 analysis.cpp:115] /root/PAT_Result5073_1.txt
I0109 04:11:22.634210  5073 analysis.cpp:123] =======================================================
Assertion: P() deadlockfree
********Verification Result********
The Assertion (P() deadlockfree) is VALID.

********Verification Setting********
Admissible Behavior: All
Search Engine: First Witness Trace using Depth First Search
System Abstraction: False


********Verification Statistics********
Visited States:1146
Total Transitions:4246
Time Used:0.0465975s
Estimated Memory Used:20901.888KB


=======================================================
Assertion: P() |= (!"D0_2?2" U "D0_0?0")
********Verification Result********
The Assertion (P() |= (!"D0_2?2" U "D0_0?0")) is NOT valid.
A counterexample is presented as follows.
<init -> D0_0!0 -> D0_1!1 -> D0_1?1 -> D2_0!0 -> D0_2!2 -> D0_2?2 -> D3_0!0 -> D0_0?0 -> D1_0!0 -> D0_3!3 -> D0_3?3 -> D4_0!0 -> D0_4!4 -> D0_4?4 -> D5_0!0 -> D5_0?0 -> D4_0?0 -> D3_0?0 -> D2_0?0 -> D1_0?0 -> terminate>

********Verification Setting********
Admissible Behavior: All
Search Engine: Loop Existence Checking - The negation of the LTL formula is a safety property!
System Abstraction: False
Fairness: no fairness


********Verification Statistics********
Visited States:22
Total Transitions:53
Time Used:0.002615s
Estimated Memory Used:8560.64KB





MPI-SV: totally 1 iterations
MPI-SV: find a violation in the 1 iterations
Different Pcs: 1
```

**It indicates that the violation of the LTL property can only be found after employing model-checking based boosting; also, pure symbolic execution fails to detect the violation**.

Same as Integrate, we can reproduce the result of verifying **Mandelbrot** in 6 processes with respect to the following LTL property, which is similar to the before LTL property (/root/mpi-sv/Artifact-Benchmark/bitmap/ltl).
```
p1 = Recv(1,0)
p2 = Recv(2,0)
U ! p2 p1
```
The command of using MPI-SV with model-checking based boosting is as follows.
```
mpisv 6 -use-directeddfs-search -wild-opt -ltl-property=/root/mpi-sv/Artifact-Benchmark/bitmap/ltl /root/mpi-sv/Artifact-Benchmark/bitmap/mandel_bitmap_ori2.o -unsafe
```
The result is expected as follows.
```
I0109 04:09:56.714808  5064 analysis.cpp:115] /root/PAT_Result5064_1.txt
I0109 04:09:56.714992  5064 analysis.cpp:123] =======================================================
Assertion: P() deadlockfree
********Verification Result********
The Assertion (P() deadlockfree) is VALID.

********Verification Setting********
Admissible Behavior: All
Search Engine: First Witness Trace using Depth First Search
System Abstraction: False


********Verification Statistics********
Visited States:427
Total Transitions:1426
Time Used:0.0310009s
Estimated Memory Used:12107.776KB


=======================================================
Assertion: P() |= (!"D0_1?1" U "D0_0?0")
********Verification Result********
The Assertion (P() |= (!"D0_1?1" U "D0_0?0")) is NOT valid.
A counterexample is presented as follows.
<init -> D0_0!0 -> D0_1!1 -> D0_1?1 -> D2_0!0 -> D0_0?0 -> D1_0!0 -> D0_2!2 -> D0_2?2 -> D0_3!3 -> D0_3?3 -> D0_4!4 -> D0_4?4 -> D0_5!5 -> D0_5?5 -> D0_6!6 -> D0_6?6 -> D2_0?0 -> D1_0?0 -> B -> terminate>

********Verification Setting********
Admissible Behavior: All
Search Engine: Loop Existence Checking - The negation of the LTL formula is a safety property!
System Abstraction: False
Fairness: no fairness


********Verification Statistics********
Visited States:21
Total Transitions:34
Time Used:0.0024805s
Estimated Memory Used:8552.448KB


=======================================================
Assertion: P() |= (!"D0_1?1" U "D0_2?2")
********Verification Result********
The Assertion (P() |= (!"D0_1?1" U "D0_2?2")) is NOT valid.
A counterexample is presented as follows.
<init -> D0_0!0 -> D0_0?0 -> D1_0!0 -> D0_1!1 -> D0_1?1 -> D2_0!0 -> D0_2!2 -> D0_2?2 -> D0_3!3 -> D0_3?3 -> D0_4!4 -> D0_4?4 -> D0_5!5 -> D0_5?5 -> D0_6!6 -> D0_6?6 -> D2_0?0 -> D1_0?0 -> B -> terminate>

********Verification Setting********
Admissible Behavior: All
Search Engine: Loop Existence Checking - The negation of the LTL formula is a safety property!
System Abstraction: False
Fairness: no fairness


********Verification Statistics********
Visited States:21
Total Transitions:31
Time Used:0.0009139s
Estimated Memory Used:8556.544KB





MPI-SV: totally 1 iterations
MPI-SV: find a violation in the 1 iterations
Different Pcs: 1
```
MPI-SV finds the violation at the first iteration. The command of using MPI-SV in pure symbolic execution is as follows.
```
mpisv 6 -max-time=3600 -ltl-property=/root/mpi-sv/Artifact-Benchmark/bitmap/ltl /root/mpi-sv/Artifact-Benchmark/bitmap/mandel_bitmap_ori2.o -unsafe
```
Same as the verification task for just deadlock-freedom, this verification task will time out in 1 hour and cannot find any violation. We suggest to set the max-time to be 5 minutes to have a try in case 1 hour is too long.
```
mpisv 6 -max-time=300 -ltl-property=/root/mpi-sv/Artifact-Benchmark/bitmap/ltl /root/mpi-sv/Artifact-Benchmark/bitmap/mandel_bitmap_ori2.o -unsafe
```

### Reproduce the results of all the verification tasks (**with a very long time**) in Table 2

First, run the docker image and mount your current directory as **/host** for copying the result excel file.
```
docker run -it -v $(pwd):/host mpisv/mpi-sv
```

Then, run the following commands for reproducing the results of all the verification tasks in Table 2. You can control the number of processes in parallel by providing a parameter for run.sh (e.g., 1, 2, ...). **This command will run verification tasks concurrently in 8 processes. It needs more than 8 hours on our experiment server that has 8 cores (Intel(R) Xeon(R) CPU E5-2682 v4 @ 2.50GHz) and 64G memory.**
```
cd /root/mpi-sv/Artifact-Benchmark/script-all/ALL
./run.sh 8
```

* Some verification tasks may be killed by "ctrl-C" when running the above command, which will influence the experimental results. You can use the following commands to check whether the problem exists.
```
cd /root/mpi-sv/Artifact-Benchmark/script-all
./ctrlC-detect.sh
```
* For those verification tasks killed "ctrl-C", you can find them in the file "/root/mpi-sv/Artifact-Benchmark/script-all/rerun_list", which looks like:
```
DTG 0 5 3600 0
Integrate 1 8 3600 1
```
* Then, if there do exist the tasks killed unexpectedly, you can use the following commands to rerun these verification tasks after **setting the parameters "Nproc" (number of current tasks) and "total_mission" (total number of tasks that are killed by ctrl-C, i.e., the number of lines in rerun_list) in /root/mpi-sv/Artifact-Benchmark/script-all/rerun_list**.
```
cd /root/mpi-sv/Artifact-Benchmark/script-all
./ctrlC-rerun.sh
```

After successfully running the reproducing command (i.e., all the task are completed successfully), you can extract the information from these log files by running the following commands:
```
cd /root/mpi-sv/Artifact-Benchmark/script-all/ALL
./collect_all.sh
```

and further obtain the excel file containing all the results by runing the following commands:
```
cd /root/mpi-sv/Artifact-Benchmark/script-all
python3 collect-all.py
```
You can copy the generated excel file (**all.xls**) to your host directory. The excel files (we carried out 3 times and calculate the average values) of the results in the paper are avaiable at this [link](https://drive.google.com/drive/folders/1YwHOvdjKO7Dryf9bYFoL58NaJimbXGhn?usp=sharing).
```
cp /root/mpi-sv/Artifact-Benchmark/script-all/all.xls /host
```
The detailed log files can be found in **/root/mpi-sv/Artifact-Benchmark/script-all**. Same as before, the template of the log file names is as follows.
```
/root/mpi-sv/Artifact-Benchmark/script-all/result_<program_name>/mut<mutate_flag>_process<process_num>_opt<opt_flag>.log
```