import pandas as pd
import gensim
import numpy as np
import xlwt
from sklearn.model_selection import train_test_split
# from getCommentVecByTfidf import getVecByTfidf
from getCommentVecByMean import getVecByMean
from getFtImps import getFeatureImps

from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import LabelBinarizer
from sumTrainer import trainer

from sklearn.tree import DecisionTreeClassifier
from sklearn import svm
from sklearn.naive_bayes import BernoulliNB
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import ExtraTreesClassifier

import gensim.models.keyedvectors as word2vec

data = pd.read_excel("training_set.xlsx", sheet_name="Sheet0")

token1Vec = OneHotEncoder(sparse=False).fit_transform(data[['#token1']])
token2Vec = OneHotEncoder(sparse=False).fit_transform(data[['#token2']])
variablesVec = OneHotEncoder(sparse=False).fit_transform(
    data[['#local_variable']])
classesVec = OneHotEncoder(sparse=False).fit_transform(data[['#classes']])
methodsVec = OneHotEncoder(sparse=False).fit_transform(data[['#methods']])
# parametersVec = OneHotEncoder(sparse = False).fit_transform(data[['# parameters']])
NPVec = OneHotEncoder(sparse=False).fit_transform(data[['#NP']])
VPVec = OneHotEncoder(sparse=False).fit_transform(data[['#VP']])
PPVec = OneHotEncoder(sparse=False).fit_transform(data[['#PP']])
auxpassVec = OneHotEncoder(sparse=False).fit_transform(data[['#auxpass']])
caseVec = OneHotEncoder(sparse=False).fit_transform(data[['#case']])
tmodVec = OneHotEncoder(sparse=False).fit_transform(data[['#tmod']])
advmodVec = OneHotEncoder(sparse=False).fit_transform(data[['#advmod']])
preconjVec = OneHotEncoder(sparse=False).fit_transform(data[['#preconj']])

verbTypeVec = LabelBinarizer().fit_transform(data['verb_type'])
treeVec = LabelBinarizer().fit_transform(data['tree'])
# toTypeVec = LabelBinarizer().fit_transform(data['to_type'])
# forTypeVec = LabelBinarizer().fit_transform(data['for_type'])

model = word2vec.KeyedVectors.load_word2vec_format('./corpus/corpusB_vec.txt',
                                                   binary=False)

n = data.shape[0]
commentVec = np.zeros([n, 200], float)
commentDict = {}

getVecByMean(data, model, commentVec, commentDict)

le = LabelBinarizer()

labels = ["class", "method", "statement", "field", "paramater"]
le.fit(labels)

y1 = le.transform(data['subject1'].astype(str))
y2 = le.transform(data['subject2'].astype(str))

Y = y1 + y2

print(Y)

for i in range(len(Y)):
    for j in range(len(Y[0])):
        if Y[i, j] > 1:
            Y[i, j] = 1

features = [
    commentVec, token1Vec, token2Vec, variablesVec, classesVec, methodsVec,
    verbTypeVec, treeVec, NPVec, VPVec, PPVec, auxpassVec, caseVec, tmodVec,
    advmodVec, preconjVec
]

X = features[0]
for index in range(1, len(features)):
    X = np.hstack((X, features[index]))

models = [DecisionTreeClassifier(random_state=32), RandomForestClassifier()]
modelNames = ["dtc_ent", "rfc_ent"]
for modelInd in range(2):
    fout = open("result_" + modelNames[modelInd] + "_entity.txt", "w")

    model = models[modelInd]

    acc = []
    pre = []
    rec = []
    f1 = []
    ham = []

    for iter in range(5):
        X_train, X_test, Y_train, Y_test = train_test_split(X,
                                                            Y,
                                                            test_size=0.2,
                                                            random_state=35)

        model.fit(X_train, Y_train)
        Y_predict = np.rint(model.predict(X_test)).astype(np.int32)

        import sklearn.metrics as M
        pre.append(M.precision_score(Y_test, Y_predict, average='micro'))
        rec.append(M.recall_score(Y_test, Y_predict, average='micro'))
        f1.append(M.f1_score(Y_test, Y_predict, average='micro'))
        ham.append(M.hamming_loss(Y_test, Y_predict))


    fout.write("Precision:   " + str(np.average(pre)) + " " + str(pre) + "\n")
    fout.write("Recall:      " + str(np.average(rec)) + " " + str(rec) + "\n")
    fout.write("F1:          " + str(np.average(f1)) + " " + str(f1) + "\n")
    fout.write("HammingLoss: " + str(np.average(ham)) + " " + str(ham) + "\n")


    fout.close()
