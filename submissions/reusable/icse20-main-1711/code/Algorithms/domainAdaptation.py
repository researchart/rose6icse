from Utils.helper import *
from sklearn.cluster import DBSCAN, KMeans
from Algorithms.Classifier import *
from sklearn.neighbors import NearestNeighbors
from sklearn.model_selection import cross_val_score
from scipy.spatial.distance import pdist
from scipy.spatial.distance import squareform
from scipy.stats import mannwhitneyu
import Utils.cliffsDelta as cliff
import scipy.spatial.distance as dist
import scipy
import random
import numpy as np
import time

""" transformate into latent space """


def kernel(ker, X, X2, gamma):
    if not ker or ker == 'primal':
        return X
    elif ker == 'linear':
        if not X2:
            K = np.dot(X.T, X)
        else:
            K = np.dot(X.T, X2)
    elif ker == 'rbf':
        n1sq = np.sum(X ** 2, axis=0)
        n1 = X.shape[1]
        if not X2:
            D = (np.ones((n1, 1)) * n1sq).T + np.ones((n1, 1)) * n1sq - 2 * np.dot(X.T, X)
        else:
            n2sq = np.sum(X2 ** 2, axis=0)
            n2 = X2.shape[1]
            D = (np.ones((n2, 1)) * n1sq).T + np.ones((n1, 1)) * n2sq - 2 * np.dot(X.T, X)
        K = np.exp(-gamma * D)
    elif ker == 'sam':
        if not X2:
            D = np.dot(X.T, X)
        else:
            D = np.dot(X.T, X2)
        K = np.exp(-gamma * np.arccos(D) ** 2)
        K[K != K] = 0
    return K


