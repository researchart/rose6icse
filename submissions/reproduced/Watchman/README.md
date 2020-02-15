&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![](https://github.com/NeolithEra/Figures/blob/master/Watchman_logo.png)</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![](https://github.com/NeolithEra/Figures/blob/master/DOI.png)</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;（https://zenodo.org/record/3668451)
</br>

This is the artifact for the ICSE 2020 Technical Track paper: "Watchman: Monitoring Dependency Conflicts for Python Library Ecosystem". A pre-print of this paper is available at [Accepted Paper #702.pdf](http://faculty.neu.edu.cn/swc/wangying/Paper/Watchman.pdf).

Project description
===

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Watchman is an online tool ([**http://www.watchman-pypi.com/**](http://www.watchman-pypi.com/)), which can performs a holistic analysis from the perspective of the entire PyPI ecosystem, to monitor the dependency conflicts (DCs) caused by library updates.
</span></br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Its main features are: 1) monitoring the library updates on PyPI and identifying the affected projects; 2) building a full dependency graph (FDG) for a Python project under analysis; 3) providing the self-diagnosis service for users to analyze the dependency conflicts in their projects; and 4) submitting the issue reports and pull requests automatically to warn the projects against dependency conflict issues. For more detailed information, please refer to the ***&quot;ABOUT&quot;*** page of Watchman.
</span>

