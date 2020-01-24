# Installation

## Requirements

- Unix-based system
- [Docker](https://docs.docker.com/install)
- [Python3](https://www.python.org)


## Structure

SmartBugs is composed of 3 modules:
1. SmartBugs execution framework: https://github.com/smartbugs/smartbugs
2. The dataset of  47,518 smart-contact extracted from the Ethereum network: https://github.com/smartbugs/smartbugs-wild
3. The RAW results of the vulnerability analysis of 9 tools on 47,518 smart contracts: https://github.com/smartbugs/smartbugs-results


## Installation

Once you have Docker and Python3 installed in your system, follow the steps:

1. Clone [SmartBugs's repository](https://github.com/smartbugs/smartbugs):
`git clone https://github.com/smartbugs/smartbugs.git`
2. Install python dependencies: `pip3 install -r requirements.txt`


## Alternative Installation Methods

- We provide a [Vagrant box that you can use to experiment with SmartBugs](https://github.com/smartbugs/smartbugs/tree/master/utils/vagrant)


## Usage

Tools available: HoneyBadger, Maian, Manticore, Mythril, Osiris, Oyente, Securify, Slither, Smartcheck, Solhint

SmartBugs provides a command-line interface that can be used as follows:
```bash
smartBugs.py [-h, --help]
              --list tools          # list all the tools available
              --list dataset        # list all the datasets available
              --dataset DATASET     # the name of the dataset to analyze (e.g. reentrancy)
              --file FILES          # the paths to the folder(s) or the Solidity contract(s) to analyze
              --tool TOOLS          # the list of tools to use for the analysis (all to use all of them) 
              --info TOOL           # show information about tool
              --skip-existing       # skip the execution that already has results
              --processes PROCESSES # the number of process to use during the analysis (by default 1)
```


## Example 

You can analyse all contracts labelled with type `reentrancy` with the tool oyente by executing:

```bash
python3 smartBugs.py --tool oyente --dataset reentrancy
```

To analyze a specific file (or folder), you can use the option `--file`. For example, to run all the tools on the file `dataset/reentrancy/simple_dao.sol`:

```bash
python3 smartBugs.py --tool all --file dataset/reentrancy/simple_dao.sol
```

By default, results will be placed in the directory `results`. 
