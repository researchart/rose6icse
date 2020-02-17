We provide a docker image that contains the script checkers in Vibranium and all the applications we use in the paper.
Below are steps to run it and reproduce the experiments on docker.

### Pull and run the docker image 
* Login to you docker hub account and pull the [docker image](https://hub.docker.com/repository/docker/managedataconstraints/data-constraints-analyzer):
```
$ docker pull managedataconstraints/data-constraints-analyzer
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
  The data is stored in the [excel file](http://bit.ly/app-versions-vs-constraint-changes).

* Table 4: Data constraints in web applications
  ```
  $ ruby run_apps.rb  --latest-version
  ```
  The data is presented in the [excel file](http://bit.ly/data-constraints-in-web-applications) under the `latest-version #constraints` tab. 

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

  Details presented in the `summary` tab of  the [excel file](http://bit.ly/top-5-popular-types-of-different-layers)

* Table 8: app versions vs constraint changes

  Details presented in the `constraint-evolution` tab of the [excel file](http://bit.ly/app-versions-vs-constraint-changes) 

  Go to the `main278/formatchecker/` script folder and run:
  ```
  $ ruby run_apps.rb --tva 
  ```
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
  
  results can be accessed through [google drive](http://bit.ly/error-message-user-study) or [here](./user-study.html)

  User study questionnaire can be found [here](http://bit.ly/user-questionnaire).
  
  Both file can be found under the folder `main278/user-study` on the docker image.

* The table in the Discussion section of [issues in Django](http://bit.ly/data-constraints-issues-in-Django) 

* [Issues we report to developers and their feedback (Section 7)](https://docs.google.com/spreadsheets/d/1d9wh0BxLLgQaSKSxFTA3ou5RH7P5D8LKaHQ1paU45u8/edit?usp=sharing)

* Source Code for better error message [gem](https://github.com/manangeconstraints/better_error_msg_gem).


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
