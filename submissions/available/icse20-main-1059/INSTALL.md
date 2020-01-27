# Installation instructions

The following instructions allow you to set up the artifact on a GNU/Linux system.
You can either [use the provided VM](#using-the-provided-vm) or [install the artifact manually](#manual-installation-on-linux) which might result in a better performance.

### Using the provided VM
We provide a virtual machine with the pre-installed dependencies.
Note that the tests may run significantly slower on the virtual machine than on a physical machine.

The package can be downloaded [here](https://docs.google.com/document/d/12G_h6recZ4nhAh6VllhnmoIKUoofmKPaAIcRJE9XJvY) as compressed *OVA* file.
You need to import the machine in *VirtualBox 6.1* or newer.
The virtual machine already includes the artifact and all necessary subject programs to run the artifact.

To run the subject program inside the VM, you need to `cd` into the `Artifact` directory by executing

```bash
cd ~/Artifact
```

If the full screen mode does not work in the VM, make sure to use the latest version of `VirtualBox` and select the `VMSVGA` video adapter in the settings of the virtual machine.

### Manual Installation on Linux
`Java 11` or higher, `Python3`, `Python2` and `Graphviz 2.40.1-14` need to be installed on the test system.
The test system must run Arch Linux or a similar GNU/Linux distribution (x64).
The `imagehash`, `mathutils` and `PIL` Python libraries need to be installed on the system Python interpreter.
This can be done with pip:
```bash
pip3 install imagehash mathutils pillow
```

`Blender`, `JQ`, `appleseed`, `Gephi`, `JSONSimple` and `MinimalJSON` are provided with the artifact and do not need to be installed.
All required Java libraries are provided in the `lib/` folder.

Make sure that `Graphviz 2.40.1-14` is installed and that `dot` is executable from the command line. You may run `dot -V` to check if this is the case.

The compiled Appleseed binaries must be located inside a folder called `appleseed` inside the folder of the jar file and contain the Appleseed Python Interpreter.
It is already included in the artifact.
The other subject programs may either be located in their respective subfolder, or installed and executable from the command line.

For a correct statistics output split into single and multiple faults and real-world data, the source folder of the files containing single faults must contain `single` in its name, the source folder for files with multiple mutations must contain `mult` and the real-world folder must contain `realworld`.
The artifact includes the test files from the paper evaluation in their appropriate folder structure.

Blender may need additional dependencies, depending on your operating system.
On a fresh `Ubuntu 18.04 LTS` installation, `libGLU.so.1` from the `libglu-mesa` package is needed to run Blender.
You can try to run Blender from the local path `blender/blender` to see if you need any additional dependencies.

___

# Further steps

To test the successful installation, one can run the following example:
### Example: Running lexical DDMax on a corrupted Real-World JSON file 

In this example, we are running lexical DDMax on a JSON file from our set of real-world corrupted files, namely `6048.json`.
The corrupted JSON file is provided in the artifact package and was also used in the evaluation.
We are going to store the repaired file into a temporary folder (`/tmp/o/`) and compare the result to the original file.
To run DDMax on this file, we run the program with the following command-line arguments:

```bash
java -jar debug-inputs.jar -r -a ddmax -i testfiles/json-invalid-realworld/6048.json -o /tmp/o -T 300000
```

On our test system, this took about 1 minute and 46 seconds (for our three subject programs *JQ*, *Minimal-JSON* and *JSON-Simple*) and produced the three output files (one for each subject) in `/tmp/o/JSONDDMax/`.
To examine the repair quality, we use the `diff` tool and run the following command:

```bash
diff /tmp/o/JSONDDMax/JQ-6048.json testfiles/json-invalid-realworld/6048.json
```

which gives us the following `diff` output:

```
17c17
<   }
---
>   },

```

As we can see, there was one line of code in the JSON file that had an additional comma which made the file invalid.
Lexical DDMax removed the additional comma which fixes the JSON file while recovering as much data as possible.

### Example: Running syntactic DDMax on an artificially corrupted JSON file
Following the above example, we can run syntactic DDMax on a simple artificially mutated JSON file:

```bash
java -jar debug-inputs.jar -r -a ddmaxg -i testfiles/json-invalid-single/7875.json -o /tmp/o
```

This gives us the following diff:

```bash
diff /tmp/o/JSONDDMaxG/JQ-7875.json testfiles/json-invalid-single/7875.json 
```

```
1c1
< { "name" : "echoto" , "script" : "echoto.js", "options" : [ "" ] }
\ No newline at end of file
---
> { "name" : "echoto" , "script" : "echoto.js" ,� "options" : [ "" ] }
\ No newline at end of file

```
As you can see, the non-printable character that was added in the mutation was successfully removed.