class TCA(object):
    def __init__(self, kernel_type='primal', dim=5, lamb=1, gamma=1):
        '''
        Init func
        :param kernel_type: kernel, values: 'primal' | 'linear' | 'rbf' | 'sam'
        :param dim: dimension after transfer
        :param lamb: lambda value in equation
        :param gamma: kernel bandwidth for rbf kernel
        '''
        self.kernel_type = kernel_type
        self.dim = dim
        self.lamb = lamb
        self.gamma = gamma

    def _normalization(self, type):
        ss = self.Xsource.shape
        tt = self.Xtarget.shape

        if type == 'N1':
            # normalization for source data
            res = np.zeros((ss[0], ss[1]))
            for i in range(ss[1]):
                tmp = self.Xsource[:, i]
                minm = np.min(tmp)
                maxm = np.max(tmp)
                res[:, i] = (tmp - minm) / (maxm - minm)
            self.Xsource = res

            # normalization for target data
            res = np.zeros((tt[0], tt[1]))
            for i in range(tt[1]):
                tmp = self.Xtarget[:, i]
                minm = np.min(tmp)
                maxm = np.max(tmp)
                res[:, i] = (tmp - minm) / (maxm - minm)
            self.Xtarget = res

        elif type == 'N2':
            # normalization for source data
            res = np.zeros((ss[0], ss[1]))
            for i in range(ss[1]):
                tmp = self.Xsource[:, i]
                mean = np.mean(tmp)
                std = np.std(tmp)
                res[:, i] = (tmp - mean) / std
            self.Xsource = res

            # normalization for target data
            res = np.zeros((tt[0], tt[1]))
            for i in range(tt[1]):
                tmp = self.Xtarget[:, i]
                mean = np.mean(tmp)
                std = np.std(tmp)
                res[:, i] = (tmp - mean) / std
            self.Xtarget = res

        elif type == 'N3':
            Smean = []
            Sstd = []
            # normalization for source data
            res = np.zeros((ss[0], ss[1]))
            for i in range(ss[1]):
                tmp = self.Xsource[:, i]
                mean = np.mean(tmp)
                std = np.std(tmp)
                Smean.append(mean)
                Sstd.append(std)
                res[:, i] = (tmp - mean) / std
            self.Xsource = res

            # normalization for target data
            res = np.zeros((tt[0], tt[1]))
            for i in range(tt[1]):
                tmp = self.Xtarget[:, i]
                mean = Smean[i]
                std = Sstd
                res[:, i] = (tmp - mean) / std
            self.Xtarget = res

        elif type == 'N4':
            Smean = []
            Sstd = []

            # normalization for target data
            res = np.zeros((tt[0], tt[1]))
            for i in range(tt[1]):
                tmp = self.Xtarget[:, i]
                mean = np.mean(tmp)
                std = np.std(tmp)
                Smean.append(mean)
                Sstd.append(std)
                res[:, i] = (tmp - mean) / std
            self.Xtarget = res

            # normalization for source data
            res = np.zeros((ss[0], ss[1]))
            for i in range(ss[1]):
                tmp = self.Xsource[:, i]
                mean = Smean[i]
                std = Sstd
                res[:, i] = (tmp - mean) / std
            self.Xsource = res

        elif type == 'N0':
            return

    def _computDCV(self):
        ss = self.Xsource.shape
        tt = self.Xtarget.shape
        Sdist = []
        Tdist = []
        SDCV = []
        TDCV = []

        # compute DCV (dataset characteristic vector) of source dataset
        for i in range(ss[0]):
            for j in range(i + 1, ss[0]):
                Sdist.append(dist.euclidean(self.Xsource[i], self.Xsource[j]))
        SDCV.append(np.mean(np.asarray(Sdist)))
        SDCV.append((np.median(np.asarray(Sdist))))
        SDCV.append(np.min(np.asarray(Sdist)))
        SDCV.append(np.max(np.asarray(Sdist)))
        SDCV.append(np.std(np.asarray(Sdist)))
        SDCV.append(ss[0])

        # compute DCV (dataset characteristic vector) of target dataset
        for i in range(tt[0]):
            for j in range(i + 1, tt[0]):
                Tdist.append(dist.euclidean(self.Xtarget[i], self.Xtarget[j]))
        TDCV.append(np.mean(np.asarray(Tdist)))
        TDCV.append((np.median(np.asarray(Tdist))))
        TDCV.append(np.min(np.asarray(Tdist)))
        TDCV.append(np.max(np.asarray(Tdist)))
        TDCV.append(np.std(np.asarray(Tdist)))
        TDCV.append(ss[0])

        return np.asarray(SDCV), np.asarray(TDCV)

    def _chooseNormalization(self):
        SDCV, TDCV = self._computDCV()

        nominal = []
        for i in range(0, 6):
            if SDCV[i] * 1.6 < TDCV[i]:
                nominal.append('much-more')
            elif TDCV[i] < SDCV[i] * 0.4:
                nominal.append('much-less')
            elif (SDCV[i] * 1.3 < TDCV[i]) and (TDCV[i] <= SDCV[i] * 1.6):
                nominal.append('more')
            elif (SDCV[i] * 1.1 < TDCV[i]) and (TDCV[i] <= SDCV[i] * 1.3):
                nominal.append('slight-more')
            elif (SDCV[i] * 0.9 <= TDCV[i]) and (TDCV[i] <= SDCV[i] * 1.1):
                nominal.append('same')
            elif (SDCV[i] * 0.7 <= TDCV[i]) and (TDCV[i] < SDCV[i] * 0.9):
                nominal.append('slight-less')
            elif (SDCV[i] * 0.4 <= TDCV[i]) and (TDCV[i] < SDCV[i] * 0.7):
                nominal.append('less')

        if (nominal[5] == nominal[2] == nominal[3] == 'much-less') or (
                nominal[5] == nominal[2] == nominal[3] == 'much-more'):
            self._normalization('N1')

        elif ((nominal[4] == 'much-more') and ('less' in nominal[5])) or (
                (nominal[4] == 'much-less') and ('more' in nominal[5])):
            self._normalization('N3')

        elif (nominal[4] == nominal[5] == 'much-more') or (nominal[4] == nominal[5] == 'much-less'):
            self._normalization('N4')

        elif nominal[0] == nominal[4] == 'same':
            self._normalization('N0')

        else:
            self._normalization('N2')

    def run(self, Xs, Ys, Xt, Yt):
        '''
        Transform Xs and Xt
        :param Xs: ns * n_feature, source feature
        :param Xt: nt * n_feature, target feature
        :return: Xs_new and Xt_new after TCA
        '''
        self.Xsource = Xs
        self.Xtarget = Xt
        self._chooseNormalization()
        Xs = self.Xsource
        Xt = self.Xtarget

        X = np.hstack((Xs.T, Xt.T))
        X /= np.linalg.norm(X, axis=0)
        m, n = X.shape
        ns, nt = len(Xs), len(Xt)
        e = np.vstack((1 / ns * np.ones((ns, 1)), -1 / nt * np.ones((nt, 1))))
        M = e * e.T
        M = M / np.linalg.norm(M, 'fro')
        H = np.eye(n) - 1 / n * np.ones((n, n))
        K = kernel(self.kernel_type, X, None, gamma=self.gamma)
        n_eye = m if self.kernel_type == 'primal' else n
        a, b = np.linalg.multi_dot([K, M, K.T]) + self.lamb * np.eye(n_eye), np.linalg.multi_dot([K, H, K.T])
        w, V = scipy.linalg.eig(a, b)
        ind = np.argsort(w)
        A = V[:, ind[:self.dim]]
        Z = np.dot(A.T, K)
        Z /= np.linalg.norm(Z, axis=0)
        Xs_new, Xt_new = Z[:, :ns].T, Z[:, ns:].T
        return Xs_new, Ys, Xt_new, Yt


