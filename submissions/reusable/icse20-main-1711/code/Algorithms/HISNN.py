import numpy as np
from scipy.spatial import distance
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.neighbors import NearestNeighbors
from sklearn.metrics import roc_auc_score
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.naive_bayes import *
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import RidgeClassifier


class HISNN(object):
    def __init__(self, Xs, Ys, Xt, Yt,MinHam=1.0, n_neighbors=5,clf='RF',
                 n_estimators=10, criterion='gini', max_features='auto', RFmin_samples_split=2,  # RF
                 Boostnestimator=50, BoostLearnrate=1,                                           # Boost
                 NNactive='relu', NNalpha=0.0001, NNmaxiter=200,                                 # NN
                 CARTsplitter='best',                                                            # CART
                 Ridgealpha=1, Ridgenormalize=False,                                             # Ridge
                 KNNneighbors=5,                                                                 # KNN
                 NBtype='gaussian',
                 SVCkernel='poly', C=1, degree=3, coef0=0.0, SVCgamma=1):
        self.MinHam = MinHam
        self.neighbors = n_neighbors
        self.Xsource = np.asarray(Xs)
        self.Ysource = np.asarray(Ys)
        self.Xtarget = np.asarray(Xt)
        self.Ytarget = np.asarray(Yt)
        self.clfType = clf

        if self.clfType == 'RF':
            self.m = RandomForestClassifier(n_estimators=n_estimators, criterion=criterion,
                                            max_features=max_features, min_samples_split=RFmin_samples_split)
        if self.clfType == 'SVM':
            self.m = SVC(kernel=SVCkernel, C=C, degree=degree, coef0=coef0, gamma=SVCgamma)
        if self.clfType == 'Boost':
            self.m = AdaBoostClassifier(n_estimators=Boostnestimator, learning_rate=BoostLearnrate)
        if self.clfType == 'NN':
            self.m = MLPClassifier(activation=NNactive, alpha=NNalpha, max_iter=NNmaxiter)
        if self.clfType == 'KNN':
            self.m = KNeighborsClassifier(n_neighbors=KNNneighbors)
        if self.clfType == 'NB':
            if NBtype == 'gaussian':
                self.m = GaussianNB()
            elif NBtype == 'multinomial':
                self.m = MultinomialNB()
            elif NBtype == 'bernoulli':
                self.m = BernoulliNB()
        if self.clfType == 'CART':
            self.m = DecisionTreeClassifier(criterion=criterion, splitter=CARTsplitter, max_features=max_features, min_samples_split=RFmin_samples_split)
        if self.clfType == 'Ridge':
            self.m = RidgeClassifier(alpha=Ridgealpha, normalize=Ridgenormalize)

    def _MahalanobisDist(self, data, base):

        covariance = np.cov(base.T)  # calculate the covarince matrix
        inv_covariance = np.linalg.pinv(covariance)
        mean = np.mean(base, axis=0)
        dist = np.zeros((np.asarray(data)).shape[0])
        for i in range(dist.shape[0]):
            dist[i] = distance.mahalanobis(data[i], mean, inv_covariance)
        return dist


    def _TrainInstanceFiltering(self):
        # source outlier remove based on source
        dist = self._MahalanobisDist(self.Xsource, self.Xsource)
        threshold = np.mean(dist) * 3 * np.std(dist)
        outliers = []
        for i in range(len(dist)):
            if dist[i] > threshold:
                outliers.append(i)  # index of the outlier
        self.Xsource = np.delete(self.Xsource, outliers, axis=0)
        self.Ysource = np.delete(self.Ysource, outliers, axis=0)

        # source outlier remove based on target
        dist = self._MahalanobisDist(self.Xsource, self.Xtarget)
        threshold = np.mean(dist) * 3 * np.std(dist)
        outliers = []
        for i in range(len(dist)):
            if dist[i] > threshold:
                outliers.append(i)  # index of the outlier
        self.Xsource = np.delete(self.Xsource, outliers, axis=0)
        self.Ysource = np.delete(self.Ysource, outliers, axis=0)

        # NN filter for source data based on target
        neigh = NearestNeighbors(radius=self.MinHam, metric='hamming')
        neigh.fit(self.Xsource)

        filtered = []
        for item in self.Xtarget:
            rng = neigh.radius_neighbors(item.reshape(1, -1))
            indexNeighs = rng[1][0]
            for it in indexNeighs:
                if it not in filtered:
                    filtered.append(it)

        a = np.zeros((len(filtered), self.Xsource.shape[1]))
        b = np.zeros(len(filtered))
        for i in range(len(filtered)):
            a[i] = self.Xsource[filtered[i]]
            b[i] = self.Ysource[filtered[i]]

        self.Xsource = a
        self.Ysource = b

    def fit(self):
        self._TrainInstanceFiltering()
        self.m.fit(np.log(self.Xsource + 1), self.Ysource)

    def predict(self):
        predict = np.zeros(self.Xtarget.shape[0])
        neigh = NearestNeighbors(n_neighbors=self.neighbors, radius=self.MinHam, metric='hamming')
        neigh.fit(self.Xsource)

        for i in range(self.Xtarget.shape[0]):
            rng = neigh.radius_neighbors([self.Xtarget[i]])
            indexNeighs = rng[1][0]

            # case 1
            if len(indexNeighs) == 1:
                subRng = neigh.radius_neighbors([self.Xsource[indexNeighs[0]]])
                indexSubNeighs = subRng[1][0]

                if len(indexSubNeighs) == 1:
                    predict[i] = self.m.predict([np.log(self.Xtarget[i] + 1)])
                else:
                    flag = 0
                    isDifferent = self.Ysource[indexSubNeighs[0]]
                    for index in range(1, len(indexSubNeighs)):
                        if self.Ysource[index] != isDifferent:
                            flag = 1
                            break
                    if flag == 0:
                        predict[i] = isDifferent
                    else:
                        predict[i] = self.m.predict([np.log(self.Xtarget[i] + 1)])

            else:
                flag = 0
                isDifferent = self.Ysource[indexNeighs[0]]
                for index in range(1, len(indexNeighs)):
                    if self.Ysource[index] != isDifferent:
                        flag = 1
                        break
                # case 2
                if flag == 0:
                    predict[i] = isDifferent
                # case 3
                else:
                    predict[i] = self.m.predict([np.log(self.Xtarget[i] + 1)])



        self.AUC = roc_auc_score(self.Ytarget, predict)

