### Introduction 

The artifact is a Docker image which contains source code for *A*utomated 
*C*ategorizer for *I*nfrastructure as Code *D*efects (*ACID*). ACID 
is a natural language processing tool that automatically idnetifies defect categories in infrastructure as code (IaC) scripts. The Docker image also includes the directories where we have Puppet scripts for which we run ACID and perform empirical analysis. The easiest way to run ACID is to execute instructions 1-6 mentioned below.  

### Dependencies: Docker and Docker Hub  

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