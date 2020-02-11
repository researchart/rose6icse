# Repairing Deep Neural Networks: Fix Patterns and Challenges
Significant interest in applying Deep Neural Network (DNN) has fueled the need to support engineering of software that uses DNNs. Repairing software that uses DNNs is one such unmistakable SE need where automated tools could be very helpful; however, we do not fully understand challenges to repairing and patterns that are utilized when manually repairing them. What challenges should automated repair tools address? What are the repair patterns whose automation could help developers? Which repair patterns should be assigned a higher priority for automation? This work presents a comprehensive study of bug fix patterns to address these questions. We have studied 415 repairs from Stack Overflow and 555 repairs from GitHub for five popular deep learning libraries Caffe, Keras, Tensorflow, Theano, and Torch to understand challenges in repairs and bug repair patterns. Our key findings reveal that DNN bug fix patterns are distinctive compared to traditional bug fix patterns; the most common bug fix patterns are fixing data dimension and neural network connectivity; DNN bug fixes have the potential to introduce adversarial vulnerabilities; DNN bug fixes frequently introduce new bugs; and DNN bug localization, reuse of trained model, and coping with frequent releases are major challenges faced by developers when fixing bugs. We also contribute a benchmark of 667 DNN (bug, repair) instances.

We have also analyzed these bug fixes to answer the following research questions:
- What are the most common bug fix patterns?
- Are the bug fix patterns different for different bug types?
- Are the bug fix pattern different for different libraries?
- Does fixing a DNN bug introduces a new bug?
- What are the challenges in fixing DNN bugs?

Our key findings are as follows: DNN bug fix patterns are distinctive compared to traditional bug fix patterns; the most common bug fix
patterns are fixing data dimension and network connectivity; DNN bug fixes have the potential to introduce adversarial vulnerabilities; DNN bug fixes frequently introduce new bugs; and DNN bug localization, reuse of trained model, and coping with frequent releases are major challenges faced by developers when fixing bugs. We also contribute a benchmark of 667 DNN (bug, repair) instances.

The data can be found at https://github.com/lab-design/ICSE2020DNNBugRepair

## Contact Lists
If you have any question, please contact the authors: [Md Johirul Islam] (mislam@iastate.edu) and [Rangeet Pan] (rangeet@iastate.edu) and [Giang Nguyen] (gnguyen@iastate.edu) and [Hridesh Rajan] (hridesh@iastate.edu)

For more information, please see [Contact.md](./CONTACT.md)

## License
This project is licensed under the MIT License - see the [LICENSE.md](./LICENSE.md) file for details.

## DOI
[![DOI](https://zenodo.org/badge/235641090.svg)](https://zenodo.org/badge/latestdoi/235641090)
