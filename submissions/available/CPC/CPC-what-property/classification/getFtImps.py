

def getFeatureImps(InfluImportances, allFeatureNames ,featureDimension, influOfEachFeature):
    cur = 0
    for i in range(len(allFeatureNames)):
        oneFeatureInflu= 0
        for j in range(cur , cur+featureDimension[allFeatureNames[i]]):
            oneFeatureInflu+=InfluImportances[j]
        influOfEachFeature[allFeatureNames[i]]=oneFeatureInflu
        cur = cur + featureDimension[allFeatureNames[i]]


