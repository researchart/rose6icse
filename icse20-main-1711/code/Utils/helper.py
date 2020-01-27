from Utils.Hyperopt_doer import *
from Utils.File import *
from numpy import asarray, compress, sum
from scipy.stats import stats, find_repeats, distributions
from math import sqrt
from numpy.ma import not_equal
import re
import warnings
import numpy as np


def wilcoxon(x, y=None, zero_method="wilcox", correction=False):
    """
    Calculate the Wilcoxon signed-rank test.
    The Wilcoxon signed-rank test tests the null hypothesis that two
    related paired samples come from the same distribution. In particular,
    it tests whether the distribution of the differences x - y is symmetric
    about zero. It is a non-parametric version of the paired T-test.
    Parameters
    ----------
    x : array_like
        The first set of measurements.
    y : array_like, optional
        The second set of measurements.  If `y` is not given, then the `x`
        array is considered to be the differences between the two sets of
        measurements.
    zero_method : string, {"pratt", "wilcox", "zsplit"}, optional
        "pratt":
            Pratt treatment: includes zero-differences in the ranking process
            (more conservative)
        "wilcox":
            Wilcox treatment: discards all zero-differences
        "zsplit":
            Zero rank split: just like Pratt, but spliting the zero rank
            between positive and negative ones
    correction : bool, optional
        If True, apply continuity correction by adjusting the Wilcoxon rank
        statistic by 0.5 towards the mean value when computing the
        z-statistic.  Default is False.
    Returns
    -------
    T : float
        The sum of the ranks of the differences above or below zero, whichever
        is smaller.
    p-value : float
        The two-sided p-value for the test.
    Notes
    -----
    Because the normal approximation is used for the calculations, the
    samples used should be large.  A typical rule is to require that
    n > 20.
    References
    ----------
    .. [1] http://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test
    """

    if not zero_method in ["wilcox", "pratt", "zsplit"]:
        raise ValueError("Zero method should be either 'wilcox' \
                          or 'pratt' or 'zsplit'")

    if y is None:
        d = x
    else:
        x, y = map(asarray, (x, y))
        if len(x) != len(y):
            raise ValueError('Unequal N in wilcoxon.  Aborting.')
        d = x - y

    if zero_method == "wilcox":
        d = compress(not_equal(d, 0), d, axis=-1)  # Keep all non-zero differences

    count = len(d)
    if (count < 10):
        warnings.warn("Warning: sample size too small for normal approximation.")
    r = stats.rankdata(abs(d))
    r_plus = sum((d > 0) * r, axis=0)
    r_minus = sum((d < 0) * r, axis=0)

    if zero_method == "zsplit":
        r_zero = sum((d == 0) * r, axis=0)
        r_plus += r_zero / 2.
        r_minus += r_zero / 2.

    if r_plus < r_minus:
        T = r_plus
        tmp = r_plus
    else:
        T = r_minus
        tmp = -r_plus
    T = min(r_plus, r_minus)
    mn = count * (count + 1.) * 0.25
    se = count * (count + 1.) * (2. * count + 1.)

    if zero_method == "pratt":
        r = r[d != 0]

    replist, repnum = find_repeats(r)
    if repnum.size != 0:
        # Correction for repeated elements.
        se -= 0.5 * (repnum * (repnum * repnum - 1)).sum()

    se = sqrt(se / 24)
    correction = 0.5 * int(bool(correction)) * np.sign(T - mn)
    z = (T - mn - correction) / se
    prob = 2. * distributions.norm.sf(abs(z))
    return tmp, prob


def is_number(num):
    pattern = re.compile(r'^[-+]?[-0-9]\d*\.\d*|[-+]?\.?[0-9]\d*$')
    result = pattern.match(num)
    if result:
        return True
    else:
        return False


