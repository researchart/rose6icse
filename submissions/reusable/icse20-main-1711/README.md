# Artifact Evaluation

This is the artifact, including the source code and dataset, for the ICSE 2020 Technical Track paper: "Understanding the Automated Parameter Optimization on Transfer Learning for Cross-Project Defect Prediction: An Empirical Study". A pre-print of this paper is available at Accepted Paper https://github.com/COLA-Laboratory/icse2020/blob/master/icse2020-paper1711.pdf.

## Background
Data-driven defect prediction has become increasingly important in software engineering process. Since it is not uncommon that data from a software project is insufficient for training a reliable defect prediction model, transfer learning that borrows data/konwledge from other projects to facilitate the model building at the current project, namely Cross-Project Defect Prediction (CPDP), is naturally plausible. Most CPDP techniques involve two major steps, i.e., transfer learning and classification, each of which has at least one parameter to be tuned to achieve their optimal performance. This practice fits well with the purpose of automated parameters optimization. However, there is a lack of thorough understanding about what are the impacts of automated parameters optimization on various CPDP techniques.

Bearing this consideration in mind, this paper presents the first empirical study that looks into such impacts on 62 CPDP techniques, 13 of which are chosen from the existing CPDP literature while the other 49 ones have not been explored before. We build defect prediction models over 20 real-world software projects that are of different scales and characteristics.

Our major finds are:
- Automated parameter optimization substantially improves the defect prediction performance of 77% CPDP techniques with a manageable computational cost. Thus more efforts on this aspect are required in future CPDP studies.
- Transfer learning is of ultimate importance in CPDP. Given a tight computational budget, it is more cost-effective to focus on optimizing the parameter configuration of transfer learning algorithms
- The research on CPDP is far from mature where it is ‘not difficult’ to find a better alternative by making a combination of existing transfer learning and classifica- tion techniques.

## Hyperopt for automated parameter optimisation

Hyperopt is a Python library that provides algorithms and software infrastructure to optimise hyperparameters of machine learning algorithms. In this project, we use Hyperopt as the optimiser (its basic optimisation driver is hyperopt.fmin) to optimise the parameter configurations of the CPDP techniques. The architecture of our automated parameter optimisation on CPDP model by using Hyperopt is as follows.

![](framework.png)

## Investigated datasets

+ AEEEM
+ JURECZKO (12 selected projects)
+ ReLink

## Installation

- `Python==3.6` 
- Install thrid-party packages (In `Anacaonda` environment)
  - `pip install hyperopt`
  - `pip install scikit-learn==0.20.4`
  - `pip install iteration_utilities`
  - `conda install tqdm`
  - `pip install imbalanced-learn==0.4  `
  - `pip install func_timeout`

## A quick start to run experiments

> Please follow `INSTALL.md` before starting to run the code.

+ Run `code\optADPT.py` to evaluate the impact of parameter optimization on the transfer learning in CPDP.
+ Run `code\optCLF.py` to evaluate the impact of parameter optimization on the classifier in CPDP.
+ Run `code\optALL.py` to evaluate the impact of parameter optimization on both transfer learning and classifier in CPDP simultaneously.
+ Run `code\optSEQ.py` to evaluate the impact of parameter optimization in a sequential manner, i.e., optimising the parameters of transfer learning before those of the classifier.

## Further developments

> If you want to investigate more combinations (transfer learning algorithms + classification algorithms), please modify the following parts of code.

1. Add new transfer learning algorithms into `code\Algorithms\domainAdaptation.py`
2. Add new classification algorithms into `code\Algorithms\Classifier.py`
3. Modify the call format in `code\Alogrithms\Framework.py`

## Contact

Code can be found from: https://github.com/COLA-Laboratory/icse2020

If you meet any problems, please feel free to contact us. (From `CONTACT.md`, you can get our e-mails.)

- Ke Li
  - E-mail: k.li@exeter.ac.uk | keli.genius@gmail.com
  - Github ID: JerryI00
- Zilin Xiang
  - E-mail: zilin.xiang@hotmail.com
  - Github ID: ZilinXiang
