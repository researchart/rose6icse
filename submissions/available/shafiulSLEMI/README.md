# SLEMI

We present SLEMI - a novel open source tool to automatically find compiler bugs in Simulink, the widely used cyber-physical system development tool chain.

## Requirements

- MATLAB with Simulink with all default toolboxes (i.e. choose all toolboxes when installing MATLAB).

We tested SLEMI in two environments:

### Windows 10

- MATLAB/Simulink installation version: R2018a

### Ubuntu 18.04.3 

- MATLAB/Simulink installation version: R2019a 

Please see the *Machine Configuration and Complete List of Toolboxes* section below in this page for addtional details on hardware and MATLAB toolboxes used.

## Installing SLEMI

- Please see the [INSTALL.md](INSTALL.md) file

## Video Demo

- Checkout a 5-minute introductory [demo](https://www.youtube.com/watch?v=oliPgOLT6eY&feature=youtu.be) of the tool which presents the various tool components, and also covers basic configuration.

## Running SLEMI and Other Scripts

- Please see the [INSTALL.md](INSTALL.md) file

## Reproduce Results

### Runtime Analysis Evaluation

The following steps would help in recreating the runtime analysis (RQ1 in the paper):

- Unzip the `reproduce/runtime-plot-data.zip` file and copy the `.mat` files to the `workdata` folder
- Run `covexp.addpaths(); covexp.r.scaling()` in a MATLAB prompt 

### Models Finding Bugs

The `reproduce/ModelFindingBugs.zip` file contains various Simulink models used to discover the bugs reported in the paper. We have included the models here so that interested readers can manually inspect the models.

## Machine Configuration and Complete List of Toolboxes

Here are additional details on the two environments we have tested SLEMI in:

### Windows 10 and MATLAB R2018a

#### Machine details

- Microsoft Windows 10 Home Version 10.0 (Build 18362)
- RAM: 8 GB
- Processor: Intel(R) Core(TM) i5-6200 CPU at 2.30 GHz

#### MATLAB/Simulink details

```
>> ver
-----------------------------------------------------------------------------------------------------
MATLAB Version: 9.4.0.813654 (R2018a)
Operating System: Microsoft Windows 10 Home Version 10.0 (Build 18362)
Java Version: Java 1.8.0_144-b01 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
-----------------------------------------------------------------------------------------------------
MATLAB                                                Version 9.4         (R2018a)
Simulink                                              Version 9.1         (R2018a)
Aerospace Blockset                                    Version 3.21        (R2018a)
Aerospace Toolbox                                     Version 2.21        (R2018a)
Antenna Toolbox                                       Version 3.1         (R2018a)
Audio System Toolbox                                  Version 1.4         (R2018a)
Automated Driving System Toolbox                      Version 1.2         (R2018a)
Bioinformatics Toolbox                                Version 4.10        (R2018a)
Communications System Toolbox                         Version 6.6         (R2018a)
Computer Vision System Toolbox                        Version 8.1         (R2018a)
Control System Toolbox                                Version 10.4        (R2018a)
Curve Fitting Toolbox                                 Version 3.5.7       (R2018a)
DSP System Toolbox                                    Version 9.6         (R2018a)
Data Acquisition Toolbox                              Version 3.13        (R2018a)
Database Toolbox                                      Version 8.1         (R2018a)
Datafeed Toolbox                                      Version 5.7         (R2018a)
Drive Cycles Blockset                                 Version 1.0         (R2012a)
Econometrics Toolbox                                  Version 5.0         (R2018a)
Embedded Coder                                        Version 7.0         (R2018a)
Filter Design HDL Coder                               Version 3.1.3       (R2018a)
Financial Instruments Toolbox                         Version 2.7         (R2018a)
Financial Toolbox                                     Version 5.11        (R2018a)
Fixed-Point Designer                                  Version 6.1         (R2018a)
Fuzzy Logic Toolbox                                   Version 2.3.1       (R2018a)
GPU Coder                                             Version 1.1         (R2018a)
Global Optimization Toolbox                           Version 3.4.4       (R2018a)
HDL Coder                                             Version 3.12        (R2018a)
HDL Verifier                                          Version 5.4         (R2018a)
Image Acquisition Toolbox                             Version 5.4         (R2018a)
Image Processing Toolbox                              Version 10.2        (R2018a)
Instrument Control Toolbox                            Version 3.13        (R2018a)
LTE HDL Toolbox                                       Version 1.1         (R2018a)
LTE System Toolbox                                    Version 2.6         (R2018a)
MATLAB Coder                                          Version 4.0         (R2018a)
MATLAB Compiler                                       Version 6.6         (R2018a)
MATLAB Compiler SDK                                   Version 6.5         (R2018a)
MATLAB Report Generator                               Version 5.4         (R2018a)
Mapping Toolbox                                       Version 4.6         (R2018a)
Model Predictive Control Toolbox                      Version 6.1         (R2018a)
Model-Based Calibration Toolbox                       Version 5.4         (R2018a)
Neural Network Toolbox                                Version 11.1        (R2018a)
OPC Toolbox                                           Version 4.0.5       (R2018a)
Optimization Toolbox                                  Version 8.1         (R2018a)
Parallel Computing Toolbox                            Version 6.12        (R2018a)
Partial Differential Equation Toolbox                 Version 3.0         (R2018a)
Phased Array System Toolbox                           Version 3.6         (R2018a)
Polyspace Bug Finder                                  Version 2.5         (R2018a)
Polyspace Code Prover                                 Version 9.9         (R2018a)
Powertrain Blockset                                   Version 1.3         (R2018a)
Predictive Maintenance Toolbox                        Version 1.0         (R2018a)
RF Blockset                                           Version 7.0         (R2018a)
RF Toolbox                                            Version 3.4         (R2018a)
Risk Management Toolbox                               Version 1.3         (R2018a)
Robotics System Toolbox                               Version 2.0         (R2018a)
Robust Control Toolbox                                Version 6.4.1       (R2018a)
Signal Processing Toolbox                             Version 8.0         (R2018a)
SimBiology                                            Version 5.8         (R2018a)
SimEvents                                             Version 5.4         (R2018a)
Simscape                                              Version 4.4         (R2018a)
Simscape Driveline                                    Version 2.14        (R2018a)
Simscape Fluids                                       Version 2.4         (R2018a)
Simscape Multibody                                    Version 5.2         (R2018a)
Simscape Power Systems                                Version 6.9         (R2018a)
Simulink 3D Animation                                 Version 8.0         (R2018a)
Simulink Check                                        Version 4.1         (R2018a)
Simulink Code Inspector                               Version 3.2         (R2018a)
Simulink Coder                                        Version 8.14        (R2018a)
Simulink Control Design                               Version 5.1         (R2018a)
Simulink Coverage                                     Version 4.1         (R2018a)
Simulink Design Optimization                          Version 3.4         (R2018a)
Simulink Design Verifier                              Version 3.5         (R2018a)
Simulink Desktop Real-Time                            Version 5.6         (R2018a)
Simulink PLC Coder                                    Version 2.5         (R2018a)
Simulink Real-Time                                    Version 6.8         (R2018a)
Simulink Report Generator                             Version 5.4         (R2018a)
Simulink Requirements                                 Version 1.1         (R2018a)
Simulink Test                                         Version 2.4         (R2018a)
Spreadsheet Link                                      Version 3.3.3       (R2018a)
Stateflow                                             Version 9.1         (R2018a)
Statistics and Machine Learning Toolbox               Version 11.3        (R2018a)
Symbolic Math Toolbox                                 Version 8.1         (R2018a)
System Identification Toolbox                         Version 9.8         (R2018a)
Text Analytics Toolbox                                Version 1.1         (R2018a)
Trading Toolbox                                       Version 3.4         (R2018a)
Vehicle Dynamics Blockset                             Version 1.0         (R2018a)
Vehicle Network Toolbox                               Version 4.0         (R2018a)
Vision HDL Toolbox                                    Version 1.6         (R2018a)
WLAN System Toolbox                                   Version 1.5         (R2018a)
Wavelet Toolbox                                       Version 5.0         (R2018a)
```

### Ubuntu 18.04.3  and MATLAB R2019a



#### Machine details

- Ubuntu 18.04.3 LTS
- RAM: 16 GB
- Processor: Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz

#### MATLAB/Simulink details


```
>> ver
-----------------------------------------------------------------------------------------------------
MATLAB Version: 9.6.0.1072779 (R2019a)
Operating System: Linux 4.15.0-74-generic #84-Ubuntu SMP 
Java Version: Java 1.8.0_181-b13 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
-----------------------------------------------------------------------------------------------------
MATLAB                                                Version 9.6         (R2019a)
Simulink                                              Version 9.3         (R2019a)
Control System Toolbox                                Version 10.6        (R2019a)
DSP System Toolbox                                    Version 9.8         (R2019a)
Image Processing Toolbox                              Version 10.4        (R2019a)
Instrument Control Toolbox                            Version 4.0         (R2019a)
Optimization Toolbox                                  Version 8.3         (R2019a)
Parallel Computing Toolbox                            Version 7.0         (R2019a)
Signal Processing Toolbox                             Version 8.2         (R2019a)
Simulink Check                                        Version 4.3         (R2019a)
Simulink Control Design                               Version 5.3         (R2019a)
Simulink Coverage                                     Version 4.3         (R2019a)
Statistics and Machine Learning Toolbox               Version 11.5        (R2019a)
Symbolic Math Toolbox                                 Version 8.3         (R2019a)
```


