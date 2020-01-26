
import io
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import PorterStemmer
#word_tokenize accepts a string as an input, not a file.

def cleanSentence(sent):
    ps = PorterStemmer()
    stop_words = set(stopwords.words('stopList'))
    words = sent.split()
    newSent = ""
    for w in words:
        if not w in stop_words:
            nw = ps.stem(w.lower())
            newSent += nw + " "
    newSent = newSent[:-1]
    return newSent