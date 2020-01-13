# Installation

## Requirement

- Docker
- Unix based system

## Structure

SmartBugs is composed of 3 modules:
1. SmartBugs execution framework: https://github.com/smartbugs/smartbugs
2. The dataset of  47,518 smart-contact extracted from the Ethereum network: https://github.com/smartbugs/smartbugs-wild
3. The RAW results of the vulnerability analysis of 9 tools on 47,518 smart contracts :https://github.com/smartbugs/smartbugs-results

## Installation

1. Install Docker: https://docs.docker.com/install/
2. Clone [SmartBugs's repository](https://github.com/smartbugs/smartbugs):
`git clone https://github.com/smartbugs/smartbugs.git`
3. Install python dependencies: `pip3 install -r requirements.txt`

## Usage

HoneyBadger, Maian, Manticore, Mythril, Osiris, Oyente, Securify, Slither, Smartcheck, Solhint

SmartBugs provides a command-line interface that can be used as follows:
```bash
smartBugs.py [-h, --help]
              --file FILES          # the paths to the folder or the Solidity contract to analyze
              --tool TOOLS          # the list of tools to use for the analysis [HoneyBadger, Maian, Manticore, Mythril, Osiris, Oyente, Securify, Slither, Smartcheck, Solhint] (all to use all of them) 
              --skip-existing       # skip the execution that already has results
              --processes PROCESSES # the number of process to use during the analysis (by default 1)
```

## Example 

You can analyse all contracts labelled with type `reentrancy` with the tool oyente by executing:

```bash
python3 smartBugs.py --tool oyente --file dataset/reentrancy
```