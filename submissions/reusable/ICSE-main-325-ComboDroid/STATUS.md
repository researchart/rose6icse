We apply for the `Reusable` and `Available` badges.

First, we released our program and artifacts on Zenodo, which are publically `available` for others.
Consider that building required testing environment needs tedious manual work,
we have built artifacts before-hand and provide scripts to execute them automatically as far as possible
to ease the burden of reproducing results of our experiments.

Second, our tool can be `reused` for further purposes.
We describe the workflow and usages of the tool step by step for a comprehensive guideline,
and discuss how it can be reused in depth in the `README.md`.

To name a few, some functionalities of our artifact are easy to reuse:

- The `runComboDroid` script can be used to easily run tests on other apps; 
- The generated combos can be reused for further testing and analyzing purposes;
- The manual execution recording and start-up script recording functionality can be easily reused for other semi-automatic techniques, 
since the recorded traces/scripts are in the form of adb command sequences and standard XML layout files; and
- The instrument functionality of ComboDroid provides fully functional apk files that outputs API call traces via the Android logging system. 
Such instrumented apps can be reused for collecting and analyzing app behaviors.

We hope that the tool could be used by others and make contributions to the community.
