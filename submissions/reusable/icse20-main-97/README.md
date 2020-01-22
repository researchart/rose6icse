# Burn After Reading: A Shadow Stack with Microsecond-level Runtime Rerandomization for Protecting Return Addresses 

## Description

* **Paper ID**

    icse20-main-97
   
* **Authors**

     Changwei Zou, Jingling Xue
     
* **Email**

      changweiz@cse.unsw.edu.au
 
      
## How to Use


### 1. Download and intall [VMware Workstation Player 15](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html). 
	 
> The free version is available for non-commercial use. 

### 2. Download the compressed image of our virtual machine [Ubuntu16.04.vmx](https://drive.google.com/open?id=1sWEo94cdba8B-nzrXPj1ynkjVFlyspDB)  and uncompress it.

> Ubuntu16.04(ICSE2020_Artifact_Password_123456).tar.bz2 

### 3. Use VMware Workstation Player 15 to open the uncompressed virtual machine Ubuntu16.04.vmx.

> The **password** to login is **123456**

#### (1) Table 3 in our paper

```sh
    barra@ubuntu:~$ cd ~/src/R4
    barra@ubuntu:~/src/R4$ ./Table3.sh
```

#### (2) Table 1 in our paper

```sh
    barra@ubuntu:~$ cd ~/src/R4
    barra@ubuntu:~/src/R4$ ./Table1.sh
```

#### (3) Figure 10 in our paper (see ~/src/R4/Fig10.png)

    Please open 4 terminals, enter the directory ~/src/R4/echo, 
    and then follow the instructions as shown in ~/src/R4/Fig10.png.

    barra@ubuntu:~$ cd ~/src/R4/echo

#### (4) A "Hello World" example is given in ~/src/R4/example.

    Please search .unsw.randomval in the file ~/src/R4/example/main.instr.s  for some 
    of the instrumented assembly code (UNSW  is the abbreviation of University of New South Wales).

    barra@ubuntu:~$ cd ~/src/R4/example
    barra@ubuntu:~/src/R4/example$ . ../env.sh 
    barra@ubuntu:~/src/R4/example$ make

#### (5) A hook example is given in ~/src/R4/hook

```sh
    barra@ubuntu:~$ cd ~/src/R4/hook
    barra@ubuntu:~/src/R4/hook$ . ../env.sh 
    barra@ubuntu:~/src/R4/hook$ make
    barra@ubuntu:~/src/R4/hook$ ./run.sh
```

#### (6) An example to show the thread local storage of bar_randval

```sh
    barra@ubuntu:~$ cd ~/src/R4/TLS	
    barra@ubuntu:~/src/R4/TLS$ . ../env.sh 
    barra@ubuntu:~/src/R4/TLS$ make
    barra@ubuntu:~/src/R4/TLS$ ./main
```


