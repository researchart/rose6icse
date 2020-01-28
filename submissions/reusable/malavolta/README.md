# ICSE SEIP 2020 – Replication package

This folder contains the replication package of the paper published at ICSE SEIP 2020 with the title **How do you Architect your Robots? State of the Practice and Guidelines for ROS-based Systems**.

This study has been designed, developed, and reported by the following investigators:

- [Ivano Malavolta](https://www.ivanomalavolta.com) (Vrije Universiteit Amsterdam)
- [Grace Lewis](https://resources.sei.cmu.edu/library/author.cfm?authorID=4347) (Software Engineering Institute, Carnegie Mellon University)
- [Bradley Schmerl](http://www.cs.cmu.edu/~schmerl/) (Institute for Software Research, Carnegie Mellon University)
- [Patricia Lago](https://www.cs.vu.nl/~patricia/Patricia_Lago/Home.html) (Vrije Universiteit Amsterdam)
- [David Garlan](https://www.cs.cmu.edu/~garlan/) (Institute for Software Research, Carnegie Mellon University)

For any information, interested researchers can contact us by sending an email to any of the investigators listed above.
The full dataset including raw data, mining scripts, and analysis scripts produced during the study are available below.

### Overview of the replication package
---
This replication package is structured as follows:

```
malavolta
    .
    |--- data_analysis/       		The data that has been extracted during the iterative content analysis and the thematic analysis phases, and the R script for plotting the extracted data (see below).
    |--- dataset/             		The full dataset of ROS-based systems mined from GitHub, including also the Python scripts for rebuilding/updating the dataset and the raw data produced in all intermediate steps.
    |--- online_questionnaire/   	List of contacted participants, script for contacting all participants via email, raw data of the responses, transcript of the on-line questionnaire.
    |--- ICSE_SEIP_2020.pdf             A copy of the paper in pdf format
```

Each of the folders listed above are described in details in the remaining of this readme.
In order to facilitate the replication and independent verification of our study, all Python scripts in the replication package have a preliminary section containing their main points of variation as constants (e.g., the paths where to save intermediate results, the minimum number of commits and stars to include a repository, the number of months since last contribution for identifying a participant of the online questionnaire, etc.). In this way, the interested researcher can straightforwardly adapt each single Python script to their needs. 

### Data analysis
---
```
data_analysis/
    .
    |--- RQ1_codes_and_selection_criteria.pdf   The codes we used for classifying each repository for answering RQ1 and the inclusion/exclusion criteria for selecting relevant repositories for our dataset    
    |--- analysis.r                             The R script we used for generating the plots reported in the article
    |--- documentation_fragments.csv            Raw textual fragments extracted from the documentation of ROS-based systems, with full traceability information about which guideline each fragment generates and the specific repository it comes from
    |--- guidelines_definitions.csv             Raw data containing the guidelines defined during the analysis for answering RQ3 with additional data about how we solved conflicts, their computed usefulness, etc.
```
The data in the CSV files has been manually, collaboratively, and iteratively extracted by the authors of the paper. The steps for recreating the plots presented in the paper the list of contributors to contact for replicating this study are presented [here](./INSTALL.md). 

### Dataset
---
```
dataset/
    .
    |--- Repos/                                         The folder which will contain all the locally-cloned repositories
    |--- manual_selection_gitlab.pdf                    16 out of 46 GitLab projects were not hosted on gitlab.com, so we performed all the filtering steps manually in those cases. This is the data we manually extracted about the 16 Gitlab repositories resulting from this manual step
    |--- repos_dataset_all.csv                          Automatically filtered repositories (598 entries)
    |--- repos_dataset_selected.csv                     Manually filtered repositories (335 entries)
    |--- repos_dataset_selected_sadoc.csv               Repositories in which the software architecture of the system is described either fully or partially (115 entries)
    |--- repos_filtering_intermediate_numbers.pdf       Raw numbers about each single filtering step applied for building the dataset of ROS-based repositories
    |--- repos_filtering_statistics.pdf                 Tables showing descriptive statistics about the various repositories selected before and after the manual selection, and after the check about the architecture documentation
    |--- repos_golden_set.pdf                           The golden set of ROS repositories used for understanding if our selection procedure is correct
    |--- repos_mining_data/                             Folder containing all the raw data related to our filtering steps, including intermediate data coming from GHTorrent, raw data produced by rosmap, and the raw data obtained at each single filtering step
    │   |--- Archive.zip                                The data related to our filtering steps (as a zip file in order to stay within the GitHub file size limits)
    |--- repos_mining_scripts/                          Folder containing all the Python scripts we used for building the dataset, to explore the obtained repositories, to compute metrics about the repositories, to locally clone repositories, etc.    
	|--- cloner.py                                  Locally clones a set of repositories as a bulk operation
	|--- detector.py                                Iterates over a set of repositories and filters out those which do not contain a ROS launch file (either in XML or in Python)
	|--- explorer.py                                The main file of the dataset building phase. It performs the filtering steps 1 to 8 in Figure 4 in the paper 
	|--- ghtorrent_queries.sql                      The SQL queries we used for exploring and selecting the initial set of GitHub repositories mined from the GHTorrent dataset (before filtering them)
	|--- merge_counter.py                           Merges duplicate repositories between the repositories mined via rosmap and GHTorrent 
	|--- metrics_manager.py                         Collects relevant metrics for each GitHub repository, such as #commits, #contributors, #issues, #PRs, etc. 
	|--- visit_website.scpt                         Auxiliary script for programmatically visiting a website using Google Chrome in MacOS
```

Interested researchers can fully rebuild/update the whole dataset by following the steps presented [here](./INSTALL.md).

### Online questionnaire
---
```
online_questionnaire/
    .
    |--- online_questionnaire.pdf                       Full transcript of the online questionnaire
    |--- online_questionnaire_invitation_email.txt      Text of the email for inviting roboticists to participate to the on-line survey
    |--- online_questionnaire_responses.csv             The data containing all the responses of the on-line questionnaire, including our manual classification
    |--- online_questionnaire_responses_raw.csv         The raw data as produced by the online form in Google Drive
    |--- online_questionnaire_scripts/                  Folder containing the Python scripts for locally cloning the repositories, for extracting the information about the contributors of each repository, and for sending out the invitation emails 
	|--- Mail Sender/                               Folder containing all artifacts needed for sending out invitation emails
	│   |--- README.md                              Mini-guide for mailSender.py informing the user to add their own email address and SendGrid API key
	│   |--- emails.csv                             The email addresses to send the invitation email to (it is empty now)
	│   |--- mailSender.py                          Sends emails in bulk, based on a template and on the list of email addresses provided in emails.csv
	|--- cloned_repos/                              The folder which will contain all the locally-cloned repositories
	|--- cloned_repos.csv                           The list of all the repositories we cloned when identifying the potential participants of the online questionnaire
	|--- email_detector.py                          Given a list of locally-cloned repositories, it iterates over them and identifies the email addresses of all developers who contributed to at least one repository in the last 12 months 
	|--- people_12_months.csv                       The list of developers who contributed to at least one repository in the last 12 months
	|--- repos_to_clone.csv                         The list of repositories to clone
```

The steps for contacting the list of contributors of the targeted GitHub repositories are presented [here](./INSTALL.md). 
