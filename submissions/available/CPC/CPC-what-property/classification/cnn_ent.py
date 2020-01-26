import pandas as pd
import gensim
from pandas import DataFrame
import numpy as np

from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import LabelBinarizer
from sklearn.preprocessing import MultiLabelBinarizer
from gensim.models import word2vec
from gensim.models import KeyedVectors

import keras

# Load input xlsx file.
data = pd.read_excel("training_set.xlsx", sheet_name="Sheet0")

# Load Word2Vec model
word_model = gensim.models.KeyedVectors.load_word2vec_format(
    "./corpus/corpusB_vec.txt")
pretrained_weights = word_model.wv.syn0
vocab_size, embedding_size = pretrained_weights.shape
print('Result embedding shape:', pretrained_weights.shape)

# Input X
comments = []
max_sent_len = 0
for row in enumerate(data['cleanB'].values):
    sent = row[1]
    # print(sent)
    if pd.isnull(sent):
        continue
    comments.append(sent)
    if len(sent) > max_sent_len:
        max_sent_len = len(sent)

X = np.zeros([len(comments), max_sent_len], dtype=np.int32)
for i, sent in enumerate(comments):
    #print(sent);
    if len(sent.split()) <= 3: continue
    for j, word in enumerate(sent.split()):
        if not word_model.__contains__(word):
            X[i, j] = word_model.wv.vocab["method"].index
            print("Unmatch: ", word)
        else:
            X[i, j] = word_model.wv.vocab[word].index

print(X)

# Labels Y
labels = ["class", "method", "statement", "field", "paramater"]

Y = np.zeros([len(comments), len(labels)], dtype=np.int32)

for j, l in enumerate(labels):
    for i, item in enumerate(data['subject1'].astype(str)):
        if item == l:
            Y[i, j] = 1
    for i, item in enumerate(data['subject2'].astype(str)):
        if item == l:
            Y[i, j] = 1

pre = []
rec = []
f1 = []
ham = []

fout = open("result_cnn_entity.txt", "w")

for iter in range(5):
    # Split data set into training data and test data.
    from sklearn.model_selection import train_test_split

    X_train, X_test, Y_train, Y_test = train_test_split(X,
                                                        Y,
                                                        test_size=0.2,
                                                        random_state=35)

    from keras.callbacks import LambdaCallback
    from keras.layers.recurrent import LSTM
    from keras.layers.embeddings import Embedding
    from keras.layers import Activation, Dense, Flatten, Dropout, Conv1D, MaxPooling1D
    from keras.models import Sequential
    from keras.utils.data_utils import get_file

    from sklearn.metrics import confusion_matrix, f1_score, precision_score, recall_score

    # Build the model
    model = Sequential()

    model.add(
        Embedding(input_dim=vocab_size,
                  output_dim=embedding_size,
                  weights=[pretrained_weights],
                  input_shape=[max_sent_len]))

    model.add(Dropout(0.5))
    model.add(Conv1D(128, 5, activation='relu'))
    model.add(MaxPooling1D(pool_size=5))
    model.add(Conv1D(128, 5, activation='relu'))
    model.add(MaxPooling1D(pool_size=5))
    model.add(Flatten())
    model.add(Dense(units=len(labels), activation='sigmoid'))

    model.compile(optimizer='adam',
                  loss='binary_crossentropy',
                  metrics=['accuracy'])
    # Train the model

    #from sklearn.model_selection import StratifiedShuffleSplit
    #folds = StratifiedShuffleSplit(n_splits = 5, test_size = 0.2)
    #for train_index, test_index in folds.split(X_train, Y_train):
    #    xtrain, xtest = X_train[train_index], X_train[test_index]
    #    ytrain, ytest = Y_train[train_index], Y_train[test_index]
    #    model.fit(xtrain, )
    model.fit(X_train, Y_train, batch_size=32, epochs=15, shuffle=True)

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
