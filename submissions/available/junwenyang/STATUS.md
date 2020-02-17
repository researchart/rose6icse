We apply for the available badge. 

The replication package is availabe through the open science framework [project](https://osf.io/yaefh/) with DOI: `10.17605/OSF.IO/YAEFH`. Inside this project, we provides all materails to reproduce our results. 

  1. The docker image uploaded as 4 tar file: data-constraint-dockera[a,b,c,d], which enables you to run the docker image without the dockerhub.

     * You can merge four tar files into one tar by `$ cat data-constraint-dockera* > data-constraint-docker.tar`

     * And extract the tar file by `tar xvf data-constraint-docker.tar`.
   

  2. The source code of our data-constraint analysis tools in `data-constraint-checker-1.0.tar.gz`, including different parameters to analyze different aspects of constraints:

     * --lastest, extract all constraints in the latest version of the applications
     * --tva, analyze the evolution of constraints change
     * --single, compare the constraints across layer 
  
  3. The final version of our paper `main-278` uploaded as `data-format-bug.pdf`. 
  
