find . -name "*.m" | while read filename; do
	echo $filename
	gsed '1 s/^/% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  \n/' $filename > tmpfile
	mv tmpfile $filename
done

