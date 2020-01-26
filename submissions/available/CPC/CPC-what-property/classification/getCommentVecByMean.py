from cleanSent import cleanSentence
import numpy as np
import pandas as pd


def sent2vec(s, model):
    res = np.zeros(200)
    # sent = cleanSentence(s)
    words = s.split()
    num = 0
    for w in words:
        if model.__contains__(w):
            res += model[w]
        else:
            res += model["method"]
        num += 1.0
    if num == 0:
        return np.zeros(200)
    else:
        return res/num


def getVecByMean(data, model, commentVec, commentDict):
    for i ,sent in enumerate(data['cleanB'].values):
        commentVec[i, :] = sent2vec(sent, model)
        commentDict[(str)(sent2vec(sent, model))] = sent
    return commentDict
