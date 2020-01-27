from Utils.helper import *
from multiprocessing import Pool
import warnings


def ContinueEX(Xsource, Lsource, Xtarget, Ltarget, loc, target, adpt, clf, mode):
    resDir = 'res' + mode.upper() + '/' + target
    if not os.path.exists(resDir):
        print(target + ':' + adpt + '-' + clf + ' ' + 'Start!')
        RunExperiment(Xsource, Lsource, Xtarget, Ltarget, loc, target, adpt, clf, mode)
    else:
        resFile = resDir + '/' + adpt + '-' + clf + '.txt'
        if not os.path.exists(resFile):
            print(target + ':' + adpt + '-' + clf + ' ' + 'Start!')
            RunExperiment(Xsource, Lsource, Xtarget, Ltarget, loc, target, adpt, clf, mode)
        else:
            count = len(open(resFile, 'rU').readlines())
            if count < 10:
                print(target + ':' + adpt + '-' + clf + ' ' + 'Start!')
                RunExperiment(Xsource, Lsource, Xtarget, Ltarget, loc, target, adpt, clf, mode, repeat=int(10 - count))
            else:
                print(target + ':' + adpt + '-' + clf + ' ' + 'done')


if __name__ == '__main__':
    begin_num = 1
    end_num = 15

    warnings.filterwarnings('ignore')

    flist = []
    group = sorted(['AEEEM', 'ReLink', 'JURECZKO'])
    for i in range(len(group)):
        tmp = []
        fnameList('data/' + group[i], tmp)
        tmp = sorted(tmp)
        flist.append(tmp)

    DA = sorted([
        'Bruakfilter',
        'Peterfilter',
        'DBSCANfilter',
        'TCA',
        'Universal',
        'DS',
        'DSBF',
        'DTB',
    ])
    CLF = sorted([
        'RF', 'Boost', 'MLP', 'CART', 'SVM', 'NB', 'Ridge', 'KNN'
                  ])

    for c in range(begin_num, end_num + 1):
        if c in range(6):
            tmp = flist[0].copy()
            target = tmp.pop(c - 1)
        if c in range(6, 18):
            tmp = flist[1].copy()
            target = tmp.pop(c - 6)
        if c in range(18, 21):
            tmp = flist[2].copy()
            target = tmp.pop(c - 18)

        Xsource, Lsource, Xtarget, Ltarget, loc = MfindCommonMetric(tmp, target, split=True)
        targetName = target.split('/')[-1].split('.')[0]

        for clf in range(len(CLF)):
            for adpt in range(len(DA)):
                if CLF[clf] in ['KNN', 'MLP'] and DA[adpt] in ['DTB']:
                    continue
                ContinueEX(Xsource, Lsource, Xtarget, Ltarget, loc, targetName, DA[adpt], CLF[clf], 'all')


    print('done!')
