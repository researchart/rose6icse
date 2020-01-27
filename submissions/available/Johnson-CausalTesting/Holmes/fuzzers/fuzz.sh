#!/bin/bash

/Users/bjohnson/anaconda3/bin/python fuzz-lowercase.py $1 > $2

/Users/bjohnson/anaconda3/bin/python fuzz-uppercase.py $1 >> $2

/usr/local/bin/node fuzzer-test.js $1 >> $2
