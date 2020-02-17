We provide a docker image that contains the script checkers in our paper main#278 and all the applications we use in the paper.
Below are steps to run it and reproduce the experiments on docker.

### Pull and run the docker image 
* Login to you docker hub account and pull the [docker image](https://hub.docker.com/repository/docker/managedataconstraints/data-constraints-analyzer):
```
$ docker pull managedataconstraints/data-constraints-analyzer:first
```
```
$ docker run -it -p 127.0.0.1:3000:3000 managedataconstraints/data-constraints-analyzer:first
```


### Reproduce experiments in the paper.

* Figure2 
  ```
  $ cd main278/formatchecker/ 
  $ ruby run_apps.rb --tva
  ```
  The output will be stored at the `../log/ouput_#{app_name}.log` file for each corresponding app. 
   
  
* Table 4: Data constraints in web applications
  ```
  $ ruby run_apps.rb  --latest-version
  ```
  The output will be generated in the terminal. 
  
 
* Table 5: # Constraints in DB but not in Application

  Go to the `main278/formatchecker/`  script folder and run:
  ```
  $ ruby run_apps.rb -s --commit-index
  ```
  This will generate a single CSV file for each application under log/absent_constraints_#{app_name}.csv, performing analysis on the commit specified in app_with_commits.txt. You can omit the --commit-index flag to instead analyze the latest version.
  
  Note: You can filter by "absence_type" in order to see only constraints in DB but not in application
  
  To see how this script's CSV output is converted to the table in the paper, you can refer to [this spreadsheet](http://bit.ly/constraint-mismatch) (under tabs "Table 5-6 raw data" and "Table 5-6 summary").
  
* Table 6: # Constraints in Application but not in DB 

  Go to the `main278/formatchecker/`  script folder and run:
  ```
  $ ruby run_apps.rb -s --commit-index
  ```
  This will generate a single CSV file for each application under log/absent_constraints_#{app_name}.csv, performing analysis on the commit specified in app_with_commits.txt. You can omit the --commit-index flag to instead analyze the latest version.

  Note: You can filter by "absence_type" in order to see only constraints in application but not in DB
  
  To see how this script's CSV output is converted to the table in the paper, you can refer to [this spreadsheet](http://bit.ly/constraint-mismatch) (under tabs "Table 5-6 raw data" and "Table 5-6 summary").

* Table 7:  Top 5 popular types of different layer

  Go to the `main278/formatchecker/` script folder and run:
  ``` 
  $ ruby run_apps.rb  --api-breakdown
  ```
  This will generate a single log file for each application under ```log/api_breakdown_#{app_name}.log```
  ```
  $ ruby api_breakdown_spread_sheets.rb 
  ```
  
  The summarized breakdown will be written to output/api_total_breakdown.xlsx. 
  
  ```
  xlsx2csv -n summary output/api_total_breakdown.xlsx 
  ```
  Then the summary will be printed in the terminal.  

 
* Table 8: app versions vs constraint changes

  Go to the `main278/formatchecker/` script folder and run:
  ```
  $ ruby run_apps.rb --tva 
  ```
  The output will be stored at the `../log/ouput_#{app_name}.log` file for each corresponding app. 
   
 
* Table 9:  Data-constraint issues in real-world apps

  Raw issues in the [issue file](http://bit.ly/data-constraints-issues-in-Rails) 

  Go to the `main278/formatchecker/`  script folder and run:
  ```$ cd issues```
  ```$ python extract_breakdown.py```
  
* Table 10: # Mismatch constraints 

  Go to the `main278/formatchecker/`script folder and run:
  ```
  $ ruby run_apps.rb -s --commit-index
  ```
  This will generate a single CSV file for each application under log/mismatch_constraints_#{app_name}.csv, performing analysis on the commit specified in app_with_commits.txt. You can omit the --commit-index flag to instead analyze the latest version.
  
    To see how this script's CSV output is converted to the table in the paper, you can refer to [this spreadsheet](http://bit.ly/constraint-mismatch) (under tabs "Table 10 raw data" and "Table 10 summary").

* User study 
  
  results can be accessed through [file](https://osf.io/sg5x8/) or [here](https://hyperloop-rails.github.io/vibranium/docs/user-study.html)

  User study questionnaire can be found [here](https://osf.io/hb6tg/).
  
  Both file can be found under the folder `main278/user-study` on the docker image.

* The table in the Discussion section of [issues in Django](https://osf.io/4qgnt/) 

* [Issues we report to developers and their feedback (Section 7)](https://osf.io/3cvbz/)

* Source Code for better error message [gem](https://osf.io/wg2mb/).


### Apply on other applications

* Prepare your application

  Go to `main278/formatchecker/apps/` folder, clone your application there. 
  
  ```
  $ git clone git_repo_link app_name
  ```
  
  It's not required to put the file under th app folder, just for convenience to next step. 
  
* Run our scripts.

  Go to `main278/formatchecker/constraint_analyzer` folder. 
  
  ```
  $ ruby main.rb -a ../apps/app_name -h
  ```
