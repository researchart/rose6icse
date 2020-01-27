# Holmes: A Causal Testing Prototype
Holmes is a prototype implementation of Causal Testing, a novel testing technique that uses causal experiments to help developers debug Java programs. This repository contains the source code along with the user study setup and materials for the paper titled:

**Causal Testing: Understanding Defects' Root Causes** by Brittany Johnson, Yuriy Brun, and Alexandra Meliou, which will appear in the Proceedings of the 42nd International Conference on Software Engineering (ICSE) 2020.

## Pre-requisites

1. Install the [Eclipse IDE](https://www.eclipse.org/eclipseide/) and make sure you have at least Java 1.7 installed on your machine.
2. Install [Python](https://www.python.org/) and [Node.js](https://nodejs.org/en/).
3. Clone this repository.
4. Download [defects4j](https://github.com/rjust/defects4j) into the Holmes directory.**

** **Note: The version of Holmes in this repo only works with projects in the Defects4J benchmark. We are currently working on an implementation that is able to run on any JUnit test within the Eclipse IDE.**

## How to install Holmes

If you want to run or use Holmes on your own machine, you will need to do the following:

1. Import the Holmes directory into Eclipse (*File > Import... > General/Existing Projects into Workspace*).
2. Once imported, open the *RunHolmes.java* file. At the top there is a global field called **workingDirectory**. Update this variable with the path to the Holmes directory on your machine.
3. Update the paths to python and node in the fuzzing script ([Holmes/fuzzers/fuzz.sh](https://github.com/LASER-UMASS/CausalTesting-Artifact_ICSE20/blob/master/Holmes/fuzzers/fuzz.sh)) to the locations for python and node on your machine.
4. From here, you can install Holmes by either [exporting the plug-in](https://help.eclipse.org/2019-12/index.jsp?topic=%2Forg.eclipse.pde.doc.user%2Fguide%2Ftools%2Fexport_wizards%2Fexport_plugins.htm) or [installing the plug-in to your host Eclipse](https://help.eclipse.org/2019-12/index.jsp?topic=%2Forg.eclipse.pde.doc.user%2Fguide%2Ftools%2Fexport_wizards%2Fexport_plugins.htm). 

## How to use Holmes

Please reference the [README.md](https://github.com/LASER-UMASS/CausalTesting-Artifact_ICSE20/tree/master/artifact_documentation) inside the artifact_documentation directory for more details on using Holmes for debugging.
