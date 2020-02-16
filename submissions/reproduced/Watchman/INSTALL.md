&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![](https://github.com/NeolithEra/Figures/blob/master/Watchman_logo.png)

Verifying the experiment results reported in Section 5.1
====

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
In this artifact, we release the metadata repository of all the library versions on the PyPI ecosystem from 6 Nov, 2002 (the date of PyPI being founded) to 31 Dec, 2019, under the MIT License. To reproduce the evaluation results in Section 5.1 of this paper, we also release a series of scripts, which help to replay the evolution history of the 16,421 releases of 2,067 projects on PyPI from 1 Jan, 2017 to 30 Jun, 2019. To ease evaluation, we divided the whole period into five sub-periods, including: (1) _Period 1_ : 1 Jan 2017 – 30 Jun 2017, (2) _Period 2_ : 1 Jul 2017 – 31 Dec 2017, (3) _Period 3_ : 1 Jan 2018 – 30 Jun 2018, (4) _Period 4_ : 1 Jul 2018 – 31 Dec 2018, (5) _Period 5_ : 1 Jan 2019 – 30 Jun 2019.
</span></br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span>
  
Inside the package `Watchman.zip` (for its download link, please refer to [README.md](https://github.com/NeolithEra/rose6icse/blob/master/submissions/reproduced/Watchman/README.md)), we provide `Replaying evolution history.zip`, which contains all necessary materials for reproducing the results of Section 5.1.
</span>


Inside the Package
----  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
Unzip the `Replaying evolution history.zip` to local directory. This folder contains two packages `pypi_validity_evaluationSQL.zip` and `Watchman_Artifacts.zip`.
</span>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`Watchman_Artifacts.zip` contains a series of script files listed as follows:</br>

- Watchman_Artifacts\validity_evaluation_period1.py
- Watchman_Artifacts\validity_evaluation_period2.py
- Watchman_Artifacts\validity_evaluation_period3.py
- Watchman_Artifacts\validity_evaluation_period4.py
- Watchman_Artifacts\validity_evaluation_period5.py

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Running above scripts can play back the evolution history of the collected projects in the five sub-periods and output the diagnosis results, separately.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
The major components included in the package `pypi_validity_evaluationSQL.zip` are:

- `pypi_validity_evaluationSQL\pypi_info.sql` is a data sheet, which records the metadata repository of all the library versions on PyPI from 6 Nov, 2002 to 31 Dec, 2019.
- `pypi_validity_evaluationSQL\pypi_info_version_all.sql` is a data sheet recording the detailed information of all the library releases on PyPI, including version numbers, updated dates, etc.
- `pypi_validity_evaluationSQL\evaluation_info.sql` contain the historical fixing records of the DC issues in the collected projects, which are mined by us from their corresponding issue tracking systems.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
To avoid users configuring the local environment for MySQL database, we deployed the above data sheets in the server-side of Watchman. In this manner, these data sheets can be automatically connected via network communication, when running our scripts. ***Therefore, the provided scripts cannot work offline***. In this artifact, we provide the package `pypi_validity_evaluationSQL.zip` only for the verification purpose.

Running Environment
----

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
This artifact is developed based on Python language, and has been tested on Window 10 operating system (64 bit) with [**python-3.7.4-amd64**](https://www.python.org/ftp/python/3.7.4/python-3.7.4-amd64.exe) installed. You are recommended to run the artifact under the same or similar environment.
Note that, the scripts require Python dependencies **pymysql** , **DBUtils** , **requests** and **BeautifulSoup4** , there may be the runtime prompts for installation, please import them using **pip**.

**Replaying the evolution history of the projects on PyPI**
----

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Watchman only needs the following three steps to play back the evolution history of the libraries on PyPI, and perform a holistic analysis from the perspective of the entire PyPI ecosystem. Based on the above analysis, Watchman detects the DC issues of **Patterns A.a** and **A.b** , and predicts potential ones that could be induced by the smells of **Type 1** and **Type 2**. Finally, it outputs the diagnosis information, and the values of metrics **resolving ratio** and **lasting time**. The **resolving ratio** measures the proportion of the resolved ones in Watchman&#39;s detected DC issues, and the **lasting time** measures the gap between the detection time of a DC issue and the fixing time of this DC issue. For more detailed definitions of **Patterns A.a** , **A.b** , **Type 1** and **Type 2 issues,** you can refer to the [README.md](https://github.com/NeolithEra/rose6icse/blob/master/submissions/reproduced/Watchman/README.md) file in the artifact package.</br>

- **Step 1:** Unzip package `Watchman_Artifacts.zip` to local directory.</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
- **Step 2:** Launch your windows console as an administrator and change your working directory to the one that `Watchman_Artifacts.zip` package being unzipped.</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
- **Step 3:** Run the provided scripts.


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
For instance, if you unzipped the package `Watchman_Artifacts.zip` to the directory `D:\`, and would like to verify the detection results during _Period 1_ (from 1 Jan 2017 to 30 Jun 2017). Then, run the following command in console.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`python D:\Watchman_Artifacts\validity_evaluation_period1.py`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Note that, if your local environment already has other versions of Python installed (such as Python 2.*), it is fine but please make sure that the command "`python`" would run python version 3.7.4. If you see the following evolution information of the libraries (on daily basis) is printed in your console, the artifact is successfully executed：

```
Detecting Project:  universal-notifications  Version No:  0.4.0 Last update date: 2017-01-02 17:57:32  Detection date: 2017-01-03
Detecting Project:  web3  Version No:  3.4.4 Last update date: 2017-01-01 13:07:22  Detection date: 2017-01-03
******************************************************************************  
2017-01-04 23:59:59  
Detecting Project:  auto-ml  Version No:  1.9.2 Last update date: 2017-01-02 07:25:16  Detection date: 2017-01-04
Detecting Project:  burp-ui  Version No:  0.4.4 Last update date: 2017-01-02 19:15:14  Detection date: 2017-01-04
Detecting Project:  cauldron-notebook  Version No:  0.0.28 Last update date: 2017-01-04 22:06:04  Detection date: 2017-01-04
Detecting Project:  cauldron-notebook  Version No:  0.0.27 Last update date: 2017-01-03 16:34:16  Detection date: 2017-01-04
Detecting Project:  cauldron-notebook  Version No:  0.0.26 Last update date: 2017-01-02 22:46:05  Detection date: 2017-01-04
Detecting Project:  cauldron-notebook  Version No:  0.0.25 Last update date: 2017-01-02 15:41:21  Detection date: 2017-01-04
Detecting Project:  cbapi  Version No:  1.0.1 Last update date: 2017-01-04 13:40:22  Detection date: 2017-01-04
Detecting Project:  changelogs  Version No:  0.3.1 Last update date: 2017-01-03 09:42:07  Detection date: 2017-01-04
Detecting Project:  changelogs  Version No:  0.3.0 Last update date: 2017-01-03 08:57:26  Detection date: 2017-01-04
Detecting Project:  clack-cli  Version No:  2.0.0b7 Last update date: 2017-01-03 10:12:58  Detection date: 2017-01-04
Detecting Project:  coala-bears  Version No:  0.10.0.dev20170101032144 Last update date: 2017-01-01 03:21:48  Detection date: 2017-01-04
Detecting Project:  coala-bears  Version No:  0.10.0.dev20170101010541 Last update date: 2017-01-01 01:05:42  Detection date: 2017-01-04
Detecting Project:  coala-bears  Version No:  0.9.2.dev20170104114034 Last update date: 2017-01-04 11:40:36  Detection date: 2017-01-04
Detecting Project:  coala  Version No:  0.10.0.dev20170103075551 Last update date: 2017-01-03 07:55:53  Detection date: 2017-01-04
Detecting Project:  coala  Version No:  0.10.0.dev20170102200244 Last update date: 2017-01-02 20:02:47  Detection date: 2017-01-04
Detecting Project:  coala  Version No:  0.10.0.dev20170102192122 Last update date: 2017-01-02 19:21:24  Detection date: 2017-01-04
……
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
During the execution process of this artifact, in directory `C:\` you can found the folder named as the period under detection (e.g., 20170101-20170630), which is used to record the corresponding diagnosis results of different types of DC issues.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
For example, the outputted files could be:</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`C: \20170101-20170630\DC_issue_Pattern_A.txt`</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`C: \20170101-20170630\DC_issue_Type_1.txt`</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`C: \20170101-20170630\DC_issue_Type_2.txt`</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`C: \20170101-20170630\Metrics.txt`</br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
***NOTE:***  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; As replaying library evolution and diagnosing DC issues should be performed based on a holistic analysis of the entire PyPI ecosystem on daily basis, which is time-consuming. For a time period (180/181 days), the above process would take around **3~4** days, and the actual execution time may depend on the quality of network communication, since it works via visiting the data sheets in the server-side.



Verifying the experiment results reported in Section 5.2
====

For replication, we release the the daily library update information on PyPI captured by Watchman during two time periods (from 1 July, 2019 to 10 August, 2019, and 1 December, 2019 to 31 December, 2019), and the corresponding downstream projects affected by the library updates identified by Watchman. To ease evaluation, we organize the data into an online searchable table on the ***"UPDATE"*** page of Watchman. Besides, we provide the diagnosis information and the statuses of the 279 real issues reported by Watchman to the open-source projects, during the two time periods, on ***"ISSUE REPORT"*** page of Watchman.

Showing the real issues reported by Watchman
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
First, please go to the online Watchman tool via the link ([**http://www.watchman-pypi.com/**](http://www.watchman-pypi.com/)). 
The ***"ISSUE REPORT"*** page of Watchman, lists the diagnosis information and the statuses of the 279 real issues reported by Watchman to the open-source projects, during the two time periods (from 1 July, 2019 to 10 August, 2019, and 1 December, 2019 to 31 December, 2019). ***Note that Watchman found and reported 162 more issues since our paper submission***.
One can verify the results of reported DC issues in Section 5.2 of this paper.


![](https://github.com/NeolithEra/Figures/blob/master/Figure5.png)
Figure 1 Online searchable table listing the diagnosis information of the 279 reported real issues

Showing the daily update information captured by Watchman (an online searchable table)
---

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<span style="">
The &quot;***UPDATE***&quot; page of Watchman, provides the daily library update information on PyPI captured by Watchman during two time periods, and the corresponding downstream projects affected by the library updates identified by Watchman.
One can sample several the listed library update information and then verify their corresponding release records on PyPI. Besides, one can download their downstream projects’ _requirement.txt_ files and check whether these downstream projects could be affected by the updated libraries (i.e., directly or indirectly depending on the updated libraries).
</span>

![](https://github.com/NeolithEra/Figures/blob/master/Figure6.png)
Figure 2 Online searchable table listing the daily library update information on PyPI captured by Watchman
