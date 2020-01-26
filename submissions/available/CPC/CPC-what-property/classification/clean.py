import io 
from nltk.corpus import stopwords 
from nltk.tokenize import word_tokenize
from nltk.stem import PorterStemmer
#word_tokenize accepts a string as an input, not a file.


ps = PorterStemmer()
stop_words = set(stopwords.words('stopList')) 


file1 = open("comment.txt")
line = file1.read()# Use this to read file content as a stream: 
words = line.split()
for w in words:
	if not w in stop_words:
		appendFile = open('commentClean.txt','a')	
		nw = ps.stem(w.lower())
		appendFile.write(" "+nw)
		appendFile.close()