""" pick the proper instance from source data """


class DBSCANfilter(object):
    def __init__(self, eps=1.0, min_samples=10):
        self.dbscan = DBSCAN(eps=eps, min_samples=min_samples)

    def run(self, Xsource, Ysource, Xtarget, Ytarget):
        Tdata = np.append(Xtarget, Ytarget.reshape(-1, 1), axis=1)
        Xdata = np.concatenate((Xsource, np.delete(Tdata, -1, axis=1)), axis=0)
        Ldata = np.concatenate((Ysource, Tdata[:, -1]), axis=0)

        self.dbscan.fit(Xdata)
        labels = self.dbscan.labels_
        n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)

        cluster = []
        for i in range(len(labels)):
            cluster.append([])
        noise = []
        for i in range(Xdata.shape[0]):
            if labels[i] != -1:
                cluster[labels[i]].append(i)
            else:
                noise.append(i)

        flag = np.zeros(n_clusters_)
        for i in range(n_clusters_):
            for item in cluster[i]:
                if item >= Xsource.shape[0] and item < Xdata.shape[0]:
                    flag[i] = 1
                    break

        for i in range(n_clusters_):
            if flag[i] == 0:
                for item in cluster[i]:
                    noise.append(item)

        Xsource = np.delete(Xsource, noise, axis=0)
        Ysource = np.delete(Ysource, noise, axis=0)

        return Xsource, Ysource, Xtarget, Ytarget


class Bruakfilter(object):
    def __init__(self, n_neighbors=10):
        self.n_neighbors = n_neighbors

    def run(self, Xsource, Ysource, Xtarget, Ytarget):
        Xsource = np.log(Xsource + 1)
        Xtarget = np.log(Xtarget + 1)

        if self.n_neighbors > Xsource.shape[0]:
            return 0, 0, 0, 0

        knn = NearestNeighbors()
        knn.fit(Xsource)
        data = []
        ysel = []

        for item in Xtarget:
            tmp = knn.kneighbors(item.reshape(1, -1), self.n_neighbors, return_distance=False)
            tmp = tmp[0]
            for i in tmp:
                if list(Xsource[i]) not in data:
                    data.append(list(Xsource[i]))
                    ysel.append(Ysource[i])
        Xsource = np.asanyarray(data)
        Ysource = np.asanyarray(ysel)

        return Xsource, Ysource, Xtarget, Ytarget


