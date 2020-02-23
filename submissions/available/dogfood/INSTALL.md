# Install Dogfood

Download the docker image and run it:

```bash
docker pull midwinter/dogfood:v3
docker run -it --rm --device /dev/kvm dogfood:v3
```

If `kvm` are unavailable, run:

```bash
docker run -it --rm dogfood:v3
```

## Run Dogfood

Since testing file systems needs tedious labors,
we provided some ready-made artifacts to ease the burden.
We also provide comprehensive instructions step by step for further testing more file systems.

*NOTICE*: All the following commands are run under directory `/dogfood/workspace/`.

### Step-1: Building the kernel

First, we need a kernel binary and a disk containing necessary command tools (i.e., sshd).
Then, we use QEMU to run the kernel with the disk mounted.

Kernel-5.1.3 is preferred, which is the latest version when we conducted our experiments.

To ease the burden, we have prepared a compiled kernel binary and a disk,
which are located in the `objs` directory.
We also provide scripts to build a kernel from scratch in the following section.

### Step-2: Test QEMU

Since we need at least two terminals, one for QEMU console and another for normal manipulation.
Tool `tmux` is preferred to open multiple terminals:

```bash
tmux -2 # Start tmux
Ctrl+b c # Start another terminal window
Ctrl+b w # Switch between the windows; learn more from the tmux documentations
```
Open another terminal.
Now, we have two terminals and we name them as `$qemu` and `$test` (the new one), respectively.

Start QEMU virtual machine and do some initializations:

```bash
$qemu: ./ctrl start
```

```bash
$test: ./ctrl init
```

This will create a QEMU snapshot;
we can use the following commands to check it:

```bash
$test: telnet localhost 45454
$test: info snapshots # In QEMU monitor
# ctrl+] and q to quit the monitor
```

Check whether file systems are supported by the kernel

```bash
$qemu: root # Login as root
$qemu: cat /proc/filesystems
```

You should see ALL file systems to be test in the list.

### Run bug cases

All our detected bugs are provided in the `bugcase.tar.gz`.
Extract it:

```bash
tar -xzvf bugcase.tar.gz
```

Each subdirectory in the `workspace/bugcase/` presents a bug case containing files, disks, and scripts to reproduce it.

Run a bug case:

```bash
$test: ./bugcase/case-204197/trigger.sh
```

The kernel will print a core dump and reboot.

We can stop QEMU and check the log file.

```bash
$test ./ctrl stop
# check the vm.log file
```

Now `$qemu` is shutdown.
Next, we present how to build a kernel from scratch if not using the pre-built kernel.

## Compile kernels from scratch

The [instructions](https://github.com/google/syzkaller/blob/master/docs/linux/setup_ubuntu-host_qemu-vm_x86-64-kernel.md) can be viewed as a guideline to build a kernel and prepare a disk image.
Though we provide scripts to make it easier,
when confronting compiling errors, the instructions may help a lot.

### Compiling-step-1: kernel config and building

We assume the compressed kernel source is downloaded from the Internet and put in the directory `workspace/kernels`.

```bash
cd kernels
tar xf linux-5.1.3.tar.xz

cd ..
./build kernel
```

The `./workspace/build` script uses a pre-defined configuration (`workspace/kernels/Config`).
View the `./workspace/build` for more information.

NOTE that
to enable the `kcov` feature in the kernel, we need `gcc >= 9` version,
which is also provided in the `party-3th` directory.

## Install Dogfood from scratch

Though we have provided scripts and pre-built artifacts, to understand the installation comprehensively, we introduce the workflow and its dependencies of Dogfood.

### Introduction

Dogfood first uses a workload generator (implemented by Python) to produce file system call sequences;
then, it compiles the sequences into executable files (using GCC),
which are executed under a kernel containing the file system to test.

QEMU is used to run the kernel, and executable files are transferred to the kernel via SCP tool.
Then, these executables are executed and manipulate the disk formatted by the file system (by mkfs utilities).

In summary, we need the following dependencies to install:

### QEMU

```bash
sudo apt-get install -y qemu
```

### Mkfs utilities

```bash
sudo apt-get install -y btrfs-tools reiserfsprogs gfs2-utils f2fs-tools
```

Tools `mkfs.xx` should be installed.

NOTE: in Ubuntu-16.04, most of these tools can be install by `apt` directly;
however, `mkfs.f2fs` may not work; if so,
we can build it from source code that we provide in the folder `./party-3th`.

### Building tools

```bash
sudo apt-get install -y build-essential
```

### Python > 3.6

Python 3.6 is installed default in Ubuntu-18.04;
if the operating system is Ubuntu-16.04, follow the instructions [here](http://ubuntuhandbook.org/index.php/2017/07/install-python-3-6-1-in-ubuntu-16-04-lts/).

Install python packages:

```bash
pip3 install termcolor
pip3 install sklearn
```

## Issues when installing and running Dogfood

### `./ctrl start`: cannot set up guest memory 'pc.ram': Cannot allocate memory

> Try to change the parameter in the file `/dogfood/workspace/mngr-tools/mngr-lib.sh:80` `-m 4G` to a smaller value, e.g., `-m 1G`

### Pull docker image failure: no space left on device

> Try to prune unused docker images [link](https://stackoverflow.com/questions/30604846/docker-error-no-space-left-on-device)