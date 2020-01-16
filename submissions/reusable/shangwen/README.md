The artifact contains part of the execution logs in our experiment and all the generated plausible patches which are stored in the folders _Execution logs_ and _Patches_, respectively.

To perform our study, we utilize the recent platform **RepairThemAll** (https://github.com/program-repair/RepairThemAll). We use totally 10 APR tools through this platform which are _jGenProg, jKali, jMutRepair, Cardumen, Arja, GenProg-A, Kali-A, RSRepair-A, Nopol, and DynaMoth_. The other six tools (_SimFix, kPar, AVATAR, FixMiner, TBar, and ACS_) are all open-source and we make modifications based on each individual repository. However, due to the execution path problem, our .jar files cannot be run under other environments. 

The folder NFL contains the data from experiment whose Fault Localization strategy is to utilize results from the state-of-the-art tool GZoltar1.7, while the folder PFL contains the data from experiment whose Fault Localization strategy is to feed APR tools with the ground-truth locations, representing *Normal Fault Localization* and *Perfect Fault Localization*, respectively.

We report all the generated plausible patches in our study to facilitate future research. As for execution logs, we only record those from **RepairThemAll** platform where ***AstorSystem*** represents _jGenPRog, jKali, jMutRepair, and Cardumen_ four repair tools, ***ArjaSystem*** represents _Arja, GenProg-A, Kali-A, RSRepair-A_ four repair tools, and ***NopolSystem*** represents _Nopol and DynaMoth_ two repair tools.

As for NPC values, the information for tools from **RepairThemAll** is stored in their execution logs. At the bottom of each log, the are three lines in this form
> NR_GENERATIONS=X

> NR_RIGHT_COMPILATIONS=Y

> NR_FAILLING_COMPILATIONS=Z

where *X* represents the total NPC, *Y* represents the NPC_<sub>in-plausible</sub>, *Z* represents the NPC_<sub>nonsential</sub>.

Information for other tools are illustrated by the naming rule of the patch: Patch_NPC_NPC_<sub>in-plausible</sub>. For example, Patch_8_5 means the NPC score is 8 and 5 in-plausible patches have been generated.

All the data in this repository can be found at https://github.com/APRStudy/APRStudy.
