# Installation
To run POSIT, make sure you have a Python 3.7 interpreter together with the Dependencies detailed below.
There are multiple ways to run the tool: training, evaluation, processing, backend/server.
They are described in the [README.md](https://github.com/PPPI/POSIT/blob/master/README.MD) of the main repository which has been made public.
It can be found here: https://github.com/PPPI/POSIT/.
For completeness, we also include them here as well.

## Dependencies
This project requires the following python libraries:
```
tensorflow<=1.15, numpy, gensim, nltk
```
for the main model (mind that tensorflow 1 is used within this repository);
```
xmltodict, beautifulsoup4, html5lib
```
for corpus preprocessing; and
```
scikit-learn
```
for the considered SVM baseline.

## Repository Structure
The repository is structured as follows:
```
crawl_lkml.py            {Python code to obain a 30 e-mail sample from LKML, seed is fixed}
data/                    {Auxilery data used to train the model}
misc.zip/                {Additional scripts and files used during evaluation with a human provided oracle (Sec. 6.1)}
results.zip/ -> test/    {Trained model weights}
                manual/  {Output and scripts used for manual evaluation}
src/ -> baseline/        {rulebased and SVM baselines}
        -> StORMeD/      {StORMeD[1] client and adapted baselines}     
        preprocessor/    {corpus construction scripts for the two corpora used}
        tagger/          {Main model code and utils}
        evaluate.py      {Script to evaluate the main model for current config}
        export_Model.py  {Script to export a TensorFlow model (for reuse in other TF systems)}
        process_pairs.py {Script to process (input, oracle) pairs}
        process.py       {Script to process posts into a text file for further use}
        RPC_serve.py     {Script to run a server accesible via RPC for reuse in other systems}
        train.py         {Script to train a model given current config}
```
The model configuration and hyperparameters can be seen in `./src/tagger/config.py`

## Obtaining StackOverflow data

To obtain the StackOverflow data used in this paper, run the following snippet:
```bash
#!/usr/bin/env bash
wget https://archive.org/download/stackexchange/stackoverflow.com-Posts.7z
p7zip -d stackoverflow.com-Posts.7z
python3 ./src/preprocessor/preprocess.py Posts.xml train 0 50000 true false
python3 ./src/preprocessor/preprocess.py Posts.xml dev 50000 25000 true false
python3 ./src/preprocessor/preprocess.py Posts.xml eval 75000 25000 true false
python3 ./src/preprocessor/preprocess.py Posts.xml train 0 50000 true true
python3 ./src/preprocessor/preprocess.py Posts.xml dev 50000 25000 true true
python3 ./src/preprocessor/preprocess.py Posts.xml eval 75000 25000 true true
```

It is provided in the tool repository in the root folder as `get_data.sh`.


## Preprocessing
To generate training data from `Posts.xml`, first run:
```bash
$ python src/preprocessor/preprocess.py <path of Posts.xml> <output name> <start> <end> <frequency?> <language id?>
```
The second argument should be one of `train/dev/eval` to indicate what part of the data
it represents. The third and fourth arguments represent the offset indices into the 
`Posts.xml` file; from which post to which post. The last two arguments are either `true` 
or `false` and indicate if (1) the `frequency_map.json` file should be used in tagging 
and (2) if language IDs should be recorded in the output files.

After generating the `train/dev/eval.txt` files, one should also generate the dictionary
files needed to convert to and from integers. This can be done as such:
```bash
$ python src/preprocessor/generaty_vocabulary.py <corpus name> <language id?>
```

For the CodeComment corpus, please use the zip: `data/corpora/lucid.zip`. 
To generate the training data, please use the lucid scripts under `src/preprocessor`.
For example:
```bash
     Convert from .lucid json to .txt ------v
[../posit] $ python src/preprocessor/lucid_reader.py ./data/corpora/lucid false
                                     corpus location (unzipped) --^           ^--- Use Language IDs?
                                            v--------- Consolidate the txt file into train, dev and eval
[../posit] $ python src/preprocessor/lucid_preprocessor.py ./data/corpora/lucid false
                                           corpus location (unzipped) --^           ^--- Use Language IDs?
               Generate vocabulary files ------v
[../posit] $ python src/preprocessor/generate_vocabulary.py lucid false
                            corpus name (under data/corpora) --^      ^--- Use Language IDs?
```

A convenience zip is provided under: `data/corpora/SO_n_Lucid_Id.zip`.

## Running the BiLSTM model
To run the model, make sure that the necessary `train/dev/eval.txt` files have been generated with 
the pre-processor scripts and update `./src/tagger/config.py` to point to them. Once that is done, simply
run:

```bash
$ python src/train.py
```
Similarly `evaluate.py` can be run after a training session, but then as a cli argument the location of the 
model.weights folder needs to be provided:
```bash
$ python src/evaluate.py ./<path to model.weights>/<uuid>/model.weights>
```
The path to model.weights is usually under `results/test/<corpus Name>`/

Similarly to `evaluate.py`, `process.py` can be run; however, it requires a further argument:
```bash
$ python src/process.py ./<path to model.weights> ./<path to data to process>
```

For example, to run an evaluation on the trained weights provided with this repository, run:
```bash
$ python src/evaluate.py ./results/test/SO_Freq_Id/7dec5e7f-9c9b-4e7b-a52a-cdb6183f83de_with_crf_with_chars_with_features_epochs_30_dropout_0.500_batch_16_opt_rmsprop_lr_0.0100_lrdecay_0.9500/model.weights
```
The script should automatically match the hyper-parameters based on the `<model_path>/config.json` file. 
Should that fail, manually copying them over to `./src/tagger/config.py` should solve the issue. 

### Model input/output format

The BiLSTM model expects a free-form textual input that it first segments by sentence and then tokenises it with one
remark: the interactive prompt after an evaluation (as performed by `evaluate.py`) expects input as a sentence at a 
time.

As output, depending if the model is trained with language ID or not, the model provides either `(word, tag)` pairs or
the nested tuple of `(word, (tag, language id))`. When output is stored to a file, it is saved as a sentence per line
where each token is presented with `+` as a separator, i.e. `word+tag[+language id]`.

Let's take the following sentence as an example input to a model with language ID output (the first sentence from 
[here](https://stackoverflow.com/questions/53955027/conv4d-in-tf-nn-convolution)):
```
I tried using tf.nn.convolution() for 6D input with 4D filter.
```

The model to outputs the following (once collected to a list):
```python
[
    ('I', ('PRON', 0)),
    ('tried', ('VERB', 0)),
    ('using', ('VERB', 0)),
    ('tf.nn.convolution()', ('method_name', 1)),
    ('for', ('ADP', 0)),
    ('6D', ('NUM', 0)),
    ('input', ('NOUN', 0)),
    ('with', ('CONJ', 0)),
    ('4D', ('NUM', 0)),
    ('filter', ('NOUN', 0)),
    ('.', ('.', 0)),
]
```

Which if stored to a file using the scripts provided in this repository produce a file with the following single line:
```
I+PRON+0 tried+VERB+0 using+VERB+0 tf.nn.convolution()+method_name+1 for+ADP+0 6D+NUM+0 input+NOUN+0 with+CONJ+0 4D+NUM+0 filter+NOUN+0 .+.+0
```

### Manual Investigation Scripts

The scripts and model output used for the manual investigation of POSIT performance on StackOverflow and LKML data are 
provided under `./results/manual/`. In the root of this folder, one can find the model output and the script used to 
produce the `True/False` annotations. The two annotations and the script to compute the score is provided under 
`./results/manual/Scores/`.

## Running the Rule-based and SVM Baselines
For the baselines, please run as follows:
```bash
$ python src/baseline/classification.py <corpus name> <use SVMs?>
```
The second argument should be either `true` or `false`.


## Running the StORMeD baselines
For the StORMeD comparisons, there are multiple scripts depending on the scenario.

For the performance on the evaluation set, run:
```bash
$ python src/baseline/StORMeD/stormed_query_from_eval.py <corpus name> <StORMeD api key>
```

To query with posts from the StackOverflow Data-dump directly, run:
 ```bash
$ python src/baseline/StORMeD/stormed_query_so.py <path to Posts.xml> <offset into Posts.xml> <StORMeD api key>
```

To query stormed on manually selected posts where a human oracle is available, run:
 ```bash
$ python src/baseline/StORMeD/stormed_query_local_so.py <path to selected_Ids_and_revisions.csv> <StORMeD api key>
```

Mind that in all scenarios a API key must be used. As these are associated to an e-mail, we cannot provide one; however,
they can be requested from the official [StORMeD website](https://stormed.inf.usi.ch/). 

The use of the StORMeD API is not restricted only to this project and the interested person should consider other 
use-cases as well. The documentation provided Ponzanelli and others is extensive and this project serves as a demo of 
using it from within Python.

The client code is a slightly adapted version of the python client provided by Ponzanelli et al.

### Evaluation on the Java subset of POSIT data

The dataset used to evaluate the adapted StORMeD on the Java subset of `SO_n_Lucid_Id` is provided via a zip located at
`./data/java.zip`. 

This unzips to create the folder `./data/java/stormed_eval_parse` which contains the chunked dataset as 4 JSON files 
per chunk: 
- `stormed_n.json` (the StORMeD HAST output), 
- `stormed_n_expected.json` (the expected Language ID output), 
- `stormed_n_expected_tags.json` (the expected AST/PoS tag output), 
- `stormed_n_toks.json` (the raw token stream). 

To compute the evaluation of our adapted StORMeD use-case, one need only run:
```bash
$ python ./baseline/StORMeD/stormed_evaluate.py ./data/java/stormed_eval_parse
```

## Predicting code-tags for StackOverflow

The data used to see how well the model would predict missed code-tags (Section 6.1) as well as the scripts to generate
it are provided under `./misc/SO_Posts_Edited`.

`SO-Ids.csv` was obtained by querying the SOTorrent[2] dataset to form an initial set of candidates. This provides those
SO posts which have been edited with the edit comment "code formatting".

These were then filtered manually to those that satisfy the following criteria:
- Must contain introduction of single or triple backticks. 
- May contain whitespace edits. 
- Cannot contain any other form of edits. 

Filtering was performed by uniform random sampling without replacement from the initial set of revisions. 

A log of the run used to generate the dataset is provided as `./misc/SO_Posts_Edited/run_log.txt`.

POSIT's output on this dataset is under `./misc/SO_Posts_Edited/results/paired_posts`, while StORMeD[1]'s is under
`./misc/SO_Posts_Edited/results/stormed/paired_posts`.

## TaskNav++

While the TaskNav source-code is not provided in this repository, the TaskNav++ output, manual investigation results
and scripts used to perform and analyse the manual investigation are made available via the zip: `./TaskNav++_LKML.zip`.

## References

[1] Ponzanelli, L., Mocci, A., & Lanza, M. (2015). 
[StORMeD: Stack overflow ready made data.](https://stormed.inf.usi.ch/) 
IEEE International Working Conference on Mining Software Repositories, 
2015-Augus, 474–477. https://doi.org/10.1109/MSR.2015.67

[2] Baltes, S., Dumani, L., Treude, C., & Diehl, S. (2018, May). 
Sotorrent: Reconstructing and analyzing the evolution of stack overflow posts. 
In Proceedings of the 15th international conference on mining software repositories (pp. 319-330).