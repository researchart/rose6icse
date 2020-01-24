# Installation instructions

The following documents how to download + install the RLCheck aritfact on your machine. 

## Requirements

* You will need **Docker** on your system. You can get Docker CE for Ubuntu here: https://docs.docker.com/install/linux/docker-ce/ubuntu. See links on the sidebar for installation on other platforms.

## Load image

To load the artifact on your system, pull the image from the public repo.
```
docker pull carolemieux/rlcheck-artifact
```

## Run container

Run the following to start a container and get a shell in your terminal:

```
docker run --name rlcheck -it carolemieux/rlcheck-artifact
```

You can exit the shell via CTRL+C or CTRL+D or typing `exit`. This will kill running processes, if any, but will preserve changed files. You can re-start an exited container with `docker start -i rlcheck`. Finally, you can clean up with `docker rm rlcheck`.

### Check installation

While in the `rlcheck-artifact` directory of the docker container, you can run the following command to make sure RLCheck runs on your system:

```
export JQF_DIR=/rlcheck-artifact/rlcheck/jqf
timeout 10s $JQF_DIR/bin/jqf-rl -c $($JQF_DIR/scripts/examples_classpath.sh) edu.berkeley.cs.jqf.examples.rhino.CompilerTest testWithInputStream edu.berkeley.cs.jqf.examples.js.JavaScriptRLGenerator $JQF_DIR/configFiles/rhinoConfig.json fuzz_results
```

After 10 seconds, the second command will terminate. If RLCheck works correctly, you should see a few files in `fuzz_results/corpus`, and a few lines in the file `fuzz_results/plot_data`. If the `corpus` directory is blank or the `plot_data` file contains only a header, the installation did not work. 

## Container filesystem

The default directory in the container, `/rlcheck-artifact`, contains the following contents:
- `README.md`: The readme file. 
- `rlcheck`: this is the rlcheck implementation
	- `jqf`: This is the main rlcheck implementation used in the evaluation on top of the the Java fuzzing platform JQF (cloned from https://github.com/rohanpadhye/jqf). 
	- `bst_example`: python implementation used for the case studies in Section 4 of the paper.
- `scripts`: Contains various scripts used for running experiments and generating figures from the paper.
- `pre-baked`: Contains results of the experiments that were run on the authors' machines.
    - `java-data`: data for the main evaluation
    - `python-data`: data for the evaluation of Section 4. 
- `example_figs`: examples of Figures 6-10 with fewer reps, on the author's machine.