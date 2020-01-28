import numpy as np
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.naive_bayes import *
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import RidgeClassifier
from sklearn.metrics import roc_auc_score


# H 测试样本分类结果
# TrainS 原训练样本 np数组
# TrainA 辅助训练样本
# LabelS 原训练样本标签
# LabelA 辅助训练样本标签
# Test  测试样本
# N 迭代次数

class trAdaBoost(object):
    def __init__(self, trans_S,  trans_A, label_S, label_A, testX, N, initWeight, clf):
        self.trans_S = trans_S
        self.trans_A = trans_A
        self.label_S = label_S
        self.label_A = label_A
        self.N = N
        self.test = testX
        self.weight = initWeight
        self.m = clf
        self.error = 0

    def fit(self):
        trans_data = np.concatenate((self.trans_A, self.trans_S), axis=0)
        trans_label = np.concatenate((self.label_A, self.label_S), axis=0)

        row_A = self.trans_A.shape[0]
        row_S = self.trans_S.shape[0]
        row_T = self.test.shape[0]
        N = self.N

        test_data = np.concatenate((trans_data, self.test), axis=0)

        # 初始化权重
        weights_A = np.ones([row_A, 1]) / row_A
        weights_S = self.weight.reshape(-1, 1)
        weights = np.concatenate((weights_A, weights_S), axis=0)

        # 防止除数为零
        if N == 0 or (1 + np.sqrt(2 * np.log(row_A / N))) == 0:
            self.error = 1
            return
        bata = 1 / (1 + np.sqrt(2 * np.log(row_A / N)))

        # 存储每次迭代的标签和bata值？
        bata_T = np.zeros([1, N])
        result_label = np.ones([row_A + row_S + row_T, N])

        predict = np.zeros([row_T])

        # print('params initial finished.')
        trans_data = np.asarray(trans_data, order='C')
        trans_label = np.asarray(trans_label, order='C')
        test_data = np.asarray(test_data, order='C')

        for i in range(N):
            P = self.calculate_P(weights, trans_label)

            result_label[:, i] = self.train_classify(trans_data, trans_label,
                                                test_data, P)
            # print('result,', result_label[:, i], row_A, row_S, i, result_label.shape)

            error_rate = self.calculate_error_rate(self.label_S, result_label[row_A:row_A + row_S, i],
                                              weights[row_A:row_A + row_S, :])
            # print('Error rate:', error_rate)
            if error_rate > 0.5:
                error_rate = 0.5
            if error_rate == 0:
                N = i
                break  # 防止过拟合
                # error_rate = 0.001

            bata_T[0, i] = error_rate / (1 - error_rate)

            # 调整源域样本权重
            for j in range(row_S):
                weights[row_A + j] = weights[row_A + j] * np.power(bata_T[0, i],
                                                                   (-np.abs(result_label[row_A + j, i] - self.label_S[j])))

            # 调整辅域样本权重
            for j in range(row_A):
                weights[j] = weights[j] * np.power(bata, np.abs(result_label[j, i] - self.label_A[j]))
        # print bata_T
        for i in range(row_T):
            # 跳过训练数据的标签
            left = np.sum(
                result_label[row_A + row_S + i, int(np.ceil(N / 2)):N] * np.log(1 / bata_T[0, int(np.ceil(N / 2)):N]))
            right = 0.5 * np.sum(np.log(1 / bata_T[0, int(np.ceil(N / 2)):N]))

            if left >= right:
                predict[i] = 1
            else:
                predict[i] = 0
                # print left, right, predict[i]

        self.label_p = predict

    def predict(self):
        return self.label_p


    def calculate_P(self, weights, label):
        total = np.sum(weights)
        return np.asarray(weights / total, order='C')


    def train_classify(self, trans_data, trans_label, test_data, P):
        trans_data[trans_data!=trans_data] = 0
        trans_label[trans_label!=trans_label] = 0
        test_data[test_data!=test_data] = 0
        P[P!=P] = 0

        self.m.fit(trans_data, trans_label, sample_weight=P[:, 0])
        return self.m.predict(test_data)


    def calculate_error_rate(self, label_R, label_H, weight):
        total = np.sum(weight)

        # print(weight[:, 0] / total)
        # print(np.abs(label_R - label_H))
        return np.sum(weight[:, 0] / total * np.abs(label_R - label_H))
