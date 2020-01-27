## 1 Use the Existing Virtual Machine Image

### (1)  Download and intall [VMware Workstation Player 15](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html). 
	 
> The free version is available for non-commercial use. 

### (2) Download the compressed image of our virtual machine [Ubuntu16.04.vmx](https://drive.google.com/file/d/1MnK8p9TcZIYDOr9hZKJOoL50cldv0J7W/view?usp=sharing)  and uncompress it.

> Ubuntu16.04(Password_123456).tar.bz2

### (3) Use VMware Workstation Player 15 to open the uncompressed virtual machine Ubuntu16.04.vmx.

> The **password** to login is **123456**



## 2 How to Rebuild From Scratch

We have installed our tool (BARRA) on the virtual machine [Ubuntu16.04.vmx](https://drive.google.com/file/d/1MnK8p9TcZIYDOr9hZKJOoL50cldv0J7W/view?usp=sharing).
If you want to rebuild it from scratch, please do it on Ubuntu 16.04 as follows.
For convenience, you can delete the ~/src directory in our virtual machine and reuse it for this purpose.

### (1) Requirement:  pip, wllvm, gcc-multilib, g++-multilib, git 

```sh
barra@ubuntu:~$ sudo apt install python-pip
barra@ubuntu:~$ sudo pip install wllvm
barra@ubuntu:~$ sudo apt-get install gcc-multilib g++-multilib
barra@ubuntu:~$ sudo apt-get install git
```
 
### (2) Download Source Code from Github

```sh
barra@ubuntu:~$ mkdir -p src
barra@ubuntu:~$ cd src
barra@ubuntu:~/src$ git clone https://github.com/sheisc/BARRA.git
```


### (3) Set Environment Variables and Build 

Suppose BARRA is stored in /home/iron/src/BARRA.
Then please use gedit to open /home/iron/src/BARRA/R4/env.sh and 
set the environment variable R4PATH to /home/iron/src/BARRA/R4
(i.e., <span style="color:red">export R4PATH=/home/iron/src/BARRA/R4</span>).
Then you can rebuild BARRA as follows.



```sh
barra@ubuntu:~/src$ cd BARRA/R4
barra@ubuntu:~/src/BARRA/R4$ . ./env.sh 
barra@ubuntu:~/src/BARRA/R4$ ./build.sh
```

