### Introduction 

The artifact is a Docker image which contains source code for *A*utomated 
*C*ategorizer for *I*nfrastructure as Code *D*efects (*ACID*). ACID 
is a natural language processing tool that automatically idnetifies defect categories in infrastructure as code (IaC) scripts. The Docker image also includes the directories where we have Puppet scripts for which we run ACID and perform empirical analysis. The easiest way to run ACID is to execute instructions 1-6 mentioned below.  

The defect categories for IaC scripts are listed in our ICSE 2020 paper `Gang of Eight: A Defect Taxonomy for Infrastructure as Code Scripts`. The pre-print of the paper is available here: https://akondrahman.github.io/papers/icse20_acid.pdf 

The artifact is available here: https://hub.docker.com/r/akondrahman/acid-puppet

### Dependencies: Docker 

### Documentation on how to run ACID

1. Install Docker on your computer 
2. Go to terminal 
3. run the command `docker pull akondrahman/acid-puppet`
4. run the command `docker run -it --name acid akondrahman/acid-puppet bash` 
5. run the command `cd /ARTIFACT/IaC_Defect_Categ_Revamp/src_categ_revamp/ACID`
6. To get the results for test repositories it takes *~0.8 minutes to complete*. run `python3 main.py`. This command will execute ACID for the test scripts. Upon completion of the analysis `Ended at: 2020-0X-XX XX:XX:XX`, and `Duration: 0.XXX minutes` will be displayed, which indicates that ACID's execution is complete. 
7. Run `cat /ARTIFACT/OUTPUT/TEST_ONLY_CATEG_OUTPUT_FINAL.csv` to see output results. The CSV file contains a mapping between a commit of a repo and a defect category.  


### Documentation on ACID's structure

1. classifier.py: implementation of the rules that are used by ACID 	 
2. constants.py: the constants that are used by ACID 	 
3. diff_parser.py: extract code from commits 	 
4. excavator.py: uses Mercurial and Git libraries to extract commits and puppet files 	 
5. main.py: main script to execute the tool  

### Paper title and Abstract 

*Gang of Eight: A Defect Taxonomy for Infrastructure as Code Scripts* 

_Defects in infrastructure as code (IaC) scripts can have serious consequences, for example, creating large-scale system outages. A taxonomy of IaC defects can be useful for understanding the nature of defects, and identifying activities needed to fix and prevent defects in IaC scripts. The goal of this paper is to help practitioners improve the quality of infrastructure as code (IaC) scripts by developing a defect taxonomy for IaC scripts through qualitative analysis. We develop a taxonomy of IaC defects by applying qualitative analysis on 1,448 defect-related commits collected from open source software (OSS) repositories of the Openstack organization. We conduct a survey with 66 practitioners to assess if they agree with the identified defect categories included in our taxonomy. We quantify the frequency of identified defect categories by analyzing 80,425 commits collected from 291 OSS repositories spanning across 2005 to 2019._ 

_Our defect taxonomy for IaC consists of eight categories, including a category specific to IaC called idempotency (i.e., defects that lead to incorrect system provisioning when the same IaC script is executed multiple times). We observe the surveyed 66 practitioners to agree most with idempotency. The most frequent defect category is configuration data i.e., providing erroneous configuration data in IaC scripts. Our taxonomy and the quantified frequency of the defect categories can help practitioners to improve IaC script quality by prioritizing verification and validation efforts._ 


### DOI and Docker Image 

DOI: _https://doi.org/10.6084/m9.figshare.8986634_

Docker Image: _https://hub.docker.com/r/akondrahman/acid-puppet_