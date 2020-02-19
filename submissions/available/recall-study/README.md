## On the Recall of Static Call Graph Construction in Practice (Artifact)

This artifact is designed to support the replication of results obtained from the experiments presented in the paper: **[Li, Dietrich, Tahir and Fourtounis: On the Recall of Static Call Graph Construction in Practice (ICSE'20)](https://ecs.wgtn.ac.nz/foswiki/pub/Main/JensDietrich/recall.pdf)**. It has the scripts (including sources) and data to conduct the experiments, and to produce the statistics and graphs presented in this paper.

### What do Expect

This study has two particular aspects that impose challenges when trying to replicate the results. We will discuss both, and then outline how we have tried to address these issues and facilitate replication.

#### Non-deterministic Behaviour

[Flakiness](https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html) is a well-known issue in testing, and an area of active research. We found 14 of the 31 programs used in the study to have non-deterministic coverage (i.e., the number of reachable methods when executing tests *may* differ between test runs). We have encountered this behaviour in the following programs: *ApacheJMeter_core-3.1, jena-2.6.3, marauroa-3.8.1, guava-21.0, quartz-1.8.3, jrefactory-2.9.19, jfreechart-1.0.13, tomcat-7.0.2, drools-7.0.0.Beta6, fitjava-1.1, log4j-1.2.16, oscache-2.4.1, weka-3-7-9* and *htmlunit-2.8*. This issue is discussed in more detail in the paper (Section 4.6, Threats to Validity).

This issue will affect the replication of results in the sense that in some cases slightly different results will be obtained. We mitigated this by providing an environment as close as possible to the one used to conduct the original experiments, using docker. We expect the variations in the number of reachable methods to be less than 1%.


#### Time and Resources Needed

Some of the experiments conducted were extremely resource-intensive, both in terms of runtime and memory required. This is discussed in detail in the paper (see Section 4.1, in particular see Table 2).

We have mitigated this issue as follows:

1. The scripts replicating each step of our experiments are implemented so that a parameter can be used to set whether to execute the script for all programs (replicating the entire results), selected set of programs, or only for a single program (i.e., "horizontal" sampling).

2. The scripts rely on each other as some scripts require the data produced by other scripts as input, the dependencies are part of the overall process discussed in the paper (Figure 1 in the paper), and those dependencies are also listed in the Table below. In cases where runtimes were particularly long or a large memory size was required, we provide cached data that can be used to check the validity of a step without performing the entire processing pipeline for all input programs up to this point (i.e., "vertical" sampling).

### How to Access the Artifact

You can check out the artifact [here](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/)

Clone the repository: `git clone --branch 1.0.0 https://Li_Sui@bitbucket.org/Li_Sui/recall-study-artefact.git`

### Contents

The artifact package includes the following:

  1. Docker Script: `Dockerfile`
  2. Bash Scripts: `build.sh`, `property.sh`, `preAnalysis.sh`, `unreflect-tests.sh`, `runTest.sh`, `processCCTs.sh`, `runDoop.sh`, `findFNs.sh`, `addNocallsiteTag.sh`, `produceStats.sh`
  3. Ant Scripts: `clean.xml`, `ant_unreflectTest.xml`, `ant_preAnalysis.xml`, `ant_dcg.xml`, `ant_packJars.xml`
  4. R Script: `graphs.r`
  5. [Xcorpus Program](https://bitbucket.org/jensdietrich/xcorpus/src/default/): *castor-1.3.1, checkstyle-5.1, commons-collections-3.2.1, drools-7.0.0.Beta6, findbugs-1.3.9, fitjava-1.1, guava-21.0, htmlunit-2.8, informa-0.7.0-alpha2, javacc-5.0, jena-2.6.3, jFin DateMath-R1.0.1, jfreechart-1.0.13, jgrapht-0.8.1,ApacheJMeter-core-3.1, jrat-0.6, jrefactory-2.9.19, log4j-1.2.16,lucene-4.3.0, mockito-core-2.7.17, nekohtml-1.9.14, openjms-0.7.7-beta-1, oscache-2.4.1, pmd-4.2.5, quartz-1.8.3, tomcat-7.0.2, trove-2.1.0, velocity-1.6.4, wct-1.5.2, weka-3-7-9* and *mockito-core-2.7.17*.

### Structure

| File/Folder | Description |
| :-----| :---- |
|`build.sh` | main build script |
|`clean.xml`| clean the artifact|
|`property.sh` | properties|
|`Dockerfile`|docker build script|
| [libs/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/libs/) | dependencies|
|[data/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/data/)|folder for Doop caches, Doop results, raw/processed CCTs, analysis stats/graph |
|[java/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/java/)|java source code, use maven to build|
|[xcorpus/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/xcorpus/)|the 31 programs from xcorpus used in this study|
|[preAnalysis_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/preAnalysis_script/)|script for pre-analysing the xcorpus to extract nativeCallsite|
|[unreflectTests_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/unreflectTests_script/)|script for unreflect junit tests (driver construction)|
|[runTest_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/runTest_script/)|script for executing the xcorpus, including instrumention and CCT recording|
|[processCCTs_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/processCCTs_script/)|script for compressing the CCTs|
|[runDoop_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/runDoop_script/)|script to construct the call graphs with doop|
|[findFNs_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/findFNs_script/)|script to diff sets of reachable methods to detect false negatives|
|[addNocallsiteTag_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/addNocallsiteTag_script/)|script for cause analysis, revisit CCTs to find out whether the parent node of a callsite exists or not|
|[produceStats_script/](https://bitbucket.org/Li_Sui/recall-study-artefact/src/master/produceStats_script/)|script for producing various tables and charts|

### Size of the Artifact

Docker image: 4.99GB

HD space required to run the artifact: 500GB (recommended)

### Prerequisites

| Process | Script| Prerequisite Scripts | Expected runtime\* (all)| Required memory\* (all)|Deterministic?\*|
| :-----| :----: |:----: | :----: | :----: | :----: |
|pre-analysis|preAnalysis_script/preAnalysis.sh|none|10mins|16GB|Y|
|unreflect tests|unreflectTest_script/unreflect-test.sh|none|10mins|16GB|Y|
|instrument, run program, record CCTs|runTest_script/runTest.sh|preAnalysis.sh, unreflect-tests.sh|24days|16G|N|
|process CCTs|processCCTs_script/processCCTs.sh|preAnalysis.sh, unreflect-tests.sh, runTest.sh|45days|256GB|Y|
|build SCGs with Doop|runDoop_script/runDoop.sh|unreflect-tests.sh|18days|384GB|Y|
|find FNs|findFNs_script/findFNs.sh|preAnalysis.sh, unreflect-tests.sh, runTest.sh, processCCTs.sh, runDoop.sh|10mins|16GB|Y|
|add a tag to CCTs|addNocallsiteTag_script/addNocallsiteTag.sh|preAnalysis.sh, unreflect-tests.sh, runTest.sh, processCCTs.sh, runDoop.sh,findFNs.sh|12hours|64GB|Y|
|compute stats and graphs|produceStats_script/produceStats.sh|preAnalysis.sh, unreflect-tests.sh, runTest.sh, processCCTs.sh, runDoop.sh,findFNs.sh,addNocallsiteTag.sh|12hours|64GB|Y|

### Docker Usage

- Docker version: 19.03.3
- build: `docker build -t recall .` (first time build may takes 20 mins )
- run: `docker run -i -v $(realpath ./data):/recall/data -t recall` (or absolute path of ./data if the realpath utility is not available)

### Run the Artifact

\* CCTs = context call trees

\* SCGs = static call graphs

Note that running all programs is a memory intensive process. Processing CCTs for all programs may take about 45 days to complete.
We designed the artifact in a way that is possible one can run one single program for testing purposes.

- run all programs: `./build.sh`
- run a single program: `./build.sh _test` (This is a simple test program, it takes about 35 mins to complete.)
- run multiple programs: `./build.sh fitjava-1.1 javacc-5.0 jFin_DateMath-R1.0.1`
- generate statistics/graph for already processed programs: `./produceStats_script/produceStats.sh`
- clean data folder: `ant -f clean.xml clean-data` (note that all files in data folder will be deleted)
- clean Doop cache: `ant -f clean.xml clean-doop-cache`
- get CCTs only: `./preAnalysis_script/preAnalysis.sh _test && ./unreflectTests_script/unreflect-tests.sh _test && ./runTest_script/runTests.sh _test && ./processCCTs_script/processCCTs.sh _test`
- get SCGs only: `./unreflectTests_script/unreflect-tests.sh _test && ./runDoop_script/runDoop.sh _test`

### Configuration

`property.sh` contains the JVM settings used to process the raw CCTs. The default values are`-Xmx64g -Xss512m`.

The settings for running the tests are defined in `xcorpus/tools/res/commons.properties`. Default values are: `dcg.timeout=900000(15mins) dcg.maxmemory=16g`

There is no memory configuration for *Doop*. We suggest using 348GB memory. The time-out is set to 6 hours, but this can be changed in `property.sh`. The time-out settings used are discussed in the paper, Section 4.1.

### Results

After running the scripts, the results can be obtained from the following directories:

- statistics and graphs are located in `data/statsAndGraphs`
- Doop SCGs are located in `data/doop-results`
- The CCTs and the FNs (false negatives) are located in `data/processed-CCTs-data`

### Running the Entire Process for a Small Set of Programs (recommended)

Since running all programs is a memory intensive process and will take weeks to complete, for demonstration purposes, we recommend that one should run the following three programs:

- `./build.sh fitjava-1.1 javacc-5.0 jFin_DateMath-R1.0.1`  

On a test machine with an Intel Core I7 3.5GHz (64-bit 12-core x86) CPU and 64GB memory, this took ca 5 hours to run.


### Cached Data

We have included the dataset that is ready to be analysed. Raw CCTs data (before reduction) is very large (600GB). Due to its large size, we choose not to include the cache data for this step, and we provide the full dataset externally.
See the README files under `data/doop-results/lib-setup`, `data/doop-results/super-setup` and `data/processed-CCTs-data`


Corresponding Author: Li Sui (l.sui@massey.ac.nz)
