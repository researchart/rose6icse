# TimeMachine  <img align="right" src="https://zenodo.org/badge/DOI/10.5281/zenodo.3672076.svg">

TimeMachine is an automated testing tool for Android apps,  which can automatically jump to the most progressive state observed in the past when progress is slow. 

<p align="center">
<img src="https://github.com/DroidTest/TimeMachine/blob/master/illustration.jpg" width="600">
</p>

TimeMachine leverages virtualization technology such as emulator to save an app state and restore it when needed. TimeMachine identifies an app state with GUI layout and memories all discovered states. When a state is considered interesting, e.g., new code is covered, TimeMachine saves the state. Meanwhile, TimeMachine observes most-recently-visited states to check whether progress is slow, e.g., being stuck in a state loop. Once progress is considered slow, TimeMachine restores the most progressive one from saved states for further exploration so that more program behavior is exercised in a short time. 

    


<!---
The figure above demonstrates how it works. When execution keeps going through a loop state S2 -- S3 -- S4 -- S2 (see Figure (a)), TimeMachine terminates the current execution due to lack of progress, resumes the most progressive state S1 (assuming that S1 is the most progressive state among all discovered states),  and launches a new execution from state S1. When reaching state S6 via S5 (see Figure(b)), the execution gets stuck, i.e., unable to exit the state after executing a fixed amount of events. TimeMachine terminates current execution again and resumes the most progressive state S5 to launch a new execution. The whole process is automatically triggered during testing.
--->



## Architecture ##
<p align="center">
<img src="https://github.com/DroidTest/TimeMachine/blob/master/arch.jpg" width="600">
</p>

The figure above shows TimeMachine's architecture. The whole system runs in a docker container with the Ubuntu operating system. App under test is installed in an Android virtual machine. TimeMachine connects the virtual machine via ADB to test the app. Main Components are configured as followed:

* Android SDK Version 25  
* Android-x86-7.1.r2
* Virtualbox 5.1.38 or 5.0.18 
* Docker API v1.13 or above 
* Python 2.7.2

## Installation & Usage ##
Instructions on how to install and use TimeMachine to test Android apps can be found in [INSTALL.md](INSTALL.md) (or on  TimeMachine Github repo [[link](https://github.com/DroidTest/TimeMachine)].

## Tool ##
TimeMachine has been released and maintained on Github: https://github.com/DroidTest/TimeMachine

## Publication ##
```
@InProceedings{zhendong:icse:2020,
author = {Dong, Zhen and B{\"o}hme, Marcel and Cojocaru, Lucia and Roychoudhury, Abhik},
title = {Time-travel Testing of Android Apps},
booktitle = {Proceedings of the 42nd International Conference on Software Engineering},
series = {ICSE '20},
year = {2020},
pages={1-12}}

```
## Badge Application ##
The badge we appply for as well as the reasons why our artifact may deserve this badge can be found [here](STATUS.md) 

## Contacts ##
Zhen Dong (zhendng@gmail.com)


