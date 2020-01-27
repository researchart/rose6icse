from Utils.classlib import *
import numpy as np
from sklearn.neighbors import NearestNeighbors
from sklearn.model_selection import train_test_split
from imblearn.over_sampling import SMOTE
from Algorithms.Classifier import *
from sklearn.ensemble import AdaBoostClassifier

from sklearn.metrics import roc_auc_score, accuracy_score


class DTB(object):
    def __init__(self, Xs, Ys, Xt, Yt, n_neighbors=10, iter=20, clf='RF',
                 n_estimators=10, criterion='gini', max_features='auto', RFmin_samples_split=2,     # RF
                 Boostnestimator=50, BoostLearnrate=1,                                              # Boost
                 CARTsplitter='best',                                                               # CART
                 Ridgealpha=1, Ridgenormalize=False,                                                # Ridge
                 NBtype='gaussian',
                 SVCkernel='poly', C=1, degree=3, coef0=0.0, SVCgamma=1
                 ):
        self.Xsource = np.asarray(Xs)
        self.Ysource = np.asarray(Ys)
        self.Xtarget = np.asarray(Xt)
        self.Ytarget = np.asarray(Yt)
        self.n_neighbors = int(n_neighbors)
        self.iter = iter
        self.clfType = clf

        self.n_estimators = n_estimators
        self.criterion = criterion
        self.max_features = max_features
        self.RFmin_samples = RFmin_samples_split
        self.Boostne = Boostnestimator
        self.BoostLearnrate = BoostLearnrate
        self.NBType = NBtype
        self.CARTsplitter = CARTsplitter
        self.Ridgealpha = Ridgealpha
        self.Ridgenormalize = Ridgenormalize
        self.SVCkernel = SVCkernel
        self.coef0 = coef0
        self.gamma = SVCgamma
        self.degree = degree
        self.C = C



    def _NNfilter(self):
        knn = NearestNeighbors()
        knn.fit(self.Xsource)
        data = []
        ysel = []

        for item in self.Xtarget:
            tmp = knn.kneighbors(item.reshape(1, -1), self.n_neighbors, return_distance=False)
            tmp = tmp[0]
            for i in tmp:
                if list(self.Xsource[i]) not in data:
                    data.append(list(self.Xsource[i]))
                    ysel.append(self.Ysource[i])
        self.Xsource = np.asanyarray(data)
        self.Ysource = np.asanyarray(ysel)

    # oversample for minor part
    def _SMOTE(self):
        smote = SMOTE()
        self.Xsource, self.Ysource = smote.fit_resample(self.Xsource, self.Ysource)

    def _max_min(self, x):
        shape = np.asarray(x).shape
        Max = np.zeros(shape[1])
        Min = np.zeros(shape[1])
        for i in range(0, shape[1]):
            a = x[:, i]
            Max[i] = np.max(a)
            Min[i] = np.min(a)

        return Max, Min

    def _weight(self):
        max, min = self._max_min(self.Xtarget)
        shape = self.Xsource.shape
        s = np.zeros(shape[0])
        w = np.zeros(shape[0])
        for i in range(0,shape[0]):
            tmp = 0
            for j in range(0, shape[1]):
                if self.Xsource[i][j] <= max[j] and self.Xsource[i][j] >= min[j]:
                    tmp = tmp + 1
            s[i] = tmp
            w[i] = s[i] / (1.0 * np.power(shape[1] - s[i] + 1, 2))

        return w

    def fit(self):
        self._NNfilter()
        self._SMOTE()
        weight = self._weight()

        trainX, self.testX, trainY, self.testY = train_test_split(self.Xtarget, self.Ytarget, test_size=0.3)
        while len(np.unique(self.testY)) <= 1:
            trainX, testX, trainY, self.testY = train_test_split(self.Xtarget, self.Ytarget, test_size=0.3)
        if self.clfType == 'RF':
            m = RandomForestClassifier(n_estimators=self.n_estimators, criterion=self.criterion,
                                            max_features=self.max_features, min_samples_split=self.RFmin_samples)
        if self.clfType == 'SVM':
            m = SVC(kernel=self.SVCkernel, C=self.C, degree=self.degree, coef0=self.coef0, gamma=self.gamma)
        if self.clfType == 'Boost':
            m = AdaBoostClassifier(n_estimators=self.Boostne, learning_rate=self.BoostLearnrate)
        if self.clfType == 'NB':
            if self.NBType == 'gaussian':
                m = GaussianNB()
            elif self.NBType == 'multinomial':
                m = MultinomialNB()
            elif self.NBType == 'bernoulli':
                m = BernoulliNB()
        if self.clfType == 'CART':
            m = DecisionTreeClassifier(criterion=self.criterion, splitter=self.CARTsplitter, max_features=self.max_features, min_samples_split=self.RFmin_samples)
        if self.clfType == 'Ridge':
            m = RidgeClassifier(alpha=self.Ridgealpha, normalize=self.Ridgenormalize)

        # self.model = trAdaBoost(self.Xsource, trainX, self.Ysource, trainY, testX, self.iter, initWeight=weight, clf=m)
        self.model = AdaBoostClassifier(base_estimator=m, n_estimators=self.iter, algorithm='SAMME')
        self.model.fit(self.Xsource, self.Ysource, sample_weight=weight)


    def predict(self):
        # if self.model.error == 1 or len(np.unique(self.testY)) <= 1:
        #     self.AUC = 0
        #     return
        Ypredict = self.model.predict(self.testX)

        self.AUC = roc_auc_score(self.testY, Ypredict)
        self.acc = accuracy_score(self.testY, Ypredict)
