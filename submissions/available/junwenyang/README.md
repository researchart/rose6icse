This artifact for our companion paper “Managing data constraints in database-backed web applications (#278)” includes the data-constraint analysis tools we developed - which were used to generate the results in that paper - as well as raw data produced by our user study. 
We hope this artifact can demonstrate the use of our data-constraint analysis tools to reviewers, as well as be useful to users who might be interested in performing similar analysis on different applications.

The artifact has been published as a project on open science framework with DOI `10.17605/OSF.IO/YAEFH`.  

## What's inside the artifact:

Inside the artifact, we wrap up all our scripts with runnable environment into a docker image, for reusability. In addition, for availability, we upload this image as well as related materials (including the companion paper) to our open science framework project.

Below are details of what is included in each part:

### Docker image (for reuse and repurposing):

  1. The source code of our data-constraint analysis tools.

  2. Benchmarks used in our paper to evaluate our data-constraint analysis tools, including

     * The source code of 12 open-source Ruby-on-Rails applications that we evaluate in our study, under `/home/main278/formatchecker/apps/`

     * The 114 issues collected from the bug tracking system of the 12 applications.

  3. The [questionnaires](http://bit.ly/user-questionnaire) and [results of our user study](http://bit.ly/error-message-user-study), located at `/home/main278/user-study`.
  
  4. The necessary environment to run the scripts.

  We also include instructions to enable reviewers to reproduce all the results presented in our paper ` main-278 Managing data constraints in database-backed web applications`, using the scripts in the docker image. 
  
### The open science framework [project](https://osf.io/yaefh/) with DOI: `10.17605/OSF.IO/YAEFH` (for availability):

  1. The docker image, referenced above, uploaded as a 4-part tar file: data-constraint-dockera[a,b,c,d], which enables users to run the docker image without needing dockerhub.

     * You can merge four tar files into one tar by `$ cat data-constraint-dockera* > data-constraint-docker.tar`

     * And extract the tar file by `tar xvf data-constraint-docker.tar`.
   

  2. A copy of the source code of our data format checker (in case users wish to use it outside docker), in `data-constraint-checker-1.0.tar.gz`, including different parameters to analyze different aspects of constraints:

     * `--latest`, extract all constraints in the latest version of the applications
     * `--tva`, analyze the evolution of constraints change
     * `--single`, compare the constraints across layer 
  
  3. The final version of our paper `main-278` uploaded as `data-format-bug.pdf`. 
  
  

## What to do with the artifact and how?

One can use the code and data included in the docker image to analyze data constraints in their own applications directly, or to reproduce the experiments in our paper. 

We put detailed instructions for each of these in the [INSTALL](https://github.com/manageconstraints/rose6icse/blob/master/submissions/available/junwenyang/README.md) file. 
