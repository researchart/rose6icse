The artifact has been published as a docker image on Docker Hub with the [link](http://bit.ly/docker-image-278).  

This artifact for our companion paper “Managing data constraints in database-backed web applications (#278)” includes the data-constraint analysis tools we developed and raw data produced by our user study. 
We hope this artifact can demonstrate the use of our data-constraint analysis tools to reviewers and potential users.


## What's inside the artifact:

Inside the artifact, we wrap up all our scripts with runnable environment into a docker image, and we upload all related materials to our open science framework project:

### The docker image for facilitation of reusing and re-purposing:

  1. The source code of our data-constraint analysis tools, including different parameters to analyze different aspects of constraints:

     * --lastest, extract all constraints in the latest version of the applications
     * --tva, analyze the evolution of constraints change
     * --single, compare the constraints across layer 

  2. Benchmarks used in our paper to evaluate our data-constraint analysis tools, including

     * The source code of 12 open-source Ruby-on-Rails applications that we evaluate Panorama upon, under `main278/formatchecker/apps/`

     * The 114 issues collected from the bug tracking system of the 12 applications.

  3. The [questionnaires](http://bit.ly/user-questionnaire) and [results of our user study](http://bit.ly/error-message-user-study) is located at `/home/main278/user-study`.
  
### The osf project https://osf.io/yaefh/ for availability.

  1. The docker image is uploaded into 4 tar file: data-constraint-dockera[a,b,c,d], which enables you to run the docker image without the dockerhub.
  ```
  cat data-constraint-dockera* > data-constraint-docker
  ```
  
  Also, the instruction file to run the docker image is in `instruction.pdf`.  
  
  2. The source code of our data format checker is in `data-constraint-checker-1.0.tar.gz`.
  
  3. The pdf of our final version paper of id main-278 is in `data-format-bug.pdf`. 
  
  

## What to do with the artifact and how?

With the code and data included in the docker image, one can use the tool to manage data constraints, directly and also reproduce the experiments in our paper. 

We put detailed instruction of both in the [INSTALL](https://github.com/manageconstraints/rose6icse/blob/master/submissions/available/junwenyang/README.md) file. 
