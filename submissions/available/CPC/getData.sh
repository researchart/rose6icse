#!/bin/bash
mkdir data
mkdir data/aim
mkdir data/source
# get the embedding
wget https://onedrive.live.com/download\?cid\=E09851E3E8F97FB2\&resid\=E09851E3E8F97FB2%21221974\&authkey\=AAmm-OT250Krnqk -O CPC-what-property/data/embedding.txt
mkdir -p CPC-what-property/classification
wget "https://onedrive.live.com/download?cid=E09851E3E8F97FB2&resid=E09851E3E8F97FB2%21223992&authkey=AK-wByWevbXzxxQ" -O CPC-what-property/classification
mkdir -p how-it-is-done/CommentCollection/lib
wget "https://onedrive.live.com/download?cid=E09851E3E8F97FB2&resid=E09851E3E8F97FB2%21223997&authkey=AOs4nwdBOOlFheA" -O how-it-is-done/CommentCollection/lib