![](https://github.com/NeolithEra/Figures/blob/master/Figure1.png)
Figure 1 The overview of Watchman&#39;s architecture

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
This artifact contains the metadata repository of all the library versions and the dependency relationships between them on PyPI from 6 Nov, 2002 (the date of PyPI being founded) to 31 Dec, 2019, and the scripts that help to play back the evolution history of the libraries released on the PyPI ecosystem.
</span>


Background
===

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
To use a library on PyPI, developers need to specify the desired version constraints in a configuration script such as _setup.py_ and _requirements.txt_. When a library is reused by another project, this library and other libraries on which it depends will be automatically installed at the project&#39;s build time. The automation smartly combines a server-side central repository and a client-side library installer to manage library dependencies. It considerably simplifies the build process of Python projects. However, such automation comes with the risk of potential dependency conflict issues, which can cause build failures when the installed version of a library violates certain version constraints on the library.</span></br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Diagnosing DC issues is a challenging task in the Python world. First, the version of a library installed for a Python project can vary over time. For each required library, pip will install its latest version satisfying the concerned constraint. Therefore, any updates of libraries on PyPI can affect the version of the libraries installed for the downstream projects (i.e., the projects that depend on the libraries), causing potential build failures. Second, an impact could be wide-spreading since it can be propagated transitively to a wide range of downstream projects. Manually identifying the affected downstream projects is impractical for developers. Third, it is difficult to obtain a full dependency graph with version constraints for projects on PyPI. The state-of-the-art tools like _pipenv_ and _Poetry_ show only which libraries have been installed, rather than their dependencies, which are less effective in diagnosing dependency conflicts. To address the above challenges, we develop Watchman to help Python developers combat DC issues.
</span>

Diagnosis information
===

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Watchman can provide diagnosis information for the following three types of (potential) DC issues:
</span>

- **Pattern A** : _Conflicts caused by the library updates on PyPI_. If the updated library version could be installed in a client project, which violates the certain version constraints specified by this project on the library, then a build failure will occur.</br>
We refer to the conflicts between direct and transitive dependencies as **Pattern A.a** issues, and the conflicts between transitive dependencies as **Pattern A.b** issues.

- **Type 1** : _Potential conflicts caused by restricting a dependency to a specific version_. If a project restricts a dependency to a specific version, its downstream projects may easily suffer from DC issues.
- **Type 2:** _Potential conflicts caused by the case that the installed version of a library is close to the upper bound specified in the version constraint_. If the installed version of a library satisfies the concerned version constraint but is close to the upper bound specified in the constraint, build failures can easily occur when the library evolves.

Recommended browser
===

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
The recommended browser is Chrome (version 79.0.3945.130 and higher).
</span>

Artifact Evaluation
===

Download
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
The artifact of Watchman, `Watchman.zip`, is available at [http://www.watchman-pypi.com/artifacts](http://www.watchman-pypi.com/artifacts). Please first download the package, to reproduce the results.
</span>


Inside the package
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
The major components in the package `Watchman.zip` are described as follows:

- `empirical_study_dataset.xlsx` : The empirical study dataset, contains 235 collected DC issues;
- `Replaying evolution history.zip` : The artifact helps to replay the evolution history of the libraries on PyPI. The package contains the following two packages:

1. `pypi_validity_evaluationSQL.zip` : The dataset recording the metadata repository of all the library versions on PyPI from 6 Nov, 2002 (the date of PyPI being founded) to 31 Dec, 2019.
2. `Watchman_Artifacts.zip` : A series of script files helps to automatically play back the evolution history of the libraries and output the diagnosis results.

An introduction to the evaluation of Watchman
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
One can replicate our work based on the following descriptions. Our replication reports are available at [http://www.watchman-pypi.com/reports](http://www.watchman-pypi.com/reports).
</span>

- **Dataset of our empirical study in Section 3:** One can manually investigate the 235 collected DC issues in open-source Python projects on GitHub (in file `empirical_study_dataset.xlsx`) and check the correctness of our categorization of the issues.
- **Verifying the functional correctness of Watchman:** One can go to our online Watchman tool via its [link](http://www.watchman-pypi.com/). The main function is provided on the ***"DIAGNOSIS"*** page of Watchman. The replication includes building an FDG for a given Python project that simulates the process of installing dependencies and diagnosing DC issues for the project. For replication, we provide three example Python projects. One can verify the diagnosis information of three types of DC issues generated by Watchman for the three example projects. One can also use Watchman to analyze any Python project released on PyPI to check their FDGs and corresponding diagnosis results. We also provide a video demo at [https://youtu.be/3EOz9g3Bw70](https://youtu.be/3EOz9g3Bw70).
- **Verifying the experiment results reported in Section 5.1:** For replication, we provide scripts and raw data. The scripts help to automatically play back the evolution history of the collected 2,067 Python projects on PyPI (from 1 January, 2017 to 30 June, 2019) and detect DC issues during the above time period. The values of our proposed metrics _resolving ratio_ and _lasting time_ can be calculated by checking the outputted evolution information of each collected library. **The detail replication steps, one can refer to** [INSTALL.md](https://github.com/NeolithEra/rose6icse/blob/master/submissions/reproduced/Watchman/INSTALL.md).</font>
- **Verifying the experiment results reported in Section 5.2:** For replication, one can check the following data: 1) the daily library update information on PyPI captured by Watchman during two time periods (from 1 July, 2019 to 10 August, 2019, and 1 December, 2019 to 31 December, 2019), and the corresponding downstream projects affected by the library updates identified by Watchman ***(provided as an online searchable table on the "UPDATE" page of Watchman)***; and 2) diagnosis information and the statuses of the 279 real issues (Watchman found and reported 162 more issues since our paper submission) reported by Watchman to the open-source projects, during the two time periods ***(provided on "ISSUE REPORT" page of Watchman)***. Then, the confirmation rate and fixing rate of these issues can be calculated easily.  **The detail replication steps, one can refer to** [INSTALL.md](https://github.com/NeolithEra/rose6icse/blob/master/submissions/reproduced/Watchman/INSTALL.md).


A quick start to Watchman
===

Example Python projects
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Three example Python projects with three types of (potential) DC issues, are provided as follows:
</span>

1. **Pattern A** : `moto` `1.3.14`
2. **Type1** : `ldapdomaindump` `0.9.1`
3. **Type2** : `bcdata` `0.3.5`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
First, please go to the online Watchman tool via its link ([**http://www.watchman-pypi.com/**](http://www.watchman-pypi.com/)). 
Its &quot;***DIAGNOSIS***&quot; page provides the main function.
</span>

Inputs of Watchman
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
  Watchman supports two types of inputs to diagnose their DC issues: 1) the name and version number of a Python project to be analyzed released on PyPI; and 2) a dependency configuration file (i.e., _requirement.txt_) of a Python project to be analyzed.
  For instance, please press the &quot;***Pagage Name/Version***&quot; button on the &quot;***DIAGNOSIS***&quot; page. Then, you can input the project name and version number to be analyzed.
  
  ![](https://github.com/NeolithEra/Figures/blob/master/Input1.png)
  Figure 2(a) Inputing the project name with prompt messages
  
  ![](https://github.com/NeolithEra/Figures/blob/master/Input2.png)
  Figure 2(b) Inputing the project version number with prompt messages
  

  If the Python project to be analyzed is not released on PyPI, then you can press the &quot;***Import File***&quot; button and then upload its _requirement.txt_ file.
  
  ![](https://github.com/NeolithEra/Figures/blob/master/Input4.png)
  Figure 3 Uploading the _requirement.txt_ file of a Python project be analysed


</span>

Displaying full dependency graph
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
On the &quot;***DIAGNOSIS***&quot; page, when a user inputs the name and version number of a Python project released on PyPI, or uploads a project&#39;s dependency configuration file (i.e., _requirement.txt_), and presses the &quot;***Graph***&quot; button, watchman provides the full dependency graph (FDG) of the project under analysis. The FDG simulates process of installing the required dependencies. Users can also save the generated FDG in an image or a text file, for further analysis, when pressing &quot;***Save***&quot; button. In addition, all of its downstream projects can also be listed on this page.
</span>

![](https://github.com/NeolithEra/Figures/blob/master/Figure2.png)
Figure 4 Displaying full dependency graph of a give Python project

![](https://github.com/NeolithEra/Figures/blob/master/Figure3.png)
Figure 5 Saving the generated full dependency graph for further analysis

Diagnosing DC issues
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
On the &quot;***DIAGNOSIS***&quot; page, when pressing the &quot;***Start***&quot; button, Watchman will help you diagnose the DC issues in the project under analysis and provide the detailed root causes and suggested fixing solutions.
</span>

![](https://github.com/NeolithEra/Figures/blob/master/Figure4.png)
Figure 6 Generating diagnosis information for a Python project under analysis


An overview of the topological structure of the PyPI ecosystem
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Press the &quot;***Go***&quot; button, users can have an overview of the topological structure of the PyPI ecosystem and also can see the details of any Python project. The searching process is like traveling through the PyPI universe.
</span>

![](https://github.com/NeolithEra/Figures/blob/master/Figure7.png)
Figure 7 An overview of the topological structure of the PyPI ecosystem

![](https://github.com/NeolithEra/Figures/blob/master/Figure8.png)
Figure 8 The details of any Python project on PyPI

License
===

The artifact is released under the [![MIT License](https://img.shields.io/github/license/xiaocong/uiautomator.svg)](http://opensource.org/licenses/MIT).