class Peterfilter(object):
    def __init__(self, eachCluster=10):
        self.eachCluster = eachCluster

    def run(self, Xsource, Ysource, Xtarget, Ytarget):
        self.Xsource = Xsource
        self.Xtarget = Xtarget
        self.Ysource = Ysource
        self.Ytarget = Ytarget
        data = np.concatenate((self.Xsource, self.Xtarget), axis=0)
        if self.eachCluster == 0:
            return 0,0,0,0
        n_cluster = int(self.Xsource.shape[0] / self.eachCluster)
        if n_cluster == 0:
            return 0, 0, 0, 0
        kmeans = KMeans(n_clusters=n_cluster)
        kmeans.fit(data)
        labels = kmeans.labels_

        # remove the clusters where have no test instance
        cluster = dict()
        for i in range(n_cluster):
            cluster[i] = []

        for i in range(len(labels)):
            cluster[labels[i]].append(i)

        chosenCluster = []
        for i in range(self.Xsource.shape[0], data.shape[0]):
            for j in range(n_cluster):
                if i in cluster[j] and (j not in chosenCluster):
                    chosenCluster.append(j)

        # choose train instance in each cluster
        out = []
        for i in range(len(chosenCluster)):
            test = []
            indexTest = []
            train = []
            indexTrain = []
            for item in cluster[chosenCluster[i]]:
                if item >= self.Xsource.shape[0] and item < data.shape[0]:
                    test.append(list(data[item]))
                    indexTest.append(item)
                else:
                    train.append(list(self.Xsource[item]))
                    indexTrain.append(item)

            if len(train) == 0:
                break
            Testfans = np.zeros((len(indexTest), len(indexTrain)))

            neigh = NearestNeighbors(n_neighbors=1)
            neigh.fit(np.asarray(test))
            for item in train:
                index = neigh.kneighbors(np.asarray(item).reshape(1, -1), return_distance=False)
                Testfans[index[0][0], train.index(item)] += 1

            for i in range(len(test)):
                index = np.argmax(Testfans[i])
                if indexTrain[index] not in out:
                    out.append(indexTrain[index])

        tmp = np.zeros((len(out), self.Xsource.shape[1]))
        tmpl = np.zeros(len(out))
        for i in range(len(out)):
            tmp[i] = self.Xsource[out[i]]
            tmpl[i] = self.Ysource[out[i]]

        return tmp, tmpl, Xtarget, Ytarget


""" pick proper  source dataset """


class DataSelection(object):
    def __init__(self, topN=5, FSS=0.2):
        self.topN = topN
        self.FSS = FSS

    def _sample(self, Xsource, Xtarget):
        K = min(500, Xsource.shape[0], Xtarget.shape[0])
        Ltrain = np.ones(K)
        Ltest = np.ones(K) * -1

        Train = random.sample(range(Xsource.shape[0]), Xsource.shape[0] - K)
        Test = random.sample(range(Xtarget.shape[0]), Xtarget.shape[0] - K)
        Train = np.delete(Xsource, Train, axis=0)
        Test = np.delete(Xtarget, Test, axis=0)

        data = np.concatenate((Train, Test), axis=0)
        label = np.concatenate((Ltrain, Ltest), axis=0)

        return data, label

    def _calDistance(self, Xsource, Xtarget):
        acc = np.zeros(10)
        for i in range(10):
            x, y = self._sample(Xsource, Xtarget)
            lr = LogisticRegression()
            acc[i] = np.mean(cross_val_score(lr, x, y, scoring='accuracy', cv=5))
        return 2 * abs((np.mean(acc) - 0.5))

    def run(self, Xsource, Ysource, Xtarget, Ytarget, loc):
        self.topN = min(self.topN, len(loc))
        dist = dict()

        for i in range(len(loc)):
            if i < len(loc) - 1:
                train = Xsource[loc[i]:loc[i + 1]]
                dist[i] = self._calDistance(train, Xtarget)
            else:
                train = Xsource[loc[i]:]
                dist[i] = self._calDistance(train, Xtarget)

        dist = sorted(dist.items(), key=lambda d: d[1])
        i = dist[0][0]
        if i != len(loc) - 1:
            x = Xsource[loc[i]:loc[i + 1] ]
            y = Ysource[loc[i]:loc[i + 1] ]
        else:
            x = Xsource[loc[i]:]
            y = Ysource[loc[i]:]

        for i in range(1, self.topN):
            index = dist[i][0]
            if index < len(loc) - 1:
                tmp = Xsource[loc[index]:loc[index + 1] ]
                temp = Ysource[loc[index]:loc[index + 1] ]
            else:
                tmp = Xsource[loc[index]:]
                temp = Ysource[loc[index]:]
            x = np.concatenate((x, tmp), axis=0)
            y = np.concatenate((y, temp), axis=0)

        fx, fy = self._sample(x, Xtarget)
        lr = LogisticRegression()
        lr.fit(fx, fy)
        coef = dict()
        for i in range(Xsource.shape[1]):
            coef[i] = lr.coef_[0][i]
        coef = sorted(coef.items(), key=lambda d: d[1], reverse=True)

        dump = []
        for i in range(int(Xsource.shape[1] * self.FSS)):
            dump.append(coef[i][0])

        x = np.delete(x, dump, axis=1)
        Xtarget = np.delete(Xtarget, dump, axis=1)

        return x, y, Xtarget, Ytarget


