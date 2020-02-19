
# Setup

Some of the setup requirements can be omitted depending on how far the reviewer want to go in reproducing the experiments. We included results for all steps to make it possible to proceed with the experiment from any given step. We made this possible so that reviewers can either reproduce everything or only the parts of the experiments they are interested in (due to the original experiments having a runtime of 3 full weeks).

Depending on which steps to process, the required setup is different. However, most steps will require a proper JDK installation, an ADK installation and Python3

## Atermative 1: Setup on your own system

- Install JDK: https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
- Install the ADK by going to https://developer.android.com/studio . Go to the section "Command line tools only" and download the correct package for your system. Make sure to set the environment variable `ANDROID_HOME` to the root path of your ADK installation. 
- Add the android tools to your path `export PATH=$PATH:${ANDROID_HOME}/tools/bin`
- Install all platforms with `for ((i = 10 ; i <= 28 ; i++ )); do sdkmanager "platforms;android-$i"; done` or use [sdkmanager](https://developer.android.com/studio/command-line/sdkmanager) to install some specific platforms. Required platforms depend on the apps that should be analyzed. (We've included all required platforms dirs in `platforms.tar.gz` in the root directory of the artifact. Reviewers can unzip (`tar -zxf platforms.tar.gz`) and copy them to `<ADK_ROOT>/platforms` if they do not want to install the packages themselves)
- Install required tools and python packages: 
```
apt update
apt install software-properties-common -y
add-apt-repository ppa:deadsnakes/ppa -y
apt install gcc binutils python3.7 python3.7-dev python3-pip -y
pip3 install --upgrade pip setuptools
pip3 install --upgrade cython
pip3 install --upgrade numpy pandas matplotlib-venn notebook
```

Note: Ubunutu users can also have a look into the provided Dockerfile as it is Ubunutu-based as well

## Alternative 2: Use the provided Dockerfile to create a docker image with a ready-to-use setup

- Install Docker for your system: https://docs.docker.com/install/
- Download and unzip the `heapster_artifact.tar.gz` as described in _Getting started_
- Change directory to the `Docker` folder in the extracted `ae` folder
- Inside the `Docker` directory build the image with `docker build -t heapster .`


# Getting started

As a first step, get the `heapster_artifact.tar.gz` from the [zenodo artifact repository](https://zenodo.org/record/3627973#.Xi6jnxNKhTY
) and extract it somewhere with `tar -zxf heapster_artufact.tar.gz`. It's content will be explained in the following steps.

If you decided to use the docker image, you now have to execute `docker run -it -p 8888:8888 -v $(pwd):/root/ heapster bash` in the directory where you extracted the archive (inside the top-level `ae` directory). Docker will mount the current directory to `/root` inside the container. This is where you will be working from now. Docker will also map the port 8888 from the container to your localhost so that you can access jupyther notebook at `http://localhost:8888` on your local machine if needed.

In the following, all paths are relative to the extracted `ae` directory.
If you used one of the setup alternatives above you won't need to setup anything anymore during the following steps.

## _DroidMacroBench_

_DroidMacroBench_ comprises 12 of the 200 most downloaded real-world apps from the Google Playstore, a set of heap-snapshots for this apps as used in our experiments and a labeled list of findings of the FlowDroid analyzer (located in `DroidMacroBench/groundTruth.csv`).

Since the _DroidMacroBench_ apps are proprietary apps, we are not allowed to redistribute them. We thus included a small script that downloads the apps and adds the `debuggable` flag. 

### Download Benchmarking Apps and Setting the `debuggable` Flag

This step requires a JDK installation (we used JDK 8) with tools added to the PATH (i.e., java and jarsigner command must be available). Also a Android SDK (ADK) is required for setting the `debugabble` flag for all apps.

To take snapshots from apps, the `debuggable` flag has to be set in the `AndroidManifest.xml` file. To run the script, go to the `DroidMacroBench` directory and run `sh prepare.sh`.

Note: In our initial experiments, we downloaded the apps directly from Google Playstore. Since this would require an account with a proper Android device ID, and we did not want to require reviewers to have that, we decided to use different resources that allow for downloading the apps directly in our `prepare.sh` script.

#### How-to prepare your own app

If you want to use other apps, you can also invoke the script that sets the `debuggable` flag yourself. Therefore, make sure you go to the `DroidMacroBench/make-debuggable` dir (has to be current working dir to work!) and invoke with `sh runner.sh APK_IN APK_OUT TMP_DIR` where `APK_IN` is the path to the app that should be augmented, `APK_OUT` is the path where the augmented app should be stored and `TMP_DIR` is some directory which can be used temporarily store the apps unpacked contents in.

### Extract heap-snapshots for further experiments

With `DroidMacroBench_heap_dumps`, we deliver a zip file with the heap snapshots we extracted from the _DroidMacroBench_ apps.

Make sure to unzip the file to be able to propose the actual heap snapshots to _Heapster_. 

Note: We do not include all apps and heap-snapshots in this artifact sine the space requirement is several hundred gigabytes. We only included the _DroidMacroBench_ apps and snapshots used in our experiments. We think this is a viable solution since these apps do not have labeled results which we think is the main value that _DroidMacroBench_ provides. We expect the performance measurements, for which we used them for, to be reproducible with any set of apps.
Nevertheless, we are happy to provide the missing apps and snapshots on request! 

#### How-to extract heap-snapshots yourself

This step requires an installation of the Android SDK to allow using the Android Debug Bridge (adb)

You can run `java -jar dumper-1.0-SNAPSHOT-jar-with-dependencies.jar` (located at the root directory) to start the dumper application that assists with extracting heap dumps.

The application will wait for a proper device being connected to the machine. Make sure to enable adb debugging on your device after plugging it to the computer.

Once the device was recognized by adb, the `dumper` will allow you to take snapshots at any given time of app execution. The app will shortly freeze until the snapshot was conducted and extracted from the phone. 

Created snapshots can be found in the `./out` directory in a folder corresponding to the used app.

## Running the experiments with _Heapster_

We include the script we used to execute all experiments as stated in the paper. To run the experiments, invoke `sh runEvaluation.sh` in the `evaluation-scripts` directory. This usually takes days to complete due to the vast number of setup permutations in our experiment. Also note that we run the experiments with 80GB of heap space which is usually a setting that's not applicable on personal computers.

The script expects the environment variable `ANDROID_HOME` to be set to the ADK's root directory. Call `export ANDROID_HOME=<PATH_TO_ADK>` before invoking the script.
It expects repacked apps with the `debuggable` flag set in the folder `DroidMacroBench/repacked_apps` and corresponding heap-snapshots in `DroidMacroBench_snapshots/`. If you are working with your own apps/snapshots, you can either copy them there or change the script accordingly.

To run a subset of the experiments, you can 
1. change the used heuristics to, for example, only use `snapshot_filter.FirstOnly()` in line 22 of `evaluation-scripts/evaluation.py` to only run the experiments on one snapshot per app.
2. run a single manual experiment with a setup of your choice (as described in the next section)
3. Run only on a subset of the apps by removing some from the `DroidMacroBench/repacked_apps` folder
4. do not run the experiments at all and have a look at the results directly. See `Experimental Results` section

Output will be located in the `./output` directory.

Note: Due to the non-determinism of FlowDroid, as described in the "Threads to validity" seciton, the results might vary slightly compared to the results stated in the paper.

#### Use _Heapster_ on your own

You can invoke _Heapster_ to run a taint analysis with or without heap snapshots in any of the modes described in our paper without running the whole evaluation as conducted in the paper.

Invoke `java -jar heapster-1.0-SNAPSHOT-jar-with-dependencies.jar PLATFORMS_DIR APK` to conduct a basic taint analysis without the help of heap-snapshots. `PLATFORMS_DIR` needs to be the path to your Android SDKs platforms directory, e.g., `<PATH_TO_ADK>/platforms` (make sure to install the required platforms for the apps you want to analyze). `APK` is the path to the apk file which should be analyzed.

Heapster furthermore supports the following options to run with heap-snapshots in the different modes:

```
  @Option(name = "-iterative", aliases = { "-i" },
      usage = "If set, the analsis will run on the provided snapshots seperately and merge the results of all conducted analyses. Requires heap dumps to be provided.",
      depends = { "-heapDumps" })
  private boolean iterative = false;

  @Option(name = "-staticFallback", aliases = { "-sf" },
      usage = "Instructs the analysis to fallback to static points-to information for a field, if none can be found in the heap dumps. Requires heap dumps to be provided.",
      depends = { "-heapDumps" })
  private boolean staticFallback = false;

  @Option(name = "-discriminator", aliases = { "-dis" },
      usage = "Used to separate this run from previous ones when creating the output directory")
  private String discriminator = "default";

  @Option(name = "-heapDumps", aliases = { "-d" },
      usage = "A list of heap dumps to use, separated by the systems path separator, i.e. : on unix and ; on windows.",
      metaVar = "D1:D2:D3", handler = MultiPathOptionHandler.class)
```

_Heapster_ will write the resulting output to the `./output` directory. 

## Experimental Results

### Precomputed Results

We include the results from our experiments to not require the reviewer to run the whole experiment again. 

- `Results/analysisLog.log` is the log file produced by the `evalation-scripts/runEvaluation.sh` script. It contains meta information of the conducted runs, e.g. app that is exercised, options of current run, runtime, etc. This and the `Results/output` directory are required to compute the final results
- `Results/output` is the output of _Heapster_ for each app (taint results + logs for all experiment permutations)
- `Results/all_results.csv` post-processed results extracted from the taint results and logs from `Results/output` (steps to produce this file is explained in the following section).
- The `Results` directory also contains all sorts of results that are generated by a Jupyther Notebook file `visualization.ipynb` taking the `Results/all_results.csv` as input. 
- The notebook can be started with `jupyter-notebook visualization.ipynb` (Note that Jupyter notebook has [to be installed](https://jupyter.org/install) for that). It is used to post-process and visualize the results in `Results/all_results.csv`. (If you are running the experiments form docker, user this instead: `jupyter-notebook --ip=0.0.0.0 --no-browser --allow-root visualization.ipynb` and copy the given localhost-based address into your host machines browser)

### Compute the Results on your own

After running _Heapster_, the raw results are located in the `./output` directory relative to the directory where you've run _Heapster_ from.

We also include a script that post-processes these raw results and builds the basis for the results as presented in our paper. To run the script, go to the `evaluation-scripts` directory and run `sh processOutput.sh`. This will post-process the results located in the `Results/output` directory with the help of `Results/analysisLog.log`. You can take our provided _Heapster_ output or generate it yourself and it there (You require the `Results/output` folder and the `Results/analysisLog.log` file, as well as a `DroidMacroBench/groundTruth.csv` file, if you want to get statistics on how well the analysis performed).

The final results can be found in `evaluation-scripts/analysisLog.csv` after running the `processOutput.sh` script in the very same directory.

### Source-code of the Tools

We included the source-code of _Heapster_ and the snapshot-dumper application in the `tooling-sources` directory. Both are build with Maven. Invoke `mvn package -DskipTests` to build a fat-jar like the one included in this artifact. The fat-jar can be found in the corresponding `target` folder located in the tooling's source directory.

Side-note: We plan to merge back the _Heapster_ extension to Soot into Soot's official codebase. This hasn't happened yet because we plan to make a minor refactoring of the code before that. Namely, we do not want to keep the static heap-snapshot cache (`soot.jimple.spark.SparkTransformer#dump`) which we had to introduce to prevent the cache from being released when FlowDroid releases the call-graph after each iteration of it's callback detection mechanism.