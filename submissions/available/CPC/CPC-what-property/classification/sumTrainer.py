# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
import xlwt

from sklearn.tree import DecisionTreeClassifier
from sklearn import svm
from sklearn.naive_bayes import BernoulliNB
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import ExtraTreesClassifier

from sklearn.model_selection import train_test_split
from getFtImps import getFeatureImps
from sklearn.metrics import accuracy_score
# 平均精度
from sklearn.metrics import average_precision_score
# 汉明损失
from sklearn.metrics import hamming_loss
# 0-1损失
from sklearn.metrics import zero_one_loss
#jaccard相似度
from sklearn.metrics import jaccard_similarity_score
# f1 score
from sklearn.metrics import f1_score
#排序损失
from sklearn.metrics import label_ranking_loss
from sklearn.metrics import recall_score



def trainer(X, Y, algornum):
    X_train ,X_test, Y_train, Y_test = train_test_split(X,Y,test_size= 0.2, random_state=35)

    #构造一个算法的数组，暂时没有svm
    algors = []
    #bayes = BernoulliNB()
    #svmc = svm.SVC(kernel='linear')
    dtc = DecisionTreeClassifier(random_state= 32)
    rfc = RandomForestClassifier()
    #etc = ExtraTreesClassifier()
    #algors.append(bayes)
    #algors.append(svmc)
    algors.append(dtc)
    algors.append(rfc)
    #algors.append(etc)

    #dtc = DecisionTreeClassifier(random_state= 32)
    model = algors[algornum]
    model.fit(X_train, Y_train)
    Y_predict = model.predict(X_test)



    #分类器评估
    scores=[]
    scores.append(accuracy_score(Y_test, Y_predict))
    scores.append(average_precision_score(Y_test,Y_predict,average='micro' ))
    #scores.append(average_precision_score(Y_test,Y_predict,average='samples' ))
    scores.append(hamming_loss(Y_test, Y_predict))
    #scores.append(zero_one_loss(Y_test, Y_predict))
    #scores.append(jaccard_similarity_score(Y_test, Y_predict))
    scores.append(f1_score(Y_test,Y_predict,average='micro' ))
    #scores.append(f1_score(Y_test,Y_predict,average='macro' ))
    #scores.append(f1_score(Y_test,Y_predict,average='weighted'))
    #scores.append(f1_score(Y_test,Y_predict,average='samples' ))
    #scores.append(label_ranking_loss(Y_test, Y_predict))
    scores.append(recall_score(Y_test, Y_predict, average='micro'))

    scoresNames = ["accuracy_score",
                   "average_precision_score micro",
                   #"average_precision_score samples",
                   "hamming_loss",
                   #"zero_one_loss",
                   #"jaccard_similarity_score",
                   "f1_score micro ",
                   #"f1_score macro ",
                   #"f1_score weighted",
                   #"f1_score samples",
                   #"label_ranking_loss",
                   "recall_micro"
    ]

    # 打印准确率到csv
    '''
    evaluationDataFrame = pd.DataFrame(data={'scoreNames':scoresNames, everyFeatureNames[i]: scores})
    trans_evaluationDataFrame = evaluationDataFrame.T
    trans_evaluationDataFrame.to_csv("C:/Julia/nlp/newcode/ec.csv" , mode = 'a' )
    '''
    # 打印准确率到excel
    for j in range(len(scoresNames)):
        print(scoresNames[j], scores[j])

    return model
