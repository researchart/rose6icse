# TRADER

## Installation

1. Please use Ubuntu 16.04 or 18.04, 64bit version
2. Install [Docker](https://www.docker.com)

   ```bash
   apt-get install -y uidmap
   curl -fsSL https://get.docker.com/rootless | sh
   ```
   Make sure the following environment variables are set:

   ```bash
   export PATH=/home/$USER/bin:$PATH
   export DOCKER_HOST=unix:///run/user/1002/docker.sock
   ```

3. Start docker

   ```bash
   systemctl --user start docker
   ```

4. Pull our docker image

   ```bash
   docker pull traderrnn/trader
   ```

5. Start the container

   ```bash
   docker run -it --rm traderrnn/trader bash
   ```

## Usage

The main functions are located in `main.py` file. For a test drive, please use the following command:

   ```bash
   python3 main.py --phase test
   ```

The above command will give a prediction result, which corresponds to the first value in Table 5.

The `main.py` script provides different options:

   * `--phase`: `test` for testing model performance, `trace` for trace divergence analysis
   * `--method`: `ori` for original model, `rs` for regularization strategies (baseline), `trader` for proposed appraoch
   * `--dataset`: different datasets including `AppReviews`, `IMDB`, `JIRA`, `StackOverflow`, `Yelp`
   * `--model_name`: different model structures including `rnn`, `lstm` and `gru`
   * `--model_size`: different numbers of hidden neurons including `64`, `128` and `256`
   * `--embed_name`: different embeddings including `glove`, `w2v` and `adv`

## Reproduction

Please use the above options to repoduce the results in Table 3-5 in the paper.

### Table 3 and Table 4

To reproduce the results presented in Table 3 and Table 4, please use the following command by providing corresponding `model_name`, `model_size` and `embed_name`:

   ```bash
   python3 main.py --phase trace --model_name [model_name] --model_size [model_size] --embed_name [embed_name]
   ```

Running the above command will give the time and space overhead of trace divergence analysis, and the fitting scores of oracle and buggy machines.

The time overhead was originally measured on the server equipped with GPUs. The artifact provided here runs on CPU for simplicity. Hence, the measurement of time overhead can be slightly different from that in the paper.

##### Output sample

```
Fitting score for oracle machine:       0.974
Fitting score for buggy machine:        0.995
Time overhead:  0.857 (s)
Space overhead: 0.399 (M)
```

### Table 5

To reproduce the results presented in Table 5, please use the following command by providing corresponding `model_name`, `model_size`, `embed_name` and `method`:

   ```bash
   python3 main.py --phase test --model_name [model_name] --model_size [model_size] --embed_name [embed_name] --method [method]
   ```

Running the above command will give the prediction result of the corresponding model.

##### Output sample

```
Testing ../models/AppReviews_rnn_64_glove_original.ckpt
Test accuracy: 67.65
```

Other tables are not directly related to the artifact.
