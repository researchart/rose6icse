from Algorithms.domainAdaptation import *
from Algorithms.HISNN import *
from Algorithms.DTB import *
from collections import defaultdict
from sklearn.preprocessing import normalize
import func_timeout
from func_timeout import func_set_timeout


class cpdp(object):
    def __init__(self, kernel_type='linear', dim=5, lamb=1, gamma=1,                                       # TCA
                 eps=1.0, min_samples=10,                                                                  # DBSCAN
                 n_neighbors=5,                                                                            # Bruak
                 eachCluster=10,                                                                           # Peter
                 DStopn=5, DSfss=0.2,                                                                      # DS
                 DTBneighbors=10, DTBT=20,                                                                 # DTB
                 DSBFtopk=1, DSBFneighbors=10,                                                             # DSBF
                 pvalue=0.05, QuantifyType='cliff',                                                        # Universal

                 n_estimators=10, criterion='gini', max_features='auto', RFmin_samples_split=2,            # RF
                 Boostnestimator=50, BoostLearnrate=1,                                                     # Boost
                 NNactive='relu', NNalpha=0.0001, NNmaxiter=50,                                            # NN
                 CARTsplitter='best',                                                                      # CART
                 Ridgealpha=1, Ridgenormalize=False,                                                       # Ridge
                 KNNneighbors=5,                                                                           # KNN
                 NBType='gaussian',                                                                        # NB

                 clf='SVM', adpt='TCA'                                                                     # TL and Classifier
                 ):
        # TL and Classifier
        self.clfType = clf
        self.adpt = adpt

        # Universal
        self.pvalue = pvalue
        self.QuntifyType = QuantifyType
        # DTB
        self.DTBneighbors=DTBneighbors
        self.DTBT=DTBT
        # DSBF
        self.DSBFtopk = DSBFtopk
        self.DSBFneighbor=DSBFneighbors
        # TCA
        self.kernelType = kernel_type
        self.dim = dim
        self.lamb = lamb
        self.gamma = gamma
        # DBSCAN
        self.eps = eps
        self.min_samples = min_samples
        # peter
        self.eachCluster = eachCluster
        # Bruak
        self.Barukneighbors = n_neighbors
        # DS
        self.DStopn = DStopn
        self.DSfss = DSfss

        # SVM
        self.SVCkernel = 'poly'
        self.coef0 = 0
        self.gamma = 1
        self.degree = 3
        self.C = 1
        # KNN
        self.KNNneighbors = KNNneighbors
        # RF
        self.n_estimators = n_estimators
        self.criterion = criterion
        self.max_features = max_features
        self.RFmin_samples = RFmin_samples_split
        # Boost
        self.Boostne = Boostnestimator
        self.BoostLearnrate = BoostLearnrate
        # NN
        self.NNactive = NNactive
        self.NNalpha = NNalpha
        self.NNmaxiter = NNmaxiter
        # NB
        self.NBType = NBType
        # CART
        self.CARTsplitter = CARTsplitter
        # Ridge
        self.Ridgealpha = Ridgealpha
        self.Ridgenormalize = Ridgenormalize

        self.default = {'Universal': {
                'pvalue': 0.05,
                'QuantifyType': 0
            },
                        'DTB': {
                'DTBneighbors': 10,
                'DTBT': 20
            },
                        'DSBF': {
                'DSBFtopk': 1,
                'DSBFneighbors': 10
            },
                        'TCA': {
                'kernel_type': 1,
                'dim': 5,
                'lamb': 1,
                'gamma': 1
            },
                        'DBSCANfilter': {
                'eps': 1,
                'min_samples': 10
            },
                        'Peterfilter': {
                'eachCluster': 10
            },
                        'Bruakfilter': {
                'n_neighbors': 10
            },
                        'DS': {
                'DStopn': 5,
                'DSfss': 0.2
            },
            'SVM': {
                'kernel': 1,
                'coef0': 0,
                'gamma': 1,
                'degree': 3,
                'c': 1
            },
            'KNN': {
                'KNNneighbors': 1
            },
            'RF': {
                'n_estimators': 10,
                'criterion': 0,
                'max_features': 0,
                'RFmin_samples_split': 2
            },
            'Boost': {
                'Boostnestimator': 50,
                'BoostLearnrate': 1
            },
            'NN': {
                'NNactive': 3,
                'NNalpha': 0.0001,
                'NNmaxiter': 50
            },
            'NB': {
                'NBType': 'gaussian'
            },
            'CART': {
                'criterion': 0,
                'max_features': 0,
                'CARTsplitter': 0,
                'RFmin_samples_split': 2
            },
            'Ridge': {
                'Ridgealpha': 1,
                'Ridgenormalize': False
            }
        }

    def _get_param_names(cls):
        """Get parameter names for the estimator"""
        # fetch the constructor or the original constructor before
        # deprecation wrapping if any
        init = getattr(cls.__init__, 'deprecated_original', cls.__init__)
        if init is object.__init__:
            # No explicit constructor to introspect
            return []

        # introspect the constructor arguments to find the model parameters
        # to represent
        init_signature = signature(init)
        # Consider the constructor parameters excluding 'self'
        parameters = [p for p in init_signature.parameters.values()
                      if p.name != 'self' and p.kind != p.VAR_KEYWORD]
        for p in parameters:
            if p.kind == p.VAR_POSITIONAL:
                raise RuntimeError("scikit-learn estimators should always "
                                   "specify their parameters in the signature"
                                   " of their __init__ (no varargs)."
                                   " %s with constructor %s doesn't "
                                   " follow this convention."
                                   % (cls, init_signature))
        # Extract and sort argument names excluding 'self'
        return sorted([p.name for p in parameters])

    def get_params(self, deep=True):
        """Get parameters for this estimator.
        Parameters
        ----------
        deep : boolean, optional
            If True, will return the parameters for this estimator and
            contained subobjects that are estimators.
        Returns
        -------
        params : mapping of string to any
            Parameter names mapped to their values.
        """
        out = dict()
        for key in self._get_param_names():
            value = getattr(self, key, None)
            if deep and hasattr(value, 'get_params'):
                deep_items = value.get_params().items()
                out.update((key + '__' + k, val) for k, val in deep_items)
            out[key] = value
        return out

    def set_params(self, **params):
        if not params:
            # Simple optimization to gain speed (inspect is slow)
            return self

        if 'C' in params:
            self.C = params['C']
            if params['SVCkernel']['kernel'] == 'linear':
                self.SVCkernel = 'linear'
            elif params['SVCkernel']['kernel'] == 'rbf':
                self.SVCkernel = 'rbf'
                self.gamma = params['SVCkernel']['rbfgamma']
            elif params['SVCkernel']['kernel'] == 'sigmoid':
                self.SVCkernel = 'sigmoid'
                self.gamma = params['SVCkernel']['siggamma']
                self.coef0 = params['SVCkernel']['sigcoef0']
            elif params['SVCkernel']['kernel'] == 'poly':
                self.SVCkernel = 'poly'
                self.gamma = params['SVCkernel']['polygamma']
                self.degree = params['SVCkernel']['degree']
                self.coef0 = params['SVCkernel']['polycoef0']
            params.pop('C')
            params.pop('SVCkernel')



        valid_params = self.get_params(deep=True)

        nested_params = defaultdict(dict)  # grouped by prefix
        for key, value in params.items():
            key, delim, sub_key = key.partition('__')
            if key not in valid_params:
                raise ValueError('Invalid parameter %s for estimator %s. '
                                 'Check the list of available parameters '
                                 'with `estimator.get_params().keys()`.' %
                                 (key, self))

            if delim:
                nested_params[key][sub_key] = value
            else:
                setattr(self, key, value)
                valid_params[key] = value

        for key, sub_params in nested_params.items():
            valid_params[key].set_params(**sub_params)

        return self

    def run(self, Xsource, Ysource, Xtarget, Ytarget, loc):
        # initial the DAtor and Classifier
        if self.clfType == 'RF':
            self.m = RandomForestClassifier(n_estimators=self.n_estimators, criterion=self.criterion,
                                            max_features=self.max_features, min_samples_split=self.RFmin_samples)

        if self.clfType == 'SVM':
            self.m = SVC(kernel=self.SVCkernel, C=1, degree=self.degree, coef0=self.coef0, gamma=self.gamma)
            Xsource = normalize(Xsource)
            Xtarget = normalize(Xtarget)


        if self.clfType == 'Boost':
            self.m = AdaBoostClassifier(n_estimators=self.Boostne, learning_rate=self.BoostLearnrate)

        if self.clfType == 'MLP':
            self.m = MLPClassifier(activation=self.NNactive, alpha=self.NNalpha, max_iter=self.NNmaxiter)

        if self.clfType == 'KNN':
            self.m = KNeighborsClassifier(n_neighbors=self.KNNneighbors)

        if self.clfType == 'NB':
            if self.NBType == 'gaussian':
                self.m = GaussianNB()
            elif self.NBType == 'multinomial':
                self.m = MultinomialNB()
            elif self.NBType == 'bernoulli':
                self.m = BernoulliNB()

        if self.clfType == 'CART':
            self.m = DecisionTreeClassifier(criterion=self.criterion, splitter=self.CARTsplitter,
                                            max_features=self.max_features, min_samples_split=self.RFmin_samples)

        if self.clfType == 'Ridge':
            self.m = RidgeClassifier(alpha=self.Ridgealpha, normalize=self.Ridgenormalize)

        if self.adpt == 'Universal':
            self.DA = Universal(pvalue=self.pvalue, QuantifyType=self.QuntifyType)


        if self.adpt == 'TCA':
            self.DA = TCA(kernel_type=self.kernelType, dim=self.dim, lamb=self.lamb, gamma=self.gamma)

        if self.adpt == 'DBSCANfilter':
            self.DA = DBSCANfilter(eps=self.eps, min_samples=self.min_samples)

        if self.adpt == 'Bruakfilter':
            self.DA = Bruakfilter(n_neighbors=self.Barukneighbors)

        if self.adpt == 'Peterfilter':
            self.DA = Peterfilter(eachCluster=self.eachCluster)
        if self.adpt == 'DSBF':
            self.DA = DSBF(topK=self.DSBFtopk, neighbors=self.DSBFneighbor)

        if self.adpt == 'DTB':
            model = DTB(Xsource, Ysource, Xtarget, Ytarget, n_neighbors=self.DTBneighbors, iter=self.DTBT,
                        clf=self.clfType,
                        n_estimators=self.n_estimators, criterion=self.criterion, max_features=self.max_features,
                        SVCkernel=self.SVCkernel, C=self.C, degree=self.degree, coef0=self.coef0, SVCgamma=self.gamma,
                        Boostnestimator=self.Boostne, BoostLearnrate=self.BoostLearnrate,
                        NBtype=self.NBType,
                        CARTsplitter=self.CARTsplitter, RFmin_samples_split=self.RFmin_samples,
                        Ridgealpha=self.Ridgealpha, Ridgenormalize=self.Ridgenormalize)
            model.fit()
            model.predict()
            return model.AUC

        if self.adpt == 'DS':
            self.DA = DataSelection(topN=self.DStopn, FSS=self.DSfss)


        s1 = time.time()

        if self.adpt == 'DS' or self.adpt == 'Universal':
            Xsource, Ysource, Xtarget, Ytarget = self.DA.run(Xsource, Ysource, Xtarget, Ytarget, loc)
        else:
            Xsource, Ysource, Xtarget, Ytarget = self.DA.run(Xsource, Ysource, Xtarget, Ytarget)

        s1 = time.time() - s1

        s2 = time.time()
        if np.asarray(Xsource).ndim <= 1 or len(np.unique(Ysource)) <= 1:
            return 0
        else:
            self.m.fit(Xsource, Ysource)
            if self.clfType == 'KNN':
                if Xsource.shape[0] < self.KNNneighbors:
                    return 0
            predict = self.m.predict(Xtarget)
            return roc_auc_score(Ytarget, predict)
