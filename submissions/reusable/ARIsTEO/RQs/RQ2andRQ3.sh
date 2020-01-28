#!/bin/bash  
source /etc/profile


sbatch -J RQ1 -n 10 -N 2 --priority=TOP -t 4-00:00:00  ./launchRQ2andRQ3.sh;

