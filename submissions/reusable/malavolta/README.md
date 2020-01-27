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
    |
    |--- dataset/             		The full dataset of ROS-based systems mined from GitHub, including also the Python scripts for rebuilding/updating the dataset and the raw data produced in all intermediate steps.
    |
    |--- online_questionnaire/   	List of contacted participants, script for contacting all participants via email, raw data of the responses, transcript of the on-line questionnaire.
    |
    |--- ICSE_SEIP_2020.pdf             A copy of the paper in pdf format
```

Each of the folders listed above are described in details in the remaining of this readme.

### Data analysis
---
```
data_analysis
    .
    |--- RQ1_codes_and_selection_criteria.pdf   TODO    
    |--- analysis.r                             TODO
    |--- documentation_fragments.csv            TODO
    |--- guidelines_definitions.csv             TODO
```

### Dataset
---
```
dataset
    .
    |--- Repos                                              TODO
	|--- manual_selection_gitlab.pdf                    TODO
	|--- repos_dataset_all.csv                          TODO
	|--- repos_dataset_selected.csv                     TODO
	|--- repos_dataset_selected_sadoc.csv               TODO
	|--- repos_filtering_intermediate_numbers.pdf       TODO
	|--- repos_filtering_statistics.pdf                 TODO
	|--- repos_golden_set.pdf                           TODO
	|--- repos_mining_data                              TODO
	│   |--- Archive.zip                                TODO
	|--- repos_mining_scripts                           TODO    
	    |--- cloner.py                                  TODO
	    |--- detector.py                                TODO
	    |--- explorer.py                                TODO
	    |--- ghtorrent_queries.sql                      TODO
	    |--- merge_counter.py                           TODO
	    |--- metrics_manager.py                         TODO
	    |--- visit_website.scpt                         TODO
```

### Online questionnaire
---
```
online_questionnaire
    .
    |--- online_questionnaire.pdf                           TODO
	|--- online_questionnaire_invitation_email.txt      TODO
	|--- online_questionnaire_responses.csv             TODO
	|--- online_questionnaire_responses_raw.csv         TODO
	|--- online_questionnaire_scripts                   TODO
	    |--- Mail Sender                                TODO
	    │   |--- README.md                              TODO
	    │   |--- emails.csv                             TODO
	    │   |--- mailSender.py                          TODO
	    |--- cloned_repos                               TODO
	    |--- cloned_repos.csv                           TODO
	    |--- cloner.py                                  TODO
	    |--- people_12_months.csv                       TODO
	    |--- repos_to_clone.csv                         TODO
```
