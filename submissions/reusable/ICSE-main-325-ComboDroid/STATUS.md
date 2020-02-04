We apply for the `Reusable` and `Available` badges.

First, we released our program and artifacts, which are `available` for others.
Consider that building required testing environment needs tedious manual work,
we have built artifacts before-hand and provide scripts to execute them automatically as far as possible
to ease the burden of reproducing results of our experiments.

Second, our tool can be `reused` for further testing.
We describe the workflow and usages of the tool step by step for a comprehensive guideline.

To name a few, some functionalities of our artifact are easy to reuse:

- The `runComboDroid` script can be used to easily run tests on other apps; 
- The generated combos can be reused for further testing and analyzing purposes;
- The manual execution recording and start-up script recording functionality can be easily reused for other semi-automatic techniques, 
since the recorded traces/scripts are in the form of adb command sequences and standard XML layout files; and
- The instrument functionality of ComboDroid provides fully functional apk files that outputs full API call traces in the Android device log. 
Such instrumented apps can be reused for collecting and analyzing app behaviors.

We hope that the tool could be used by others and make contributions to the community.