def GetData(filename, showType=False):
    if 'JURECZKO' in filename:
        with open(filename, 'r') as f:
            data = f.readlines()
        x = []
        y = []
        empty = []

        # get the types of metrics from first line
        type = data[0].strip().split(';')
        type.pop()
        type.pop(0)

        # get the detail data of metrics
        for line in data[1:]:
            tmp = []

            odom = line.strip().split(';')
            # delete the project information
            for i in range(3):
                odom.pop(0)

            for i in range(len(odom)):
                if is_number(odom[i]):
                    tmp.append(float(odom[i]))
                else:
                    if i not in empty:
                        empty.append(i)
                    tmp.append(0)

            if tmp.pop() > 0:
                y.append(1)
            else:
                y.append(-1)
            x.append(tmp)

        x = np.delete(np.asarray(x), empty, axis=1)
        empty = sorted(empty)
        for i in range(len(empty)):
            type.pop(empty[len(empty) - i - 1])

        if showType:
            return x, np.asarray(y), type
        else:
            return x, np.asarray(y)

    else:
        with open(filename, 'r') as f:
            data = f.readlines()  # txt中所有字符串读入data
            x = []
            y = []
            type = []

            for line in data:
                if '###' in line:
                    odom = line.strip().split(' ')
                    odom.remove('###')
                    type = odom
                else:
                    tmp = []
                    odom = line.strip().split(',')  # 将单个数据分隔开存好
                    if not is_number(odom[0]):
                        continue
                    for item in odom:
                        if is_number(item):
                            tmp.append(float(item))
                        elif (item == 'true') or (item == 'TRUE') or (item == 'Y') or (item == 'buggy'):
                            y.append(1)
                        else:
                            y.append(-1)
                    x.append(tmp)

        if showType:
            return np.asanyarray(x), np.asarray(y), type
        else:
            return np.asanyarray(x), np.asarray(y)


def SfindCommonMetric(fsource, ftarget, showDiff=False, showType=False):
    sx, sy, Stype = GetData(fsource, showType=True)
    tx, ty, Ttype = GetData(ftarget, showType=True)

    common = []

    ss = sx.shape
    tt = tx.shape
    for i in range(ss[1]):
        if Stype[i] in Ttype:
            common.append(Stype[i])

    if len(common) > 0:
        fsx = np.zeros((ss[0], len(common)))
        ftx = np.zeros((tt[0], len(common)))
        for i in range(len(common)):
            index = Stype.index(common[i])
            fsx[:, i] = sx[:, index]

            index = Ttype.index(common[i])
            ftx[:, i] = tx[:, index]

        DiffSx = np.zeros((ss[0], ss[1] - len(common)))
        DiffTx = np.zeros((tt[0], tt[1] - len(common)))

        i = 0
        for j in range(ss[1]):
            if Stype[j] not in common:
                DiffSx[:, i] = sx[:, j]
                i = i + 1
        i = 0
        for j in range(tt[1]):
            if Ttype[j] not in common:
                DiffTx[:, i] = tx[:, j]
                i = i + 1
        if showDiff and showType:
            return fsx, sy, ftx, ty, DiffSx, DiffTx, common
        elif showDiff and (not showType):
            return fsx, sy, ftx, ty, DiffSx, DiffTx
        elif (not showDiff) and showType:
            return fsx, sy, ftx, ty, common
        else:
            return fsx, sy, ftx, ty
    else:
        return 0, 0, 0, 0


def MfindCommonMetric(list, ftarget, split=False):
    tx, ty, Ttype = GetData(ftarget, showType=True)
    tt = tx.shape
    common = []

    flist = list.copy()
    ### find the common metric
    first = 1
    dump = []

    for item in flist:
        x, y, Stype = GetData(item, showType=True)
        ss = x.shape

        if first == 1:
            for i in range(ss[1]):
                if Stype[i] in Ttype:
                    common.append(Stype[i])
            first = 0
        else:
            for i in range(len(common)):
                if common[i] not in Stype and i not in dump:
                    dump.append(i)
    dump = sorted(dump, reverse=True)
    for i in range(len(dump)):
        common.pop(dump[i])

    ### read the data and concatendate

    if len(common) == 0:
        return 0, 0, 0, 0, []
    else:
        ftx = np.zeros((tt[0], len(common)))
        for i in range(len(common)):
            index = Ttype.index(common[i])
            ftx[:, i] = tx[:, index]

        sx, sy, Stype = GetData(flist.pop(), showType=True)

        fsx = np.zeros((len(sy), len(common)))
        for i in range(len(common)):
            index = Stype.index(common[i])
            fsx[:, i] = sx[:, index]

        loc = []
        base = 0

        for item in flist:
            x, y, Type = GetData(item, showType=True)
            loc.append(base)
            base += len(y)
            fx = np.zeros((len(y), len(common)))
            for i in range(len(common)):
                index = Type.index(common[i])
                fx[:, i] = x[:, index]
            fsx = np.concatenate((fsx, fx), axis=0)
            sy = np.concatenate((sy, y), axis=0)

        if split:
            return fsx, sy, ftx, ty, loc
        else:
            return fsx, sy, ftx, ty, []

