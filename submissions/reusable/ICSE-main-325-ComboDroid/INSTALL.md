
# Install ComboDroid

Though we have provided scripts and pre-built artifacts, to understand the installation comprehensively, we introduce the workflow and its dependencies of ComboDroid.


## ComboDroid: workflow and dependencies

### TL;DR

1. Install KVM on the machine. see [Configure hardware acceleration for the Android Emulator](https://developer.android.com/studio/run/emulator-acceleration) for installing KVM on different platforms;
2. Download the ova file of the virtual machine, and run it on VirtualBox of version 6.1.2 or later, which supports nested KVM virtualization; and
3. Open an terminal in the virtual machine, and run
	```bash
	./runComboDroid.sh SUBJECT [OPTION]
	```
  	at `/home/combodroid` directory, where:

	* SUBJECT specifies which app should be tested. Enter either
		- An **integer** in [1,17] for each test subjects used in our evaluation accordingly (the order is the same as the one of Table 1 in our paper)<sup>1</sup>; or
		- **0** for additional apps the tester want to test.
	* OPTION specifies the settings to test the app.
		- For test subjects in our evaluation, enter **alpha** or **beta** to run the corresponding variant of ComboDroid, e.g.,
			```bash
			./runComboDroid.sh 2 alpha
			```
		- For additional apps, the location of a configuration file must be given 
		(See [Step-1: Prepare the configuration file](#Step-1: Prepare the configuration file) for more details),
    	e.g.,
			```bash
			./runComboDroid.sh 0 /home/combodroid/artifact/Configs_alpha/Config_Aard2.txt
			```

The testing results and logs are stored at the `/home/combodroid/result_SUBJECT_OPTION_TIMESTAMP` directory for test subjects in our evaluation 
(e.g., `/home/combodroid/results_1_beta_20200109125739`), 
or `/home/combodroid/result_0_TIMESTAMP` directory for additional apps.

<sup>1</sup> Due to the recent update of GitHub, its account authorization page no longer supports the browser of Android 6.0, and this makes it impossible to test most of the functionalities of PocketHub [#8] by ComboDroid's current implementation. We plan to deal with this in the short future.

### Introduction

ComboDroid first parses the configuration file, and instruments the apk file of the app with [Soot](https://github.com/Sable/soot) (implemented by Kotlin);
then, it installs the instrumented app on the Android device, pushes a test client (implemented by Kotlin and Java) to the device, and begins the test.

During the test, ComboDroid iterates to (1) mine an automaton of the app, either fully automatically (variant alpha) or with manual execution traces (variant beta), and extracts use cases from it, and (2) generate combos with extracted use cases.

In summary, we need the following dependencies to install and run:


### Java SDK

Currently, the Android SDK as well as ComboDroid requires Java 1.8.
See [Java SE Development Kit](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) for more information about installing and settings.

### Android SDK

To instrument the apk file, the Android SDK is required. 
Currently, the complete SDK can be downloaded within Android Studio. 
See [Android Studio](https://developer.android.com/studio?hl=en) for more information.


### Android Device

The current implementation of ComboDroid targets Android 6.0 (API-level 23).
ComboDroid can run on both emulator and real device.


## Run ComboDroid

We prepare some ready-made artifacts to reproduce our evaluation results.
We also provide comprehensive instructions step by step for testing additional Android apps.

*Notice*: All the following commands are run under directory `/home/combodroid`

### Step-1: Prepare the configuration file

*Notice*: this step is not necessary for reproducing our evaluation results.

A configuration file for ComboDroid is a set of key-value pairs containing following properties:
* Mandatory:
	* subject-dir: the folder containing the apk file of the app under test;
	* apk-name: the name of the apk file;
	* androidSDK-dir: the location of the Android SDK;
	* android-platform-version: the version of android platform for instrumentation, which is normally set to **26**;
	* android-build-tool-version: the version of android build tool for instrumentation, which is normally set to **27.0.3**;
	* keystore-path: the location of the keystore file for re-sign the apk file after instrumentation, see [Android Keystore System](https://developer.android.com/training/articles/keystore);
	* key-alias: the alias of the key in the keystore file;
	* key-password: the password of the key in the keystore file;
	* package-name: the package name of the app under test;
	* ComboDroid-type: the variant of ComboDroid requested to run, whose value can be:
		- alpha: run the alpha variant of ComboDroid;
		- beta: run the beta variant of ComboDroid, which (1) askes the human to record execution traces, and (2) uses the traces for testing;  
		- beta_record: only ask human to record execution traces; and
		- beta_combine: uses existing execution traces for testing.
	* running-minutes: the overall running minutes of ComboDroid; and
	* modeling-minutes: the running minutes for each automation mining phase.
* Optional:
	* trace-directory: the location of existing execution traces. Mandatory when running beta_combine variant of ComboDroid; and
	* startup-script: the location of a startup script to perform additional initialization of the app (e.g., logging in).

The example configuration file can be found at `/home/combodroid/artifact/Configs_alpha` directory.

### Step-2 Run the ComboDroid

Run

```bash
./runComboDroid.sh SUBJECT [OPTION]
```
where:
* SUBJECT specifies which app should be tested. Enter either
	- An **integer** in [1,17] for each test subjects used in our evaluation accordingly (the order is the same as the one of Table 1 in our paper); or
	- **0** for additional apps the tester want to test.
* OPTION specifies the settings to test the app.
	- For test subjects in our evaluation, enter **alpha** or **beta** to run the corresponding variant of ComboDroid, e.g.,
		```bash
		./runComboDroid.sh 2 alpha
		```
	- For additional apps, the location of a configuration file must be given, e.g.,
		```bash
		./runComboDroid.sh 0 /home/combodroid/artifact/Configs_alpha/Config_Aard2.txt
		```

Depending on the running variant, ComboDroid may request further interactions.

#### Providing a start-up script

If no start-up script is specified in the configuration file, ComboDroid will ask if a start-up script is needed.
If so, it will ask the tester to record such a script.
The recorded script will be stored in `/home/combodroid/artifact/startup.txt`.
Detailed information will be presented in the terminal.

#### Recording execution traces

When running beta or beta_record variant, the tester will be asked to provide execution traces. 
Detailed instructions and information will be presented in the terminal.
The recorded traces will be stored in the `/home/combodroid/traces` directory.

#### Feedback loop

If running the beta of beta_combine variant of ComboDroid, when it exhausts all possible combos or encouter enough previsouly unexplored app states, 
it will ask the tester to provide additional execution traces starting from the initial state of the newly explored ones, respectively. 
Detailed instructions and information will be presented in the terminal.

### Test results

When the test finishes, the results can be found at the `/home/combodroid/result_SUBJECT_OPTION_TIMESTAMP` directory for test subjects in our evaluation 
(e.g., `/home/combodroid/results_1_beta_20200109125739`), or `/home/combodroid/result_0_TIMESTAMP` directory for other apps, which includes:
	
* Coverage.xml: the statement coverage results of the app under test; and
* Log.txt: the complete test log file, including full execution traces and generated combos.


## Known issues

* ConcurrentModificationException: We use [Soot](https://github.com/Sable/soot) to instrument the app under test 
for recording execution traces. Soot opens multiple threads for instrumentation, and though we have strictly follow its guide lines, in rare occasions a ConcurrentModificationException can occur. We have reported it to Soot's developers.