class DSBF(object):
    def __init__(self, topK=1, neighbors=10):
        self.topK = int(topK)
        self.neighbors = neighbors

    def featureReduction(self, source, target):
        d = pdist(target.T, metric='euclidean')
        D = squareform(d)
        dist = D.copy()
        D = np.zeros(D.shape)

        for i in range(target.shape[1]):
            index = np.argsort(dist[i])
            count = 0
            for j in range(len(index)):
                if count < self.topK and index[j] != i:
                    D[i][index[j]] = 1
                    count += 1

        V = np.sum(D, axis=0)
        V[V < 1e-6] = 0
        index = np.where(V != 0)
        target = np.delete(target, index, axis=1)
        source = np.delete(source, index, axis=1)

        return source, target

    def outlierRemove(self, target, ys):
        d = pdist(target, metric='euclidean')
        D = squareform(d)
        dist = D.copy()
        D = np.zeros(D.shape)
        for i in range(target.shape[0]):
            index = np.argsort(dist[i])
            count = 0
            for j in range(len(index)):
                if count < self.topK and index[j] != i:
                    D[i][index[j]] = 1
                    count += 1
        V = np.sum(D, axis=0)
        V[V < 1e-6] = 0
        index = np.where(V == 0)
        target = np.delete(target, index, axis=0)
        ys = np.delete(ys, index, axis=0)
        return target, ys

    def Bruakfilter(self, Xsource, Ysource, Xtarget, Ytarget):
        Xsource = np.log(Xsource + 1)
        Xtarget = np.log(Xtarget + 1)

        if self.neighbors > Xsource.shape[0]:
            return 0, 0, 0, 0

        knn = NearestNeighbors()
        knn.fit(Xsource)
        data = []
        ysel = []

        for item in Xtarget:
            tmp = knn.kneighbors(item.reshape(1, -1), self.neighbors, return_distance=False)
            tmp = tmp[0]
            for i in tmp:
                if list(Xsource[i]) not in data:
                    data.append(list(Xsource[i]))
                    ysel.append(Ysource[i])
        Xsource = np.asanyarray(data)
        Ysource = np.asanyarray(ysel)

        return Xsource, Ysource, Xtarget, Ytarget

    def run(self, Xsource, Ysource, Xtarget, Ytarget):
        Xsource, Xtarget = self.featureReduction(Xsource, Xtarget)
        if Xsource.shape[1] == 0:
            return 0, 0, 0, 0
        Xsource, Ysource = self.outlierRemove(Xsource, Ysource)
        if len(Xsource) == 0:
            return 0, 0, 0, 0
        Xtarget, Ytarget = self.outlierRemove(Xtarget, Ytarget)
        if len(Xtarget) == 0:
            return 0, 0, 0, 0
        Xsource, Ysource, Xtarget, Ytarget = self.Bruakfilter(Xsource, Ysource, Xtarget, Ytarget)
        if len(Xsource) == 0 or len(Xtarget) == 0:
            return 0, 0, 0, 0
        Xsource, Ysource = self.outlierRemove(Xsource, Ysource)
        if len(Xsource) == 0 or len(Xtarget) == 0:
            return 0, 0, 0, 0

        return Xsource, Ysource, Xtarget, Ytarget


