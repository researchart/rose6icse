# FRMiner

### Project Archive
This project is archived in [https://archive.softwareheritage.org/browse/origin/https://github.com/FRMiner/FRMiner/directory/](https://archive.softwareheritage.org/browse/origin/https://github.com/FRMiner/FRMiner/directory/).

### Project Description
This is the code for `Detection of Hidden Feature Requests from Massive Chat Messages via Deep Siamese Network`(FRMiner). 


FRMiner identifies feature request dialog from massive chat log with a pair-wise network structure which can improve the requirement gathering process significantly.


We release the code and annotated data to help you to reproduce our model and conduct further research.



### Requirements
- Please check the [installation guide](./INSTALL.md) to configure your environment


### File organization
- `data/`
    - `origin_data/`: original dialogues data 
    - `*_feature.txt`: converted feature dialogues
    - `*_other.txt`: converted non-feature dialogues
    - `glove.6B.50d.txt`: Pretrained word2vec file, and you need to download this file at [Glove](https://nlp.stanford.edu/projects/glove/), then put it into this folder
- `src/`
    - `config.json`: a json file including settings
    - `finetune_config.json`: a json file for fine-tuning
    - `p_frminer_reader.py`: dataset reader for p-FRMiner
    - `p_frminer_model.py`: p-FRMiner model
    - `frminer_reader.py`: dataset reader for FRMiner
    - `frminer_model.py`: FRMiner model
    - `preprocess.py`: dataset preprocess and split
    - `siamese_metric.py`: metric for FRMiner
    - `util.py`: some util functions


### Parameters Configuration
`config.json` is the config file. Some key json fields in config file are specified as follows：

```json
"train_data_path": train file path
"validation_data_path": test file path
"text_field_embedder": word embedding, including pre-trained file and dimension of embedding 
"pos_tag_embedding": pos-tag embedding
"optimizer": optimizer, we use Adam here
"num_epochs": training epochs
"cuda_device": training with CPU or GPU
```

### Train & Test

Open terminal in the parent folder which is the same directory level as `FRMiner` and run
``allennlp train <config file> -s <serialization path> -f --include-package FRMiner``.

For example, with `allennlp train FRMiner/config.json -s FRMiner/out/ -f --include-package FRMiner`, you can get
the output folder at `FRMiner/out` and log information showed on the console.
