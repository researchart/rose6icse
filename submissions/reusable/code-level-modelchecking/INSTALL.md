# Installation instructions

## Install CBMC and Related Tools - Prebuilt Binaries
For the convenience of the reviewers, prebuilt binaries are available at https://github.com/danielsn/rose6icse/tree/padstone_with_binaries/submissions/available/code-level-modelchecking/binaries

To use them, add the appropriate directory (i.e., macOS, ubuntu18, or windows) to your PATH.

## Install CBMC and Related Tools - Install from Source

### Install CBMC
- CBMC is available at https://github.com/diffblue/cbmc
- As of the time of this artifact, it was at commit `2400d104aff652d2c83aacd80fbed54387b3ad59`
- It can be built and installed by following the instructions at https://github.com/diffblue/cbmc/blob/develop/COMPILING.md
- Make sure to add it to your path

### Install CBMC-viewer
- CBMC viewer is available at https://github.com/markrtuttle/cbmc/tree/cbmc-viewer
branch: cbmc-viewer
- As of the time of this artifact, the commit was `be88c82850952e057b56e03ba8c013415357a5cc`
- Assuming you've cloned to `<CBMC_VIEWER_REPO>`, add the directory `$CBMC_VIEWER_REPO/scripts/cbmc-viewer` to your path

## Clone the aws-c-common Repository
```
git clone https://github.com/awslabs/aws-c-common.git
```

Then, pick a proof to run. Try the `aws_array_list_get_at_ptr()` function from the paper.

```
cd .cbmc-batch/jobs/aws_array_list_get_at_ptr
make report
open html/index.html
```

It takes about 20 seconds on average to generate the report.
If you get errors, make sure that you're using the latest version of CBMC and CBMC-viewer, and that they are correctly set up on your path.
