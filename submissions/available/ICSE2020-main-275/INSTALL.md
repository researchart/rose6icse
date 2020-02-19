# Install

The analysis of the paper "Recognizing Developers’ Emotions while Programming" has been executed using R, version 3.5

To install all the libraries needed to run the scripts use the command: 

```
Rscript install.R
```
### Dependencies

The most important dependencies used are:

- [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)
- [lme4](https://cran.r-project.org/web/packages/lme4/index.html)
- [caret](https://cran.r-project.org/web/packages/caret/index.html)


In the following, we provided a description of the folders contained in the replication package, as well as the instructions to run the scripts and replicate the results we reported in the study.

- RangeOfEmotions, contains input data, scripts and results for analysing the range of emotions which have been self-reported by developers during programming task and during elicitation. Specifically, the plot representing the Russell circumplex model and the boxplots are created with the command: 

  ```
  Rscript circumplexModel.R emotions_rating.csv interruptions_rating.csv
  ```

  

- Correlation, contains input data, scripts and results for analysing the correlation between emotions and progress, using the linear mixed model and the Spearman correlation. To compute the linear mixed model use the command: 

  ```
  Rscript linearMixedModel.R interruptions_rating_normalized.csv
  ```

  To compute the Spearman rho coefficient and create line charts with emotion and progress rating for each subject use the command:  

  ```
  Rscript Correlation.R interruptions_rating_normalized.csv
  ```

  

- MachineLearning, contains: 

  - scripts for preprocessing biometric signals, extracting features and creating datasets.  For reasons related to privacy, we are not including the raw data of all participants. However, we provide the data of one participant as example for running the script . 

    ```
    Rscript Emotions.R
    ```

  - script for creating dataset with the features concatenated for each device

    ```
    Rscript concatenateDataset.R <input_dir>
    ```

  ```
  where <input_dir> is the folder which contains the output of Emotions.R 
  ```

- DatasetEmotions, datasets used as input for parameter tuning and classification: 

  - For the Hold-out setting, we used the dataset "SAM_valence.csv", and "SAM_arousal.csv". The dataset is splitted into training and testing set inside the scripts

  - For the leave one subject out setting we used a specific combination of training and test datasets (i.e the *i-th* training file contains features extracted from all subjects, except *i*, while i-th* testing file contains the features extracted from the subject *i*). The training datasets are contained in the folder "Training_disambiguated_valence" and "Training_disambiguated_arousal", while the testing datasets are contained in the folders "Testing_disambiguated_valence" and "Testing_disambiguated_arousal"

  - Analysis, contains script for tuning parameters and creating models in the two settings:

    - Hold out

      ```
      nohup ./run_HoldOut.sh <input.csv> models/models_all.txt <output_folder> <signal> <label> &> log.txt &
      ```

      where, <input> is the input dataset,  <output_folder> is the name of the folder where saving the output, <signal> is used to select the features that have to be used for creating the model (it can be: EEG, E4 or ALL), <label> is the class to classify (it can be valence or arousal). 

      For example, the command to replicate the results of the "Full set" for the valence dimension is: 

      ```
      nohup ./run_HoldOut.sh SAM_valence models/models_all.txt results_SAM_valence ALL valence &> log.txt &
      ```

      The output folder will contain eight .txt files, one for each model created. Each files contains the results of the parameter tuning and the performance of the model created, repeated for 10 times (10-fold cross validation). In the paper the results are reported as average over the 10 runs.

    - Leave one subject out

      ```
      nohup ./run-tuning_LOSO.sh <Training_folder> <Testing_folder> <filename> models/models_all.txt <output_folder> <signal> <label> &> log.txt &
      ```

      where, <Training_folder> is the folder with the training datasets (Training_i contains the features of all subject, except the subject *i*) ,  <Testing_folder> is the folder with the testing datasets (Testing_i contains the features of the subject *i*),  <filename> is the name of file without the suffix "Training_i" (it must be tha same for the training and testing files), <output_folder> is the folder where save the output, <signal> is used to select the features that have to be used for creating the model (it can be: EEG, E4 or ALL), <label> is the class to classify (it can be valence or arousal)

      For example, the command to replicate the results of the "Full set" for the valence dimension is: 

      ```
      nohup ./run-tuning_LOSO.sh BySubject/Training_disambiguated_valence BySubject/Testing_disambiguated_valence disambiguated_valence models/models_all.txt resulst_SAM_valence ALL valence &> log.txt &
      ```

      The output folder will contain eight .txt files, one for each model created. Each files contains the results of the parameter tuning and the performance of the model created, repeated for 10 times (10-fold cross validation). In the paper the results are reported as average over the 10 runs.

      - Results parsing.ipynb is a jupyter notebook that reads all the eight files and produce an unique .csv files containing, for each algorithm, the results of the single run. 

  - BestResults.xlsx, contains the results obtained for each run (Hold out) and for each subject (Leave One Subject Out) by the model with the highest performance.