class Universal(object):
    def __init__(self, pvalue=0.05, QuantifyType='cliff'):
        self.p = pvalue
        self.type = QuantifyType

    def _compareMetricDistribution(self, x1, x2):
        s, p = mannwhitneyu(x1, x2)
        if p < self.p:
            sig_diff = 1
        else:
            sig_diff = 0
        return sig_diff

    def _quantifyDifference(self, x1, x2):
        if self.type == 'cliff':
            d, res = cliff.cliffsDelta(x1, x2)
        else:
            res = cliff.cohen(x1, x2)
        return res

    def cluster(self, No_metric, numGroup, group):
        indexOfCluster = 0
        clusterOfGroup = np.zeros(numGroup)

        for i in range(0, numGroup-1):
            indexNewCluster = indexOfCluster + 1
            for j in range(i+1, numGroup):
                if self._compareMetricDistribution(group[i][:, No_metric], group[j][:, No_metric]) == 1:
                    if self._quantifyDifference(group[i][:, No_metric], group[j][:, No_metric]) == 'large':
                        clusterOfGroup[j] = indexNewCluster
                        indexOfCluster = indexNewCluster

        return clusterOfGroup

    def rankTransform(self, xsource, xtarget, loc):
        group = []
        for i in range(len(loc)):
            if i < len(loc) - 1:
                train = xsource[loc[i]:loc[i + 1]]
            else:
                train = xsource[loc[i]:]
            group.append(train)
        group.append(xtarget)
        resGroup = group.copy()

        for i in range(xsource.shape[1]):
            clusterIndex = self.cluster(i, len(loc) + 1, group)
            cluster = np.unique(clusterIndex)
            for item in cluster:
                tmp = np.asarray(np.where(clusterIndex == item))[0]
                tmp_data = np.asarray([])
                for ncs in tmp:
                    tmp_data = np.concatenate((tmp_data, group[int(ncs)][:, i]))

                percentiles = np.percentile(sorted(tmp_data), [10, 20, 30, 40, 50, 60, 70, 80, 90])
                for ncs in tmp:
                    ncs = int(ncs)
                    t = resGroup[ncs][:, i]
                    for it in range(len(t)):
                        if t[it] <= percentiles[0]:
                            resGroup[ncs][:, i][it] = 1
                        elif t[it] <= percentiles[1]:
                            resGroup[ncs][:, i][it] = 2
                        elif t[it] <= percentiles[2]:
                            resGroup[ncs][:, i][it] = 3
                        elif t[it] <= percentiles[3]:
                            resGroup[ncs][:, i][it] = 4
                        elif t[it] <= percentiles[4]:
                            resGroup[ncs][:, i][it] = 5
                        elif t[it] <= percentiles[5]:
                            resGroup[ncs][:, i][it] = 6
                        elif t[it] <= percentiles[6]:
                            resGroup[ncs][:, i][it] = 7
                        elif t[it] <= percentiles[7]:
                            resGroup[ncs][:, i][it] = 8
                        elif t[it] <= percentiles[8]:
                            resGroup[ncs][:, i][it] = 9
                        else:
                            resGroup[ncs][:, i][it] = 10


        return resGroup

    def run(self, Xsource, Ysource, Xtarget, Ytarget, loc):
        res = self.rankTransform(Xsource, Xtarget, loc)
        source = np.asarray(res[0])
        for i in range(1, len(loc)):
            source = np.concatenate((source, res[i]), axis=0)
        target = res[-1]

        return source, Ysource, target, Ytarget


