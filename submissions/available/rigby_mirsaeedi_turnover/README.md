# Replication Package

## Install The Tool

1) [Install](https://github.com/CESEL/RelationalGit/blob/master/install.md) the tool and its dependencies.

## Preparation 

1) Restore the [backup of data](https://drive.google.com/drive/folders/1nc7Hu7kbPpavYrCMmCU5SEBlLlZTo5Fv) into MS Sql Server. For each studied project there is a separate database. 
2) Copy the **configuration files** and **simulation.ps1** which are provided in the [replication package](https://github.com/CESEL/RelationalGit/tree/master/ReplicationPackage).
3) Open and modify each configuration file to set the connection string. You need to provide the server address along with the credentials. Following snippet shows a sample of how connection string should be set.

```json
 {
	"ConnectionStrings": {
	  "RelationalGit": "Server=ip_db_server;User Id=user_name;Password=pass_word;Database=coreclr"
	},
	"Mining":{
 		
  	}
 }
```

4) Open **simulations.ps1** using an editor and make sure the config variables defined at the top of the file are reffering to the correct location of the downloaded config files. 

```powershell
# Each of the following variables contains the absolute path of the corresponding configuation file.

$corefx_conf = "absolute/path/to/corefx_conf.json"
$coreclr_conf = "absolute/path/to/coreclr_conf.json"
$roslyn_conf = "absolute/path/to/roslyn_conf.json"
$rust_conf = "absolute/path/to/rust_conf.json"
$kubernetes_conf = "absolute/path/to/kubernetes_conf.json"
```

## Run Simulations

1) Run the **simulations.ps1** script. Open PowerShell and run the following command in the directory of the file

``` powershell

./simulations.ps1

```

This scripts runs all the defined reviewer recommendation algorithms accross all projects. Each run is called a simulation because for each pull request one of the actual reviewers is randomly selected to be replaced by the top recommended reviewer.

**Note**: Make sure you have set the PowerShell [execution policy](https://superuser.com/questions/106360/how-to-enable-execution-of-powershell-scripts) to **Unrestricted** or **RemoteAssigned**.

## Research Questions

In following sections, we show which simulations are used for which research questions. For each simulation, a sample is provided that illustrates how the simulation can be run using the tool.

### RQ1, Review and Turnover: What is the reduction in files at risk to turnover when both authors and reviewers are considered knowledgeable?


```PowerShell

# committers only
dotnet-rgit --cmd simulate-recommender --recommendation-strategy NoReviews --conf-path <path_to_config_file>

# committers + reviewers = what happended in "Reality"
dotnet-rgit --cmd simulate-recommender --recommendation-strategy Reality --conf-path <path_to_config_file>
```

---

### RQ2, Ownership: Does recommending reviewers based on code ownership reduce the number of files at risk to turnover?

```PowerShell

# AuthorshipRec Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy AuthorshipRec --conf-path <path_to_config_file>


# RevOwnRec Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy RecOwnRec  --conf-path <path_to_config_file>

```

---

### RQ3, cHRev: Does a state-of-the-art recommender reduce the number of files at risk to turnover?


```PowerShell

# cHRev Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy cHRev --conf-path <path_to_config_file>
```

---

### RQ4, Learning and Retention: Can we reduce the number of files at risk to turnover by developing learning and retention aware review recommenders?

```PowerShell

# LearnRec Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy LearnRec  --conf-path <path_to_config_file>

# RetentionRec Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy RetentionRec  --conf-path <path_to_config_file>

# TurnoverRec Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy TurnoverRec --conf-path <path_to_config_file>
```

---

### RQ5, Sofia: Can we combine recommenders to balance Expertise, CoreWorkload, and FaR? 

```PowerShell

# Sofia Recommender
dotnet-rgit --cmd simulate-recommender --recommendation-strategy sofia  --conf-path <path_to_config_file>

```

# Results

You need to produce the result per project. The tool provides a set of easy to use commands for generating the results based on the simulations.

## Results RQ1

1) Open the database of a project that you want to see its results.
2) Query the **LossSimulations** table. 
3) Note the id of the **Reality** simulation (reality_sim_id) and **NoReviews** simulations (no_reviews_sim_id). 
4) run the following command to dump the results. Replace {reality_sim_id} and {no_reviews_sim_id} with corresponding ids.

```PowerShell

dotnet-rgit --cmd analyze-simulations --analyze-result-path "path_to_result" --no-reviews-simulation {no_reviews_sim_id} --reality-simulation {reality_sim_id}  --conf-path "PATH_TO_CONF_CoreFX"
```

## Results RQ2, RQ3, RQ4, and RQ5

1) Open the database of a project that you want to see its results.
2) Query the **LossSimulations** table. 
3) Note the id of the **Reality** simulation and all other simulations. 
4) run the following command to dump the result of quartely percentage change of Expertise, CoreWorkload, and Files at Risk. Replace {reality_sim_id} and {rec_sim_idX} with corresponding ids.

```PowerShell

dotnet-rgit --cmd analyze-simulations --analyze-result-path "path_to_result" --recommender-simulation {rec_sim_id1} {rec_sim_id2} {rec_sim_id3} --reality-simulation {reality_sim_id}  --conf-path "PATH_TO_CONF_CoreFX"
```

**Note** 1) Replace _reality_sim_id_ parameter with the id of the Reality simulation. 2) replace _rec_sim_idX_ parameters with the id of other simulations. These ids are separated by a space. in these samples we have three ids for other simulation. 3) replace _path_to_result_ parameter with the path of a folder you want to store the result.

### Interpretation of Results

The tool creates three csv files, **expertise.csv**, **workload.csv** , and **far.csv** respectively. The first column always shows the project's periods (quarters). Each column corresponds to one of the simulations. Each cell shows the percentage change between the actual outcome and the simulated outcome in that period. The last row of a column shows the median of its values.

The following table illustrates how a csv file of a project with 5 periods is formatted, assuming that only cHRev, TurnoverRec, and Sofia got compared with reality.

| Periods       | cHRev         | cHRev         | TurnoverRec   | Sofia         |
| ------------- | ------------- | ------------- | ------------- |-------------- |
| 1  | 9.12  | 20 | 15  | 10  |
| 2  | 45.87  | 30  | 20  | 25  |
| 3  | 25.10  | 40  | 25  | 42  |
| 4  | 32.10  | 50  | 30  | 90  |
| 5  | 10.10  | 60  | 35  | 34.78  |
| Median  | 25.10  | 40  | 25  | 25  |

**Note**: During simulations, for each pull request, one reviewer is randomly selected to be replaced by the top recommended reviewer. Therefore, the results may vary by up to 2.5 percentage points (see details in thesis and paper per project and 215 simulation runs).

