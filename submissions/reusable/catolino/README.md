# READ ME

**REFACTORING COMMUNITY SMELLS IN THE WILD: THE PRACTITIONER’S FIELD MANUAL**

In this document, we present the replication package of the paper "Refactoring Community Smells in the Wild: The Practitioner’s Field Manual" accepted at the 42nd International Conference on Software Engineering - Software Engineering in Society Track (ICSE ’20).


## DOWNLOAD

The replication package can be downloaded at this URL: https://doi.org/10.6084/m9.figshare.10075406

The Camera-Ready version of our paper can be found at this URL: https://drive.google.com/file/d/1kf6518oNaPoLAs0_0F35ZNOJl4EdUtUa/view?usp=sharing

## WHAT TO REPRODUCE
Since we conducted an online experiment through a survey, it is not possible to fully reproduce the study, since different participants might produce a different outcomes.

## REPRODUCING PAPER'S RESULTS

### Replication Package Content

It contains 4 files:
1. SurveyStructure.pdf : This file contains the structure of the survey that we sent to the participants;

2. Scenarios.pdf : This file explains each scenario that corresponds to a specific community smell. These descriptions have been included in the SurveyStructure.pdf;

3. Answers.xlsx: This file contains the answers of the 76 participants. They are divided for each community smell analyzed;

4. Labels.pdf: This pdf shows how we mapped the participants' answers to the refactoring strategies that are presented also in the paper.

### How To Reproduce

As previously explained, running the experiment with different users might produce different results.

Once obtained the responses, based on the open answers received for each community smell, you need to apply the Straussian Grounded Theory, that consists of the following steps:

1. In the first place, one inspector labels survey responses by applying a single label per every piece of text. In particular, the inspector splits sentences using standard text separators (e.g., commas or semicolons) and then assigns initial labels based on the content of the text. Subsequently, the other two/three inspectors have to validate the initial labels and provide suggestions on how to improve them, e.g., if it makes sense to split one of them or aggregate some. After this first step, the inspectors compute the inter-rater agreement using Cohen's k coefficient. 

2. In a second phase, the feedback coming from the first step is taken into account by the first inspector in order to cluster labels that are semantically similar or even identical. To this aim, the inspector applies the semantic similarity principle. The result of this step consists of the renaming of labels to better reflect the various categories identified.

3. The main inspector, together with the other three, iterate over the labels assigned so far until they can reach an agreement with respect to names and meanings of them all. These results in a theoretical saturation, namely the phase in which the analysis of the labels does not propose newer insights and all concepts in the theory are well-developed.

4. Finally, based on the labels assigned to the practitioners' answers, you can proceed with building a taxonomy of refactoring strategies for each community smell considered. 

References for all the techniques used, are available in the camera-ready of the paper (https://drive.google.com/file/d/1kf6518oNaPoLAs0_0F35ZNOJl4EdUtUa/view?usp=sharing) 