def GetDataList(flist):
    a = flist.pop()
    xs, ys, xt, yt, loc = MfindCommonMetric(flist, a)
    x = np.concatenate((xs, xt), axis=0)
    y = np.concatenate((ys, yt), axis=0)
    return x, y


def collectData(fname):
    count = len(open(fname, 'r').readlines())
    with open(fname, 'r') as f:
        tmp = list(map(eval, f.readline()[1:-2].split()))
        res = np.zeros((count - 1, len(tmp)))
        i = 0
        print(fname, len(tmp))
        for line in f:
            line = line[1:-2]
            res[i] = np.asarray(line.split())[:len(tmp)]
            i += 1
            print(np.asarray(line.split()))
    return np.concatenate(([tmp], res))

def resCollect():
    for mode in {'all', 'clf', 'seq', 'adpt'}:
        resDir = 'res' + mode.upper()
        for root, dirs, files in os.walk(resDir):
            for name in files:
                fname = os.path.join(root, name)
                result = collectData(fname)
                np.savetxt(fname, result, fmt='%.7f')


def normal(xs, xt):
    ss = xs.shape
    tt = xt.shape

    # normalization for source data
    res = np.zeros((ss[0], ss[1]))
    for i in range(ss[1]):
        tmp = xs[:, i]
        minm = np.min(tmp)
        maxm = np.max(tmp)
        res[:, i] = (tmp - minm) / (maxm - minm)
    xs = res

    # normalization for target data
    res = np.zeros((tt[0], tt[1]))
    for i in range(tt[1]):
        tmp = xt[:, i]
        minm = np.min(tmp)
        maxm = np.max(tmp)
        res[:, i] = (tmp - minm) / (maxm - minm)
    xt = res

    return xs, xt


def RunExperiment(fsource, ftarget, adaptation, classifier, mode='adpt', repeat=10, fe=1000):
    if adaptation == 'DS' or adaptation == 'FS':
        Xsource, Lsource, Xtarget, Ltarget, loc = MfindCommonMetric(fsource, ftarget, split=True)
    else:
        Xsource, Lsource, Xtarget, Ltarget, loc = MfindCommonMetric(fsource, ftarget)
    target = ftarget.split('/')[-1][:-5]
    fres = create_dir('res' + mode.upper() + '/' + target)

    if adaptation == 'DBSCANfilter':
        Xsource, Xtarget = normal(Xsource, Xtarget)
        Xsource[Xsource!=Xsource] = 0
        Xtarget[Xtarget!=Xtarget] = 0


    num = repeat
    res = np.zeros((num, 2))
    for i in range(num):
        if mode == 'adpt':
            res[i] = optParamAdpt(Xsource, Lsource, Xtarget, Ltarget, loc, classifier, adaptation, fe).run()
        elif mode == 'all':
            res[i] = optParamAll(Xsource, Lsource, Xtarget, Ltarget, loc, classifier, adaptation, fe).run()
        elif mode == 'clf':
            res[i] = optParamCLF(Xsource, Lsource, Xtarget, Ltarget, loc, classifier, adaptation, fe).run()
        elif mode == 'seq':
            res[i] = optParamSEQ(Xsource, Lsource, Xtarget, Ltarget, loc, classifier, adaptation, fe).run()
        # print the result into file
        with open(fres + adaptation + '-' + classifier + '.txt', 'at') as f:
            print(res[i], file=f)



def HeteRunEXperiment(fsource, ftarget, classifier, mode='adpt', repeat=10):
    Xsource, Lsource = GetDataList(fsource)
    Xtarget, Ltarget = GetData(ftarget)
    source = fsource[0].split('/')[1]
    target = ftarget.split('/')[-1][:-5]
    fres = create_dir('res' + mode.upper() + '/hete-'+ target)

    num = repeat
    res = np.zeros((num, 2))
    for i in range(num):
        if mode == 'adpt':
            res[i] = optParamAdpt(Xsource, Lsource, Xtarget, Ltarget, [], classifier, 'HDP').run()
        elif mode == 'all':
            res[i] = optParamAll(Xsource, Lsource, Xtarget, Ltarget, [], classifier, 'HDP').run()
        elif mode == 'clf':
            res[i] = optParamCLF(Xsource, Lsource, Xtarget, Ltarget, [], classifier, 'HDP').run()
        elif mode == 'seq':
            res[i] = optParamSEQ(Xsource, Lsource, Xtarget, Ltarget, [], classifier, 'HDP').run()

        # print the result into file
        with open(fres + source + '-' + classifier + '.txt', 'at') as f:
            print(res[i], file=f)
