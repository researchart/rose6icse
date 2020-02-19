1. Install [VirtualBox](https://www.virtualbox.org).
2. Download the aritfact virtual machine image from [https://doi.org/10.6084/m9.figshare.11592033](https://doi.org/10.6084/m9.figshare.11592033) (select rivulet.ova)
3. Import the downloaded `rivulet.ova` appliance. We suggest allocating at least 10GB of RAM to your VM.
4. Start the VM. The username is `rivulet` and password is `rivulet`. There is an SSH server running, so if you configure a networking interface for the VM, you can SSH in.
5. Run the build of RIVULET, by running `cd rivulet` and then `mvn install`. The build should complete successfully
6. Continue in `README.md` to find instructions to use the artifact. If you would like to examine our versions of the output of any of the benchmarks/experiments, then also download the `output.zip` file from the artifact page on FigShare.