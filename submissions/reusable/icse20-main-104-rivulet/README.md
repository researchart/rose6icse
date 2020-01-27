# Artifact for ICSE paper: Revealing Injection VUlnerabilities by Leveraging Existing Tests (RIVULET)
RIVULET is a system for detecting code injection vulnerabilities in Java web applications by combining existing JUnit tests with dynamic taint tracking and input generation. This artifact contains the code and experimental scripts for RIVULET as described in our ICSE 2020 paper.

The artifact is available at [https://doi.org/10.6084/m9.figshare.11592033](https://doi.org/10.6084/m9.figshare.11592033). The artifact should allow for replication of our experimental results (following the instructions below to execute scripts and interpet results described in our paper), and for reuse of the tool (by its general portability and documentation).

RIVULET should run out-of-the-box on any Mac or Linux environment with Java 8. However, some of the experiments involve third party applications with additional dependencies that require some manual steps to install, and if you are interested in replicating those experiments, we would strongly suggest using the provided VM (which is pre-prepared with these dependencies configured).

The artifact is organized as follows:

* rivulet.ova: A VirtualBox VM that contains all code and dependencies necessary to reproduce the experiments described in the paper. The username is rivulet, and the password is rivulet.
* rivulet-source.zip: A zip archive that contains an archive of the code to rivulet used in our paper, matching git revision `5ea0ff93a547d79167a1c121928feb31ff498901`, the same included in the VM. The code can also be downloaded from [GitHub](https://github.com/gmu-swe/rivulet).
* output.zip: A zip archive that contains the output of all of running each of our experiments
* README.md: An instruction guide that describes how to run RIVULET, and how to reproduce our experiments using the VM.


## Installation and Running Benchmarks
RIVULET relies on [Phosphor](https://github.com/gmu-swe/phosphor) to perform dynamic taint tracking of all of the application and library code in an application, and relies on JUnit tests to drive program execution. Currently, RIVULET is only compatible with applications running in a Java 8 JVM with JUnit tests that are executed by Apache Maven. If you are interested only in using RIVULET with your existing project, you can skip directly to "Using RIVULET with Existing Test Suites" and follow the instructions for "Installing for an individual project."

#### To install RIVULET:

1. Make sure that you have some version of OpenJDK 8 installed. Set the JAVA_HOME environmental variable to this path. On mac, e.g.: `export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_192-openjdk/Contents/Home/`. Our VM has this variable set correctly.
2. Clone our [GitHub](https://github.com/gmu-swe/rivulet) repository. Our VM has this repository already cloned, in the `rivulet` directory.
3. In the `rivulet` directory, run `mvn install`. This will build the project, download an extra copy of Maven, and set up that copy of Maven so that whenever tests are run with it RIVULET is used.


Optionally, run the integration tests, which include all of the benchmark workloads used in our ICSE 2020 paper (although they do *not* run the case study workloads on iTrust, Struts and Jenkins). 

* In the integration-test directory, run the tests: `mvn test`. The first time you do this, it will take some time to instrument the JRE with Phosphor (this is cached in `~/.phosphor-jvm/`). Alternatively, you can run just the benchmarks (OWASP, Juliet, WAVSEP DAST, and Securibench-Micro) using `mvn -Pbenchmarks test`. One of the benchmarks in the test suite requires a MySQL server to be running, and it will automatically download, configure, start and stop that server (it will install it to `target/mysql-dist`).

#### Notes:

* The plugin will instrument your JVM the first go-round, and store that instrumented jvm in `~/.phosphor-jvm` - if you need to change the sources/sinks etc, you will need to regenerate it (by deleting that directory). If you get `java.lang.RuntimeException: Method code too large!` during the instrumentation, it is probably OK to ignore them for now. Similarly, the plugin will cache the instrumented code for projects that you run, generally in the `target/cached-phosphor` directory of that project - a `mvn clean` will blow it away. Our VM has this JVM already instrumented.

* To play around with it: go into the `integration-test` project and inspect the tests. You will see that when the tests run, they print a "VIOLATION" when a source-sink flow is detected. The tests are then rerun. During reruns, you will see "CRITICAL VIOLATION" when a source-sink flow is verified. If you would like to write and run your own test, the easiest way to do so is to add your test method to an existing test and continue to use the `mvn test` command, perhaps running only the test that you changed, e.g. `mvn -Dtest=DeepSourceTest`. The default sources and sinks for integration tests can be found in `maven-extension/src/main/resources/config-files/integration-test/`; additional sources/sinks can be specified as annotations on a test class or test method.


## Reproducing our ICSE 2020 experiments
Our [ICSE 2020 paper](https://www.rivulet.io/rivulet.pdf) describing RIVULET includes the following experiments, which you can easily reproduce using our artifact:

### Evaluating RIVULET on Benchmarks
We evaluated RIVULET using NIST's [Juliet Benchmark version 1.3](https://samate.nist.gov/SRD/testsuite.php), [OWASP's benchmark version 1.2](https://www.owasp.org/index.php/Benchmark), [Ben Livshits' securibench-micro](https://suif.stanford.edu/~livshits/work/securibench-micro/), and [WAVSEP's benchmark version 1.5](https://sourceforge.net/projects/wavsep). Binaries of each of these benchmarks are included in this repository, and can easily be executed simply by running `mvn install` in the top level of this repository and then, in the `integration-test` directory, run `mvn -Pbenchmarks test`. Each benchmark test is represented by a JUnit test, and you can examine the output from the test executions to confirm that all benchmarks pass.

### Evaluating RIVULET on Large Applications
We also evaluated RIVULET on the following three applications: [iTrust](https://github.com/ncsu-csc326/iTrust) (an educational software project, version 1.23), [Struts](https://github.com/apache/struts) (an open-source web application framework, version 2.3.20_1) and [Jenkins](https://github.com/jenkinsci/jenkins) (an open-source continuous integration project, revision 8349dcebb).

Detailed instructions for executing these benchmarks follow. While it is possible to reproduce these experiments on any Mac or Linux machine with Java 8 installed, we have also created a [VM image](https://doi.org/10.6084/m9.figshare.11592033) with the exact versions of all of the libraries that we used in our evaluation. The VM image also includes complete copies of the expected output of each step.

All of these instructions assume that you have already compiled and installed RIVULET following the instructions above *and* ran the integration tests (which automatically generate a Phosphor-instrumented JVM).

Upon completing the per-app instructions below, you can re-generate table 3 in our ICSE 2020 paper as follows, column-by-column:
1. Total number of tests: taken from build output when running maven, not counting the reruns
2. Baseline time: reported by maven when running the build without RIVULET
3. RIVULET time: reported by maven when running the build with RIVULET
4. Flows: Taken from `target/phosphor-report.json` (`test/target/phosphor-report.json` for Jenkins), `violationsPerSink`
5. Reruns Naive: Following the procedure described in section 5.3 of our ICSE 2020 paper, for RCE, this is the same as Reruns; for XSS, this is (Reruns/7)*152
6. Reruns: Taken from the `phosphor-report.json`, `rerunsPerGenerator.<generator>.rerunsExecuted`
7. Critical violations: Taken from the `phosphor-report.json`, `rerunsPerGenerator.<generator>.criticalReruns`
8. Vulnerabilities: Based on manual analysis of each critical violation to determine the number of unique vulnerabilities discovered.

#### Jenkins
The Jenkins test suite automatically starts and stops an in-process server to host the web app, so it is quite easy to run its test suite with RIVULET. To run Jenkins with RIVULET:
If not using our VM image, in the directory `experiments` (within the top of this repository), clone 
our fork of [Jenkins](https://github.com/gmu-swe/jenkins) and checkout the branch `RIVULET_EVAL`. Once done:

1. `cd` to the directory `experiments/jenkins`
2. In a single command, run Jenkins' test suite: `bash ../../runPom.sh -Djenkins.test.timeout=600 install pom.xml`. On our commodity laptop running the VM, this took approximately 25 hours.

When completed, you should expect to see 9 *critical violations*, in `hudson.pages.SystemConfigurationTestCase`, `hudson.security.csrf.DefaultCrumbIssuerTest`, `jenkins.model.MasterBuildConfigurationTest`, and `jenkins.security.Security857Test`. The first three test classes all reveal [CVE-2019-10406](https://jenkins.io/security/advisory/2019-09-25/). The `Security857Test` reveals an XSS vulnerability, albeit an intentional one (the test exercises super-administrator functionality that is designed to allow administrators to insert code to be included in templates).

#### Struts
The Struts rest-showcase test suite expects that the projecrt has already been compiled and deployed to a web server. To run Struts with RIVULET:
If not using our VM image, in the directory `experiments` (within the top of this repository), clone our fork of [Apache Struts](https://github.com/gmu-swe/struts) and checkout the branch `STRUTS_2_3_20_1_APP_TESTS`. Once done:

1. `cd` to the directory `experiments/struts/apps/rest-showcase`
2. Compile the application without running its tests: `mvn -DskipTests install` (if any tests run and fail: ignore them)
3. Start an embedded Tomcat server to run the web app by running the command `bash runStrutsTestServer.sh`
4. In another terminal, in the same directory (`experiments/struts/apps/rest-showcase`) run the test suite: `bash ../../../../runPom.sh -Dtomcat.port=8080 -Difc.port=8182 install pom.xml `. Please note that it is expected that up to 4 tests in the test class `PostOrderTest` may fail (they can fail without RIVULET, too - they are flaky). On our commodity laptop running the VM, this step took approximately 6 minutes.
5. Stop the Tomcat server by typing control-C in that terminal window.
 
When completed, you should expect to see *critical violations* reported for the test `it.org.apache.struts2.rest.example.PostOrderTest#testPostOrderWithErrors`, demonstrating CVE-2017-5638. To see the values that RIVULET used to detect the vulnerability, you can inspect the log file `target/phosphor-reports/RERUN-it.org.apache.struts2.rest.example.PostOrderTest-0.json`, looking specifically at entries wiht the status "Critical violation criteria met."

#### iTrust
iTrust's test suite expects that the project has already been compiled and deployed to a web server, and also that MySQL is installed, with a username of `root` and a password of `root`. To simplify running these experiments, our [VM image](https://doi.org/10.6084/m9.figshare.11592033) has an appropriate MySQL server installed and set to run on boot.

To run iTrust:
If not using our VM image, in the directory `experiments` (within the top of this repository), clone our [fork of iTrust](https://github.com/gmu-swe/iTrust) (branch `rivulet-integration`). Then make sure to install a MySQL server and start it, using user `root` and password `root` and configure MySQL to ignore case sensitivity in table names (this is a requirement of iTrust, not of RIVULET) by adding the following to your `/etc/my.cnf`:

```
[mysqld]
lower_case_table_names=1
```
 Once done (or, start here if you are in our VM):

1. `cd` to the directory `experiments/iTrust/iTrust`
2. Compile the application without running its tests: `mvn -DskipTests install`
3. Start an embedded Tomcat server to run the web app by running the command `bash runiTrustServerRIVULET.sh`. The server will start and stay in the foreground. 
4. In another terminal, in the same directory (`experiments/iTrust/iTrust`) run the test suite: `bash ../../../runPom.sh -Dtomcat.port=8080 -Difc.port=8182 install pom.xml`. On our commodity laptop running our VM, this step takes approximately 4 hours.
5. Stop the Tomcat server by typing control-C in that terminal window.

When completed, you should expect to see *critical violations* reported for the following tests, which represent the vulnerabilities that we found:
`edu.ncsu.csc.itrust.selenium.DependentsTest`, `edu.ncsu.csc.itrust.selenium.ExpertReviewsTest`, `edu.ncsu.csc.itrust.selenium.FindExpertTest`, `edu.ncsu.csc.itrust.selenium.GroupReportTest`, `edu.ncsu.csc.itrust.selenium.TelemonitoringUseCaseTest` and `edu.ncsu.csc.itrust.selenium.WardTest` (`FindExpertTest` and `ExpertReviewsTest` both reveal the same vulnerability). You can check for this by searching for the string "criteria met" in the `experiments/iTrust/iTrust/target/phosphor-reports/` directory. Inside of the report files, you can see the specific string that was used to demonstrate the vulnerability, e.g.:

```
...
              { 
                "replacements": [
                  "Replacement: {io/rivulet/PhosphorHttpRequest.getEntityBody()Ljava/lang/String;(arg=-1)(ids=[13]) -> a@b.com<script src=https://www.rivulet.io/alert.js></script> with <SubstringConverter: [97, 106)>}"
                ],
                "criticalViolationStatus": "Critical violation criteria met.",
                "testOutcome": "Succeeded"
              },
...
```

The vulnerabilities are described in detail [in our pull request that resolves them](https://github.com/ncsu-csc326/iTrust/pull/2).  

## Using RIVULET with Other Existing Test Suites
Once RIVULET is installed, it is relatively straightforward to use it to find vulnerabilities in an existing application, provided that that application has an automated test suite that is executed with `mvn test` or `mvn verify`.

You can choose to either install RIVULET site-wide for a given maven installation, or to modify your project's POM file to use RIVULET. With the site-wide installation, you'll use a specific `mvn` binary to run your tests, which will automatically transform your project to use RIVULET. An advantage to modifying the POM file is that you do not need to install RIVULET (it will automatically be downloaded and installed by maven).

### Installing for an individual project
Add the following to the project's pom.xml file:

```
<project>
...
<build>
...
		<extensions>
			<extension>
				<groupId>io.rivulet</groupId>
				<artifactId>rivulet-maven-extension</artifactId>
				<version>1.0.0</version>
			</extension>
		</extensions>
...
</build>
</project>
```

### Installing site-wide
Transforming POM files can be annoying. When you install RIVULET, the install script will download an extra copy of maven and install the RIVULET maven extension into that copy of maven (simply copying the extension into the `lib/ext` folder). After you have run `mvn install`, you can find that copy of maven in `apache-maven-phosphor/bin/mvn`. The `runPom.sh` script will ensure that the correct version of maven is selected, and will also apply some default configuration options.

### Running tests with RIVULET
Once RIVULET is installed, it will modify your project's build configuration on-the-fly to perform its vulnerability analysis. RIVULET is designed to work out-of-the-box (with no configuration change) if your web server runs in the same JVM as your tests (e.g. if you use a JUnit rule to start a jetty or tomcat server before running tests) - if this is the case, simply running `mvn install` (or `runPom.sh install pom.xml` for the site-wide install) will run everything.

If your project is NOT configured to start a testing web server in the same process as the tests, then you can still use RIVULET: you'll just need to connect RIVULET to both ends of the system (the web server JVM and the test running JVM). Take a look at the scripts that we've provided in our iTrust and Struts forks (see below) for examples of doing so. 


## License
This software is released under the MIT license.

Copyright (c) 2020, Katherine Hough, Gebrehiwet Welearegai, Christian Hammer and Jonathan Bell.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Acknowledgements
This project makes use of the following libraries:

* [ASM](http://asm.ow2.org/license.html), (c) 2000-2011 INRIA, France Telecom, [license](http://asm.ow2.org/license.html)
* [jsoup](https://jsoup.org), (c) Jonathan Hedley, [license](https://jsoup.org/license)

Phosphor's performance tuning is made possible by [JProfiler, the java profiler](https://www.ej-technologies.com/products/jprofiler/overview.html).

Jonathan Bell and Katherine Hough are funded in part by NSF CCF-1763822, NSF CNS-1844880, and the NSA under contract number H98230-18-D-008.
