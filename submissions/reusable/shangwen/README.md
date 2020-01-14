The artifact contains part of the execution logs in our experiment and all the generated patches.

The folder NFL contains the data from experiment whose Fault Localization strategy is GZoltar1.7, while the folder PFL contains the data from experiment whose Fault Localization strategy is the ground-truth locations, representing *Normal Fault Localization* and *Perfect Fault Localization*, respectively. The data in our paper is completely based on these information.

To perform our study, we utilize the recent platform **RepairThemAll** (https://github.com/program-repair/RepairThemAll). We use totally 10 APR tools through this platform which are _jGenProg, jKali, jMutRepair, Cardumen, Arja, GenProg-A, Kali-A, RSRepair-A, Nopol, and DynaMoth_. The other six tools (_SimFix, kPar, AVATAR, FixMiner, TBar, and ACS_) are all open-source and we make modifications based on each individual repository. However, due to the execution path problem, our .jar files cannot be run under other environments. 

We report all the generated plausible patches in our study to facilitate future research. As for execution logs, we only record those from **RepairThemAll** platform where ***AstorSystem*** represents _jGenPRog, jKali, jMutRepair, and Cardumen_ four repair tools, ***ArjaSystem*** represents _Arja, GenProg-A, Kali-A, RSRepair-A_ four repair tools, and ***NopolSystem*** represents _Nopol and DynaMoth_ two repair tools.

All the data in this repository can be found at https://github.com/APRStudy/APRStudy.
