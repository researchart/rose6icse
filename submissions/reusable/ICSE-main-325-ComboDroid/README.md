

# Artifact Evaluation for ComboDroid  

ComboDroid is a prototype tool to generate effective test inputs for Android apps. Please follow the instructions in `INSTALL.md` to complete the installation. All following instructions assume that we are in the ComboDroid installation directory
(`/home/combodroid` in the pre-built VM image).

Source code repository: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3666313.svg)](https://doi.org/10.5281/zenodo.3666313)  

Virtual machine repository: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3673079.svg)](https://doi.org/10.5281/zenodo.3673079)  

## 1. Running Example: Automatically Testing of Hacker News Reader

Load [`runComboDroid.sh`](runComboDroid.sh) and [`Config_runningExample.txt`](Config_runningExample.txt) to the ComboDroid installation directory (`/home/combodroid` in the provided VM image).
If you're using the provided VM image, `runComboDroid.sh` **already exists and should be replaced with the updated version**.

The easiest way to load the two additional scripts to the VM is using the *drag-n-drop* functionality of VirtualBox.
You can find guidance [here](https://www.virtualbox.org/manual/UserManual.html#guestadd-dnd).
If this does not work (due to reasons such as unsupported host environment), 
you can also load the file via the network (e.g., send yourself an email with the files as an attachment on the host and download it in the VM).

To see how ComboDroid automatically tests the unmodified Hacker News Reader APK (version 3.3) for 10 minutes (with an AVD window), just type

```bash  
bash runComboDroid.sh running-example
```

Wait for a while for running environment setup (may take ~20s to minutes). Some error messages may appear; just ignore them. Then you'll see Android device emulator (AVD) boot. The full log can be found in `Log.txt`.

```bash  
Interaction with the Android device needed, running in windowed mode
error: no emulator detected
Wait for emulator to boot
...
Emulator boot complete      <== ComboDroid starts now!
```

ComboDroid first examines the running environment and parses the options.  
For the example, following messages will show:  

```bash  
/home/combodroid/Config_runningExample.txt -v --no-startup
[ComboDroid] CoordConfig(displayWidth=1080.0, displayHeight=1920.0, minX=0.0, maxX=32767.0, minY=0.0, maxY=32767.0)
[ComboDroid] Property: package-name, value: io.github.hidroh.materialistic
[ComboDroid] Property: subject-dir, value: subjects
[ComboDroid] Property: apk-name, value: hnr.apk
[ComboDroid] Property: instrument-output-dir, value: instrumentedApks
[ComboDroid] Property: keystore-path, value: /home/combodroid/artifact/testKeyStore.jks
[ComboDroid] Property: key-alias, value: combodroid
[ComboDroid] Property: key-password, value: combodroid
[ComboDroid] Property: androidSDK-dir, value: /home/combodroid/Android
[ComboDroid] Property: android-platform-version, value: 26
[ComboDroid] Property: android-buildtool-version, value: 27.0.3
[ComboDroid] Property: ComboDroid-type, value: alpha
[ComboDroid] Property: trace-directory, value: traces
[ComboDroid] Property: running-minutes, value: 10
[ComboDroid] Property: modeling-minutes, value: 5
[ComboDroid] WARNING: unable to find startup-script proerty in the configuration file, use default value []
[ComboDroid] Property: startup-script, value: 
```  

Next, it uses Soot to instrument the apk file.  
It traverses through the apk file and finds those API calls that are likely to access shared resources.  
It instruments logging statements before these calls and also logs the name of the APIs.  
After the instrumentation, the apk file gets re-signed and pushed onto the AVD.  
During this process, the following messages will show (just ignore errors):

```bash  
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".  
SLF4J: Defaulting to no-operation (NOP) logger implementation  
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.  
Soot started on Wed Feb 19 18:55:19 CET 2020
[ComboDroid] invoking retrofit2.OkHttpCall.parseResponse is likely to access network resource
[ComboDroid] invoking retrofit2.OkHttpCall$1.callSuccess is likely to access network resource
[ComboDroid] invoking retrofit2.OkHttpCall$1.callFailure is likely to access network resource
[ComboDroid] invoking io.github.hidroh.materialistic.data.MaterialisticDatabase$ReadStory.getId is likely to read database
[ComboDroid] invoking okhttp3.Request.method is likely to access network resource
[ComboDroid] invoking androidx.preference.Preference.getContext is likely to read shared preferences
[ComboDroid] invoking okhttp3.internal.ws.RealWebSocket$1.<init> is likely to access network resource
...  
Soot finished on Wed Feb 19 18:55:32 CET 2020
Soot has run for 0 min. 13 sec.
[ComboDroid] resign the instrument app /home/combodroid/artifact/instrumentedApks/hnr.apk-Ins/hnr.apk
```  

Next, a client responsible for generating and sending events will be pushed onto the AVD, and the input generation process starts. **You should see events to be delievered to the Android app.**
For the running example, the log will look like this:  

```bash  
[ComboDroid] Events injected: 1
[ComboDroid] ## Network stats: elapsed time=25ms (0ms mobile, 0ms wifi, 25ms not connected)
[ComboDroid] In Continueous mode, re-deploy 600000 9
[ComboDroid] :Monkey: seed=1582288840024 count=1000
[ComboDroid] :AllowPackage: io.github.hidroh.materialistic
[ComboDroid] :IncludeCategory: android.intent.category.LAUNCHER
[ComboDroid] :IncludeCategory: android.intent.category.MONKEY
[ComboDroid] Power Manager says we are interactive
[ComboDroid] -Wed Feb 19 18:56:20 GMT+01:00 2020  Needs to start the app!
[ComboDroid] -Wed Feb 19 18:56:20 GMT+01:00 2020 reset trace, but the backup hasn't been used or the currentState is null, keep holding it
[ComboDroid] :Switch: #Intent;action=android.intent.action.MAIN;category=android.intent.category.LAUNCHER;launchFlags=0x10200000;component=io.github.hidroh.materialistic/.LauncherActivity;end
[ComboDroid]     // Allowing start of Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] cmp=io.github.hidroh.materialistic/.LauncherActivity } in package io.github.hidroh.materialistic
[ComboDroid]     // Allowing start of Intent { cmp=io.github.hidroh.materialistic/.ListActivity } in package io.github.hidroh.materialistic
[ComboDroid]     // activityResuming(io.github.hidroh.materialistic)
[ComboDroid] -Wed Feb 19 18:56:22 GMT+01:00 2020  read a trace with size of 146
[ComboDroid] *** WARNING *** find more than one argument for : io.github.hidroh.materialistic.Preferences.get->android.content.SharedPreferences.getBoolean#5801 shared preferences read
[ComboDroid] *** WARNING *** find more than one argument for : io.github.hidroh.materialistic.Preferences.get->android.content.SharedPreferences.getString#8796 shared preferences read
[ComboDroid] *** WARNING *** find more than one argument for : io.github.hidroh.materialistic.Preferences.get->android.content.SharedPreferences.getString#12799 shared preferences read
[ComboDroid] -Wed Feb 19 18:56:22 GMT+01:00 2020 In trace we find 482 network access, 0/0 database access, 0/0 database field access, 5/0 preference access,and 7/3 local variable access
[ComboDroid] >>>>>>>> Modeling begin step [1][113221340682]
[ComboDroid] this:Naming[6], parent:Naming[0].
[ComboDroid]   0. [000][BASE] //*[@clickable='true' or @long-clickable='true' or @checkable='true' or @scrollable='true'] -> ActionPatchNamer[TypeNamer[type,resource-id]]
[ComboDroid]   1. [000][BASE] //*[@clickable='false' and @long-clickable='false' and @checkable='false' and @scrollable='false'] -> ActionPatchNamer[EmptyNamer]
[ComboDroid]   2. [001][REFINE] //*[@class="android.widget.FrameLayout"][@resource-id=""][@enabled='true'][@clickable='true'][@checkable='false'][@long-clickable='true'][@scrollable='false'] -> ActionPatchNamer[CompoundNamer[TypeNamer[type,resource-id],IndexNamer[index]]]
[ComboDroid] -Wed Feb 19 18:56:22 GMT+01:00 2020 no previous state, record start trace
[ComboDroid] GSTG(g1): activities (1), states (1), edges (0), unvisited actions (25), visited actions (0)
[ComboDroid] GSTG is NOT updated.
[ComboDroid] GSTG state is changed.
[ComboDroid] Graph Stable Counter: graph (0), state (0), activity (0)
...
[ComboDroid] Events injected: 2947
[ComboDroid] :Sending rotation degree=0, persist=false
[ComboDroid] -Wed Feb 19 19:05:20 GMT+01:00 2020 Explored app activities:
[ComboDroid]    1 io.github.hidroh.materialistic.ComposeActivity
[ComboDroid]    2 io.github.hidroh.materialistic.ItemActivity
[ComboDroid]    3 io.github.hidroh.materialistic.LauncherActivity
[ComboDroid]    4 io.github.hidroh.materialistic.ListActivity
[ComboDroid]    5 io.github.hidroh.materialistic.UserActivity
[ComboDroid]      0  TRIVIAL_ACTIVITY
[ComboDroid]      0  SATURATED_STATE
[ComboDroid]      0  USE_BUFFER
[ComboDroid]    207  EARLY_STAGE
[ComboDroid]      0  EPSILON_GREEDY
[ComboDroid]      0  RANDOM
[ComboDroid]      0  NULL
[ComboDroid]      2  BUFFER_LOSS
[ComboDroid]     53  FILL_BUFFER
[ComboDroid]      0  BAD_STATE
[ComboDroid] -Wed Feb 19 19:05:20 GMT+01:00 2020 Total Coverage: Covered 15143 Total: 54982 Ratio: 0.27541740933396386
[ComboDroid] -Wed Feb 19 19:05:20 GMT+01:00 2020 Encounter 0 new GUIs asking for additional use cases
[ComboDroid] :Dropped: keys=0 pointers=3 trackballs=0 flips=0 rotations=0
[ComboDroid] ## Network stats: elapsed time=540798ms (0ms mobile, 0ms wifi, 540798ms not connected)
[ComboDroid] // Monkey finished
[ComboDroid] -Wed Feb 19 19:05:20 GMT+01:00 2020 print traces
[ComboDroid] Executed 10
``` 

The script runs ComboDroid for 10 minutes on the running example.
After the execution finishes, the dumped log file `Log.txt` as well as a detailed Coverage file `Coverage.xml` will be stored at the directory `result_running-example_TIMESTAMP`,  
where the `TIMESTAMP` is a 14-digit timestamp indicating the starting time of the input generation process.  
For instance, the directory can be `result_running-example_20200127141251`.  

*Note*: By the end of the execution, the script will clean up the environment.
Some errors such as `cp: cannot stat 'Coverage.xml': No such file or director` may occur.
This is expected and does not affect the execution.
  

## 2. Reproducing the Experimental Results in the Paper (Using the Pre-built VM Image)

The results can be reproduced within our provided virtual machine.  
Since two testing scenarios are presented in the paper,  
we introduce steps to reproduce the results, respectively.  

### 2.1 Running Alpha Variant of ComboDroid (Fully Automatic)


in the ComboDroid installation directory (`/home/combodroid`), run  
  

```bash  
bash runComboDroid SUBJECT alpha  
```  

to run alpha variant of ComboDroid on one `SUBJECT`,  
where `SUBJECT` is an integer in [1,17] representing a test subject used in our evaluation:  

| Index | Subject | Index | Subject |  
|:---------:|:---------:|:---------:|:---------:|  
| 1 |WordPress | 10 |Hacker News Reader |  
| 2 |AntennaPod | 11 |CallMeter |  
| 3 |K-9 Mail | 12 |SimpleTask |  
| 4 |MyExpenses | 13 |Simple Draw|  
| 5 |Wikipedia | 14 |Aard2 |  
| 6 |AnkiDroid | 15 |Workd Clock|  
| 7 |AmazeFileManager| 16 |CoolClock |  
| 8 |PocketHub | 17 |Alogcat |  
| 9 |AnyMemo |  
  

The statement coverage result will be in the file `/home/combodroid/result_SUBJECT_alpha_TIMESTAMP/Coverage.xml`
as well as the `/home/combodroid/artifact/Coverage.xml` file.  
  

### 2.2 Running Beta Variant of ComboDroid (Semi-Automatic)
  

in the ComboDroid installation directory (`/home/combodroid`), run  
  

```bash  
bash runComboDroid SUBJECT beta  
```  

to run the beta variant of ComboDroid on one `SUBJECT`,  
where `SUBJECT` is an integer in [1,10] representing a test subject used in our evaluation.  
The indices of subjects are the same as the one for the alpha variant.  
  
The statement coverage result will be in the file `/home/combodroid/result_SUBJECT_beta_TIMESTAMP/Coverage.xml`
as well as the `/home/combodroid/artifact/Coverage.xml` file.  
 
  *Note*: Due to the recent update of GitHub, its account authorization page no longer supports the browser of Android 6.0, and this makes it impossible to test most of the functionalities of PocketHub [#8] by ComboDroid's current implementation. We plan to deal with this in the short future.

## 3. Configuring ComboDroid for Testing Android Apps

To test any given app (APK), the following steps should be followed:

1. Write a configuration file;
2. At the ComboDroid installation directory (`/home/combodroid`), run
    ```bash  
    bash runComboDroid 0 PATH_TO_CONFIGURATION_FILE  
    ```
    where `PATH_TO_CONFIGURATION_FILE` is the **absolute** path to a configuration file;
3. (Optional) Provide a startup script; and 
4. (Optional) Record manual execution traces.

The execution log file `Log.txt` will be stored at the `result_0_TIMESTAMP` directory.

We describe these steps in detail.
Suppose we want to run beta variant (semi-automatically) of ComboDroid on an app, whose APK file is at `/home/combodroid/aut.apk`, for 60 minutes with a 10-minute time limit of automaton mining phase of each iteration.

### 3.1 Write a Configuration File

A configuration file for ComboDroid is a set of key-value pairs containing the following properties.

- Mandatory:  
    * `subject-dir`: the directory containing the apk file of the app under test;  
    * `apk-name`: the name of the apk file;  
    * `androidSDK-dir`: the location of the Android SDK;  
    * `instrument-output-dir`: the directory where the instrumented apk files will be stored;  
    * `android-platform-version`: the version of the Android platform for instrumentation, which is normally set to **26**;  
    * `android-build-tool-version`: the version of Android build tool for instrumentation, which is normally set to **27.0.3**;  
    * `keystore-path`: the location of the Keystore file for re-signing the apk file after instrumentation, see [Android Keystore System](https://developer.android.com/training/articles/keystore) for more details;  
    * `key-alias`: the alias of the key in the Keystore file;  
    * `key-password`: the password of the key in the Keystore file;  
    * `package-name`: the package name of the app under test;  
    * `ComboDroid-type`: the variant of ComboDroid requested to run, whose value can be:  
        - **alpha**: run the alpha variant of ComboDroid; or
        - **beta**: run the complete beta variant of ComboDroid, which (1) askes the human to provide execution traces, and (2) uses the traces for testing;  
        - **beta_record**: only ask human to record execution traces; or
        - **beta_combine**: uses existing execution traces for combining.  
    * `running-minutes`: the overall running minutes of ComboDroid; and  
    * `modeling-minutes`: the running minutes for each automaton mining phase. 
- Optional:  
    * `trace-directory`: the location of existing execution traces. Mandatory when running **beta_combine** variant of ComboDroid; and  
    * `startup-script`: the location of a startup script to perform additional initialization of the app (e.g., logging in).  
  
Examples of configuration files can be found at the `/home/combodroid/artifact/Configs_alpha` directory. 
We'll further provide detailed instructions in our public Github repo. 
In our pre-built VM image, for the example (running beta variant on the `aut.jar` apk file) you only need to copy a random example configuration file, and change the following proerties to:
  
* `subject-dir=/home/combodroid`;
* `apk-name=aut.jar`;
* `ComboDroid-type=beta`;
* `running-minutes=60`; and
* `modeling-minutes=10`.

All other properties can be left as they are.


#### 3.2 (Optinal) Provide a Startup Script

For some apps, to thoroughly exercise their functionalities, some startup operations are needed (e.g., logging in). 
If you have previously tested the app and recorded a startup script, 
you can reuse it by setting the `start-script` property in the configuration file.
If no startup script is specified in the configuration file (or the specified file could not be found), ComboDroid will ask the tester whether a startup script is needed:
```bash
No specified startup script of the file is missing, would you like to record a startup script? [yes/no]
```
If the tester enters `yes`, ComboDroid records a startup script:

1. ComboDroid first initializes the recording process and freshly starts the app;
2. After initialization, a message `Waiting for event....` will show on bash, and the tester can begin recording startup script. Currently, ComboDroid supports recording the following kinds of events:
    - GUI event: currently, ComboDroid supports touch, long touch, and straight swipe events. To record such GUI events, the tester can directly click or drag on  the screen of AVD;
    - System event: ComboDroid currently supports (1) BACK, HOME, and VOLUME key events, and (2) adb shell command. The tester can click on the buttons of AVD to record key events, and input adb shell command on bash to record adb command;
3. When all required events have been recorded, the tester can input `halt` in the bash to stop recording.

The recorded startup script is at `/home/combodroid/artifact/startup.txt`.
All events are recorded in the format of  `adb shell` command with a timestamp indicating how long after sending the previous event this event  is sent, and can be further reused. 

*Note*: After receiving each event, ComboDroid will dump the GUI layout and record the event, 
and cannot handle another event before showing `"Ready recording event, waiting for the next event`  on the bash.

### 3.3 (Optional) Record Manual Execution Traces

If the tester runs the **beta** or **beta_record** variants of the artifact such as our example, ComboDroid will ask the tester to record manual execution traces.
The process is similar to the one of recording a startup script:

1. ComboDroid first initializes the recording process and freshly starts the app;
2. After initialization, a message `Waiting for the event....` will show on bash, and the tester can begin recording execution traces. 
Besides the GUI events and the system events, when recording an execution trace the test can also specify start and end of a use case by inputting `start` and `end` on bash to specify the start and end of a use case, respectively;
   
4. When finishing recording an execution trace, the tester can input `halt` on bash to stop recording. 
ComboDroid will show `Enter 1 to start recording, 2 to quit` on the bash, asking whether the tester wants to record another trace.
The tester can either input `1` to go back to step 1 to do so, or `2` to quit recording.

The recorded traces is stored at the `/home/combodroid/artifact/traces` directory.

## 4. Usage of Tool Built from Source Code

In `INTALL.md` we introduce how to build the tool from source code.
The built tool, namely two jar files `ComboDroid.jar` and `client.jar`, 
can be directly used in our VM.
Load the two jar files to the `/home/combodroid/artifact` directory,
overriding the pre-built artifact,
and you can run it just as described in the previous sections.
 
