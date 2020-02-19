## Requirement ##
The following is required to set up TimeMachine:
* at least 100 GB hard drive 
* 8 GB memory
* Ububntu 16.04 64-bit

## Install ##

### Step 1: clone repository ###
```
git clone https://github.com/DroidTest/TimeMachine.git
```
### Step 2: install dependencies ###

install and configure docker 
```
sudo apt-get install docker.io
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker 
```

### step 3: build an docker image ###
```
docker build -t droidtest/timemachine:1.0 .
```
It takes serveral minutes.

## Usage ##
TimeMachine takes as input apks instrumented with Android apps instrumenting tool [Emma](http://emma.sourceforge.net/) or [Ella](https://github.com/saswatanand/ella) (open sourced). Under folder two_apps_under_test are closed-source apks instrumented with Ella, i.e., Microsoft Word and Duolingo. Script exec-single.bash starts a testing process by creating a docker container and launching TimeMachine in the container to test the given app.     
```
cd fuzzingandroid
```
Test example apps in a container   
```
#USAGE: exec-single.bash APP_DIR OPEN_SOURCE DOCKER_IMAGE TIMEOUT [OUTPUT_PATH]

./exec-single-app.bash ../two_apps_under_test/ms_word/ 0 droidtest/timemachine:1.0 1800 ../word_output
./exec-single-app.bash ../two_apps_under_test/duolingo/ 0 droidtest/timemachine:1.0 1800 ../duolingo_output
```  

## Output ##
check method coverage
```
./compute_cov_aver.bash ../word_output/ ../two_apps_under_test/ms_word/
./compute_cov_aver.bash ../duolingo_output/ ../two_apps_under_test/duolingo/
```
check crashes
```
cat word_output/timemachine-output/crashes.log
cat duolingo_output/timemachine-output/crashes.log 
```
## Need help? ##
* If failed to connect VM, please check whether virtualbox is correctly installed. TimeMachine was tested on virtualbox 5.0.18 and virtualbox 5.1.38. 
* Contact Zhen Dong (zhendng@gmail.com) for further issues.
