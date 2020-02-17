# Installing SLACC
SLACC can be setup from scratch on a [local machine](#setting-up-from-scratch) or a [preconfigured virtualbox](#preconfigured-image) image can be used. We would recommend the preconfigured virtualbox for prototyping and while setting up from scratch for replicating the ICSE results.

## Preconfigured Image
Setting up SLACC can be a cumbersome task. We have preset SLACC as a virtualbox image with the `CodeJam` dataset used in our study and a sample `Example` dataset which we used in the motivation section of our paper.

### Setting up
* First download the latest version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for your operating system.
* Download the virtualbox image of [SLACC](https://drive.google.com/drive/u/3/folders/1UqWRvwiSy9ILwFMEDC6_bimzP2mg9m_T).
* Open Virtualbox and import the image. `File -> Import Appliance`. Please note that the virtual box is configured for smaller experiments so it might not be ideal for large experiments like the one used in our paper.
* **Hardware Requirements**: 8GB memory, 20GB storage(dynamically expands based on source code)

### Navigating around
* Once the image is booted up, it can be logged in using the credentials
```
USER_NAME : slacc
PASS_WORD: slacc
```
* The source code is already downloaded and unpacked in the folder `~/Raise/ProgramRepair/SLACC`. Navigate into this folder
```
> cd ~/Raise/ProgramRepair/SLACC
```
* Setting up DB. Check if mongoDB is running using the command `mongo`. If not start mongoDB using
```
> sudo systemctl start mongod
```
* You are now set to use SLACC. No changes have to be made to the java or python properties. Head over to the [README](https://github.com/DynamicCodeSearch/SLACC/tree/ICSE20/README.md#running-slacc) to try out a on the `Example` dataset or the `CodeJam` dataset.


## Setting up from Scratch
Clone SLACC from github using 
```
> git clone https://github.com/DynamicCodeSearch/SLACC.git
```

### Hardware
* SLACC requires atleast 4GB of memory to function on smaller programs. Storage and number of processors vary based on the size of the targe code for clone detection.
* For the CodeJam dataset used in the paper, we used a 16 node cluster 4-core AMD opteron processor and 32GB DDR3 1333 ECCDRAM. This took around 2 hours for SLACC to identify clusters in the dataset.

### Database
* Most of the data and meta-data used by SLACC is stored in MongoDB. We use [MongoDB 3.6](https://docs.mongodb.com/manual/installation/) for our experiments but it should work on later versions as well.
* Set the environment variable **$MONGO_HOME** to the path where Mongo is installed.
* When running `mongo`, ensure its running as a daemon(background process).

### Java
* SLACC requires [JDK version 1.8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html). After downloading this version configure the environment variable **$JAVA_HOME** to the path where Java is installed.
* We also use [maven version 3.3+](https://maven.apache.org/download.cgi). Make sure you can access the maven command `mvn` form a command line window.
* We would recommend a GUI like [Intellij Idea](https://www.jetbrains.com/idea/) or [Eclipse](https://www.eclipse.org/downloads/) if you plan on editing the source code.
* The additional java dependecies can be installed by running `mvn clean install` in `SLACC/code` folder.

### Python
* We use python [2.7.6+](https://www.python.org/downloads/release/python-2716/). Make sure you can access `python` from the command line after installing python.
* For managing python packages we use [pip 9.0+](https://pip.pypa.io/en/stable/installing/). Make sure you can access `pip` from the command line after installing pip.
* To install required python libraries 
```
> cd SLACC/code
> pip install -r requirements.txt
```

### Properties
Finally the properties have to be set for Java and Python
* Open `SLACC/code/src/main/java/edu/ncsu/config/Settings.java` and set the variable `ROOT_PATH` to the parent folder where SLACC is cloned.
* Open `/SLACC/code/src/main/python/properties.py` and set the variable `ROOT_HOME` to the parent folder where SLACC is cloned.
