### Introduction 

Our artifact is applicable for the `Reusable` and `Available` badge. Our artifact is a tool called *A*utomated 
*C*ategorizer for *I*nfrastructure as Code *D*efects (*ACID*), which automatically identifies defect categories 
from repositories with Puppet scripts. 

Our artifact is applicable for the `Reusable` badge because: 
- ACID is functional 
- Documentation on how to run ACID is available 
- Documentation on ACID's structure is available to facilitate reuse and repurpose 

Our artifact is applicable for the `Available` badge because: 
- ACID is functional 
- ACID's source code both in a publicly avilable repository (https://github.com/akondrahman/IaC_Defect_Categ_Revamp/tree/master/src_categ_revamp/ACID) and a Docker image (https://hub.docker.com/r/akondrahman/acid-puppet)  
- DOI for ACID is: https://doi.org/10.6084/m9.figshare.8986634 


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