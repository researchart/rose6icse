## VM requirements and setup

- Download the VM image at the archived Zenodo repository: https://zenodo.org/record/3629099#.XjJ65RNKjOQ
  - Due to upload instability and errors, we had to split the VM image into 29 parts which need to be reconstructed.
  - Please download each part `xaa` through `xbc` in the link above and put it in an empty directory (`/tmp/image-parts`)
  - `cd` into the directory and run `cat * > image.vdi`. This concatenates the parts into the image in the right order.
  - Move the `image.vdi` to a place on the file system
  - Delete the image parts `xaa` through `xbc` (or the entire temporary directory)

- Using [VirtualBox](https://www.virtualbox.org/), go through the wizard to create a new machine. Pick Linux for the `Type`, and Ubuntu (64-bit) as the `Version`. Allocate memory (4096MB or more recommended). Then use the option to create the machine using an existing image ("Use an existing virtual hard disk file") and select the `image.vdi` from the previous step on the file system. The following minimum VM configuration is highly recommended, which can be changed after creating the image:
  - 2 virtual CPUs, Execution Cap to 100%
  - 4096MB RAM
- Boot up the VM. Log in with username/password: `vagrant/vagrant`
- Run `./check.sh | head -n 1`, which will run one sample of our experiments and show the first line. If you see:

```
a668866f0588c175849dd699fa1edfc11ff68d73
```

in the output, then everything is working.
