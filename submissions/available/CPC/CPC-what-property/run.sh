mvn compile
mvn exec:java
./de-dup.sh
clear
echo "===================="
echo "raw data for table 4"
echo "===================="
python2 table4.py
