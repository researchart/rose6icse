# SLACC: Simion-based Language Agnostic Code Clones
This repository contains source code and scripts to obtain results for the paper ["SLACC: Simion-based Language Agnostic Code Clones"](https://github.com/DynamicCodeSearch/SLACC/blob/ICSE20/SLACC_preprint.pdf).

The repository contains two major folders.
* `code/` which contains all the source code and scripts to generate semantic cross language code clones.
* `projects/` which contains the datasets which can be checked for semantic code clones. Each dataset has its dedicated folder for all the supported languages. For example, for the dataset used in the ICSE paper(`CodeJam`), the java code for the projects are in the folder `SLACC/projects/src/main/java/CodeJam`; while the python code for the projects are in the folder `SLACC/projects/src/main/<language>/<dataset>`

## Setting it up
The artifacts for SLACC can be installed by following the instructions in [INSTALL.md](https://github.com/DynamicCodeSearch/SLACC/blob/ICSE20/INSTALL.md). SLACC can either be [setup from scratch](https://github.com/DynamicCodeSearch/SLACC/edit/ICSE20/INSTALL.md#setting-up-from-scratch) or reusing the preconfigured [virtualbox image](https://github.com/DynamicCodeSearch/SLACC/edit/ICSE20/INSTALL.md#preconfigured-image). We would recommend using the preconfigured image for prototyping or running the `Example` dataset used in the motivation section of the paper. For running the `CodeJam` dataset, it might be best to setup from the scratch or use the image on a machine with at least 16GB of memory and 2 processors.

## Datasets
* `CodeJam` : Study on four problems from Google Code Jam (GCJ) repository and their valid submissions in Java and Python. We use the first problem from the fifth round of GCJ from 2011 to 2014. Overall in this study, we consider 247 projects; 170 from Java and 77 from Python. 
* `Example`: A sample program that contains 3 (2 in python, 1 in java) implementations of interleaving of arrays used in the `Motivation` section of the paper. 

## Running SLACC
Make sure [SLACC is setup](https://github.com/DynamicCodeSearch/SLACC/blob/ICSE20/INSTALL.md) and the database is running before trying to run the following scripts.

**On Ubuntu**
```
> sudo systemctl start mongod
```

[**On MacOS**](https://docs.mongodb.com/manual/tutorial/manage-mongodb-processes/#start-mongod-as-a-daemon)
```
> mongod --fork --logpath /var/log/mongodb/mongod.log
```

All code to run SLACC is made from the directory code. Navigate into this folder before executing subsequent scripts.
```
> cd code
```

### 1. Obtaining Datasets(OPTIONAL)
This stage is not required on the preconfigured image or when cloned, since the source code for both datasets are automatically added in the `projects/` folder. That said, if the datasets need to be changed follow the following commands.
##### For `CodeJam`
* The repository already contains the java and python files in `projects/src/main/java/CodeJam` and `projects/src/main/python/Codejam` respectively.
* To download these projects again, run 
```
# For java
> sh scripts/codejam/java/download.sh
# For python
> sh scripts/codejam/python/download.sh
```
##### For `Example`
* The repository already contains the java and python files in `projects/src/main/java/Example` and `projects/src/main/python/Example` respectively. Modify it and rerun SLACC for observing differnet clusters.

### 2. Initializing SLACC
Next up we initialize SLACC for a dataset. This phase reinitializes the database and clears all the old metadata. To run this, execute
```
> sh scripts/common/initialize.sh <dataset>
```

For example, to initialize the dataset `Example`, execute
```
> sh scripts/common/initialize.sh Example
```

SLACC can then be executed on a dataset by [running all stages at once](https://github.com/DynamicCodeSearch/SLACC/blob/ICSE20/README.md#3-running-all-stages-for-a-dataset) or [each stage independently](https://github.com/DynamicCodeSearch/SLACC/blob/ICSE20/README.md#4-running-each-stage-separately). For small datasets like `Example` or prototyping, it is best to run all stages at once as it will take under 2 minutes on the Virtualbox image. For larger datasets like `CodeJam`, we would advice to run each stage independently as the **Function Execution** stage might crash due to excessive memory usage and might need to be restarted. In such instances, the function execution will pick up from where it crashed and no prior execution results will be lost.

### 3. Running all stages for a dataset
To run all stages of SLACC for a dataset, execute
```
> sh scripts/common/runner.sh <dataset>
```

For example, to run all stages of SLACC for the dataset `Example`, execute
```
> sh scripts/common/runner.sh Example
```
The results can be accessed by following the steps in [results](https://github.com/DynamicCodeSearch/SLACC/blob/ICSE20/README.md#5-results) section below.

### 4. Running each stage separately

#### a) Snip

##### Java
  * For snipping the functions, run 
  ```
  > scripts/java/snip.sh <dataset>
  ```
  * For generating permutations for the snipped functions, run 
  ```
  > sh scripts/java/permutate.sh <dataset>
  ```
##### Python:  
  * For snipping and permutating the functions, run 
  ```
  > sh scripts/python/snip.sh <dataset>
  ```
  
#### b) Extracting arguments and metadata
##### Java:
  * First, objects are identified and the metadata is stored in the database. Run
  ```
  > sh scripts/java/store_objects.sh <dataset>`
  ```
  * Next, we extract the primitive arguments. Run 
  ```
  > sh scripts/java/extract_primitive_arguments.sh <dataset>
  ```
  * Finally we extract the Fuzzed Arguments. Run 
  ```
  > sh scripts/java/extract_fuzzed_arguments.sh <dataset> True
  ```
##### Python:
  * For Python we extract the metadata and any additional argument types not covered by the java argument extractor. Run 
  ```
  > sh scripts/python/extract_metadata.sh <dataset>
  ```
The extracted arguemnts are stored in `primitive_arguments` and `fuzzed_arguments` collection in MongoDB

#### c) Execute functions
##### Java:
  To execute the snipped java functions, run 
  ```
  sh scripts/java/execute.sh <dataset>
  ``` 
  The executed functions stored in `functions_executed` collection in mongo.
##### Python:
  To execute the snipped python functions, run 
  ```
  > sh scripts/python/execute.sh <dataset>
  ```
  The executed functions stored in `py_functions_executed` collection in mongo.
#### d) Cluster
  Finally the executed functions are can be clustered by running
  ```
  > `sh scripts/common/analyze.sh <dataset>`
  ```
  This script ensures that the functions are clustered for similarity thresholds of `0.01, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30`.
  
### 5. Results
  The cluster results are stored as `.txt` files, `.pkl` files and in the database.
  * `.txt` - These files contains the functions grouped as clusters in a readable format. This can be accessed from the folder `code/meta_results/<dataset>/clusters/cluster_testing/eps_<threshold>/*.txt`. There are four types of `.txt` files in this folder
    * `java_python.txt` : Contains all the clusters.
    * `only_java.txt`: Contains all the clusters with only java functions.
    * `only_python.txt`: Contains all the clusters with only python functions.
    * `only_mixed.txt`: Contains all the clusters with only mixed functions.
  * `.pkl` - These files contains the functions grouped as clusters in a reusable python format. This can be accessed from the folder `code/meta_results/<dataset>/clusters/cluster_testing/eps_<threshold>/*.pkl`. Like the `.txt` files, there are four types of `.pkl` files in this folder all representing the same types of clusters.
  * **Database**: Clusters are also stored in the database for thresholds varying between `0.01` and `0.30` in collections approporiately named as `clusters_<threshold>`.
  
  
  To access the clusters generated for the `Example` dataset, run
  ```
  > cat meta_results/Example/clusters/cluster_testing/eps_0.01/only_mixed.txt
  ```
  There should be two clusters, one representing the complete interleave and another representing a partial interleave. The clusters should look as show below
  ```
  

****** Cluster 68 ******
public static String func_29bae602199d4dc7accf137be62131e0(Integer[] a, Integer[] b){
    String result = "";
    int i = 0;
    for (i = 0; i < a.length && i < b.length; i++) {
        result += a[i];
        result += b[i];
    }
    Integer[] remaining = a.length < b.length ? b : a;
    for (int j = i; j < remaining.length; j++) {
        result += remaining[j];
    }
    return result;
}
def func_4e0f71a6fbd248af83dc763c508a14e5(l1, l2):
    result = ''
    a1, a2 = len(l1), len(l2)
    for i in range(max(a1, a2)):
        if i < a1:
            result += str(l1[i])
        if i < a2:
            result += str(l2[i])
    return result



****** Cluster 20 ******
public static String func_d5770ad5257d4e5da0ff719987570b1a(Integer[] a, Integer[] b){
    String result = "";
    int i = 0;
    for (i = 0; i < a.length && i < b.length; i++) {
        result += a[i];
        result += b[i];
    }
    return result;
}
public static String func_31fe2eac986843068d97c5d5883d2708(Integer[] a, Integer[] b){
    String result = "";
    int i = 0;
    for (i = 0; i < a.length && i < b.length; i++) {
        result += a[i];
        result += b[i];
    }
    Integer[] remaining = a.length < b.length ? b : a;
    return result;
}
def func_6552277742934f47bca79259b014f81c(l1, l2):
    zipped = chain.from_iterable(zip(l1, l2))
    return ''.join([str(x) for x in zipped])

  ```
