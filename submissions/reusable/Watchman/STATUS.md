Our artifact applies for `Reusable`,	`Available`,	`Replicated` and `Reproduced` badges. The reasons why the we believe that the artifact deserves the badges are described as follows:

Reusable
---
1. Watchman is developed as an online tool (http://www.watchman-pypi.com/), which can help developers diagnose the dependency conflict (DC) issues in their projects. The functional correctness of Watchman can be verified.
2. This artifact is documented and well-structured to the extent that reuse and repurposing is facilitated. 
3. Specially, We released 235 DC issues collected in the empirical study, which is a reusable dataset that can help developers understand and improve the technique for diagnosing DC issues.

We also released the metadata repository of all the library versions on the PyPI ecosystem from 6 Nov, 2002 (the date of PyPI being founded) to 31 Dec, 2020, under the MIT License. To reproduce the evaluation results in Section 5.1 of this paper, we released a series of scripts, which help to replay the evolution history of the 16,421 releases of 2,067 projects on PyPI from 1 Jan, 2017 to 30 Jun, 2019. The above dataset and scripts are useful for future research.

Available
---
This artifact is placed on a publicly accessible archival repository. 

A DOI or link to this repository along with a unique identifier for the object is provided: https://zenodo.org/record/3627491</br>
![](https://github.com/NeolithEra/Figures/blob/master/DOI.png)

Replicated
---
The main results of this paper have been obtained in a subsequent study by a person other than the authors, using the artifacts provided by the authors. 

The provided replication report is available at: http://www.watchman-pypi.com/reports 

Reproduced
---
The main results of the paper have been independently obtained in a subsequent study by a person or team other than the authors, without the use of author-supplied artifacts.

Recently, we promoted Watchman in the open source community by communicating with developers in the comments section of issue reports submitted by us. We also invited several experienced developers from two Chinese software companies, ***Neusoft*** Co. Ltd (SSE: 600718) and ***Pinduoduo*** Co. Ltd (Nasdaq: PDD), to apply Watchman to their company projects and asked for their feedback. 
We observed that 467 users from 15 different countries visited Watchman website from 9 December, 2019 and 17 January, 2020 (we tried our best to filter out the visits by robots/crawlers). And Watchman has successfully generated online diagnosis reports for 2590 Python projects. In addition, the developers of the two software companies sent us reproduction reports via emails.

The provided reproduction report is available at: http://www.watchman-pypi.com/reports
