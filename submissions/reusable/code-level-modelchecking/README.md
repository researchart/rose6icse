# Code-Level Model Checking in the Software Development Workflow

## Abstract
This experience report describes a style of applying symbolic model checking
  developed over the course of four years at Amazon Web Services (AWS).
Lessons learned are drawn from proving properties of numerous C-based systems,
  e.g., custom hypervisors, encryption code, boot loaders, and an IoT
  operating system.
Using our methodology, we find that we can prove the correctness of industrial
  low-level C-based systems with reasonable effort and predictability.
Furthermore, AWS developers are increasingly writing
  their own formal specifications.
All proofs discussed in this paper are publicly available on GitHub.

## Code-Level Proofs and Specifications Available on GitHub
All proofs and specifications described in the paper are available, under the Apache 2.0 license, on the GitHub repository located at https://github.com/awslabs/aws-c-common/
This is the master repository for AWS C Common library, and is in active use by the AWS C Common development team.
The description of the contents of this repository are based off commit `b0ea9f35df8934f9e03fc3bab3919d55efd69b88`, although they are not expected to change significantly in the future.

### Code-Level Specifications
As discussed in the paper, all specifications we developed have been merged into the public GitHub repo.
For example, the `aws_array_list_is_valid()` function described in the paper is available at https://github.com/awslabs/aws-c-common/blob/b0ea9f35df8934f9e03fc3bab3919d55efd69b88/include/aws/common/array_list.inl#L92
Similarly, the `aws_array_list_get_at_ptr()` function, including its specifications, can be found at
https://github.com/awslabs/aws-c-common/blob/b0ea9f35df8934f9e03fc3bab3919d55efd69b88/include/aws/common/array_list.inl#L334

Specifications for other modules are available in their respective `.c`, `.h`, or `.inl` files.
For example, the specification for the `aws_string` module can be found in https://github.com/awslabs/aws-c-common/blob/b0ea9f35df8934f9e03fc3bab3919d55efd69b88/source/string.c
Note that we took a targeted approach to verification, where we focused our efforts on high-value modules used by the Encryption SDK, so some modules do not yet have formal specifications (e.g., the `uuid` module at https://github.com/awslabs/aws-c-common/blob/b0ea9f35df8934f9e03fc3bab3919d55efd69b88/source/uuid.c )

### Code-Level Verification Harnesses
As discussed in the paper, all code-level verification harnesses are publicly available on the GitHub repo.
Each proof has its own directory, organized into the following directory structure: `.cbmc-batch/jobs/<proofname>`
For example, the `aws_array_list_get_at_ptr()` proof described in the paper is at https://github.com/awslabs/aws-c-common/tree/b0ea9f35df8934f9e03fc3bab3919d55efd69b88/.cbmc-batch/jobs/aws_array_list_get_at_ptr

- `Makefile` is the Makefile needed to build the proof
- `<proofname>_harness.c>` is the actual C code for the proof harness.
- `.cbmc_batch.yaml` is the `.yaml` file that is used by the CI system to execute the proof.

At present, there are 171 code-level proofs in the AWS C Common repository.

### Proof Helper Code
The `.cbmc_batch/<source | stubs | include>` folders include the "proof helper" code described in the paper.

### Proof Results Publicly Available from the CI System
Open any pull request.
For example, https://github.com/awslabs/aws-c-common/pull/566 to choose one at random.
Scroll down to the last commit.
Click on the green checkmark.
Scroll down, and notice the green checkmarks from all the `CBMC Batch: <proofname>` CI jobs.

## Proof Tooling is Available Open-Source
All the tools we use are open-source, and available on GitHub.

CBMC is available at https://github.com/diffblue/cbmc
As of the time of this artifact, it was at commit 2400d104aff652d2c83aacd80fbed54387b3ad59.

CBMC viewer is available at https://github.com/markrtuttle/cbmc/tree/cbmc-viewer
branch: cbmc-viewer
As of the time of this artifact, the commit was be88c82850952e057b56e03ba8c013415357a5cc.

## Verify the Proof Results Locally on your Machine
Follow the instructions in `INSTALL.md`.
