#!/bin/bash

source /etc/profile
 


module load base/MATLAB/2018a

echo $3
echo $4
matlab -nodisplay -nosplash -r "cd('../Benchmarks/$1/'); $3; cd('../../RQs'); RQ1('$1','$2','$4'); exit();"

