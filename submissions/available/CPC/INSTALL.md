# INSTALL

1. Use ubuntu 16.04, 64bit version or ubuntu 18.04, 64bit version
2. Install [Docker](https://www.docker.com)

   ```bash
   curl -fsSL https://get.docker.com/rootless | sh
   ```

   The script will show the environment variables that are needed to be set.

3. Pull our image

   ```bash
   docker pull xiangzhex/cpc:release
   ```

4. start the container

   ```bash
   systemctl --user start docker
   docker run -ti xiangzhex/cpc:release zsh
   ```

5. Now you're in the container. Enter the following commands to get the result

   ```bash
   cd ~
   ./start.sh
   ```

The script will run for around 2 hours. If everything goes well, the results are stored in the directory `~/result`.

During the running of the script, there'll be output in the stdout. These output are for debugging usage. Please feel free to ingnore them. ALL the result will be stored in the directory `~/result`.

## how to interpret the results

### Table4

#### What and Property

The `property` and `what` parts of table4 has been printed out at the end of the script. You can also `cd` to the `CPC-what-property` directory and run `python2 table4.py` in that directory.

We've improved the distance model and the system a bit, so the results are expected to be slightly better than that in our paper.

##### Output sample

Take the following output as an example. `zero` means this table is the statistics for the propagated comments whose distance to the existing comments are zero. Similarly, `<0.5` and `>=0.5` means the distance are less than 0.5 and larger than or equal to 0.5, respectively. Also, the label `number` means all the comments regardless of the distance.

`category` means the category of comments. This script only generates statistics for `property` and `what`.

`source` means the projects where the propagated comments come from.

```
                         zero
category source
property apacheDB-trunk   844
         collections     1373
what     apacheDB-trunk   178
         collections      115
```

#### How

The output of `how` propagation are excel files. We manually count the statistics of `how`.

### Table 6

The `#N` columns of table 6 are calculated from table 4.
(For each project and category, `#N` = `#pc` - (`#cmt dist=0` + `#cmt dist<0.5` + `#cmt dist>=0.5`)

Other tables are not directly related to the artifact.
