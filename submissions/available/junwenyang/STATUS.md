We are applying for the available badge. 

The replication package is available through the open science framework [project](https://osf.io/yaefh/) with DOI: `10.17605/OSF.IO/YAEFH`. Inside this project, we provide all materials to reproduce our results, specifically:

  1. The docker image uploaded as 4-part tar file: data-constraint-dockera[a,b,c,d], which enables you to run the docker image without the dockerhub.

     * You can merge four tar files into one tar by `$ cat data-constraint-dockera* > data-constraint-docker.tar`

     * And extract the tar file by `tar xvf data-constraint-docker.tar`.
   

  2. A copy of the source code of our data-constraint analysis tools in `data-constraint-checker-1.0.tar.gz` (in case one wants to use it outside docker), including different parameters to analyze different aspects of constraints:

     * `--latest`, extract all constraints in the latest version of the applications
     * `--tva`, analyze the evolution of constraints change
     * `--single`, compare the constraints across layer 
  
  3. The final version of our paper `main-278` uploaded as `data-format-bug.pdf`
  
  4. Other relevant materials, including: step-by-step instructions to replicate results, details of issues studied in the paper, and user survey results and questionnaire.
  
