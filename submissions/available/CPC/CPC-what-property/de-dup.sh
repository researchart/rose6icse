#!/bin/bash

sort n_distanceLog_all.csv|uniq -c|sed 's/ *[[:digit:]]* *\(.*\)/\1/g'>n_distance_uniq.csv
