import os








##===================================crashlytics.setUserEmail / setUserIdentifier /setUserName ================= 5 6 7
def crashlytics(app, testPath):
    APIfileName = "Crashlytics.smali"
    APIname_1 = ".method public static setUserEmail(Ljava/lang/String;)V"
    APIname_2 = ".method public static setUserIdentifier(Ljava/lang/String;)V"
    APIname_3 = ".method public static setUserName(Ljava/lang/String;)V"

    locals_org = "locals"
    locals_new_1 = "    .locals 3"
    locals_new_2 = "    .locals 3"
    locals_new_3 = "    .locals 3"

    targetStatement_1 = "Lcom/crashlytics/android/core/CrashlyticsCore;->setUserEmail(Ljava/lang/String;)V"
    targetStatement_2 = "Lcom/crashlytics/android/core/CrashlyticsCore;->setUserIdentifier(Ljava/lang/String;)V"
    targetStatement_3 = "Lcom/crashlytics/android/core/CrashlyticsCore;->setUserName(Ljava/lang/String;)V"

    text_toBeAdd_1 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    text_toBeAdd_2 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    text_toBeAdd_3 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
        # # second API
        if APIname_2 in line:  # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:  # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:  # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue
        # #
        # # # # API_3
        if APIname_3 in line:  # locate the API method
            flag = 3
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 3 and locals_org in line:  # change the locals
            text_part1.append(locals_new_3)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_3:  # locals is the place to insert
                text_part1.append(text_toBeAdd_3)
                # print "target 3 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 3 and targetStatement_3 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_3)
            flag = 0
            # flag_goPart2 = 1
            # print "target 3 %s: %d" % (line.strip(), index)
            continue

        else:
            text_part1.append(line)
        #
        APIfile.close()
        os.rename(APIfilePath, APIfilePath + "_bak")
        fw = open(APIfilePath, 'w+')
        for line in text_part1:
            # fw.write(line + '\n')
            fw.write(line)

#==================================================== com.amplitude.api.AmplitudeClient.setUserId ====================
def amplitude(app, testPath):

    APIfileName = "Amplitude.smali"
    APIname_1 = ".method public static setUserId(Ljava/lang/String;)V"
    locals_org = "locals"
    locals_new_1 = "    .locals 3"
    targetStatement_1 = "Lcom/amplitude/api/AmplitudeClient;->setUserId(Ljava/lang/String;)Lcom/amplitude/api/AmplitudeClient"

    text_toBeAdd_1 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)



##==================================================== com.appsee.Appsee.setUserId ==================== 9
def appsee(app, testPath):

    APIfileName = "Appsee.smali"
    APIname_1 = ".method public static setUserId(Ljava/lang/String;)V"
    locals_org = "locals"
    locals_new_1 = "    .locals 6"
    targetStatement_1 = "locals"

    text_toBeAdd_1 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)



#======================= com.applovin.adview.AppLovinIncentivizedInterstitial.setUserIdentifier ==================== 10
def applovin(app, testPath):
    APIfileName = "AppLovinIncentivizedInterstitial.smali"
    APIname_1 = ".method public setUserIdentifier(Ljava/lang/String;)V"
    locals_org = "locals"
    locals_new_1 = "    .locals 2"
    targetStatement_1 = "locals"

    text_toBeAdd_1 = " \
        new-instance v0, Ljava/lang/Exception; \n \
        const-string v1, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v0,v1}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v1, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)
#
# ==================================appsflyer================= 11 12 13
def appsflyer(app, testPath):
    APIfileName = "AppsFlyerLib.smali"
    APIname_1 = ".method public setAndroidIdData(Ljava/lang/String;)V"
    APIname_2 = ".method public setAppUserId(Ljava/lang/String;)V"
    APIname_3 = ".method public setCustomerUserId(Ljava/lang/String;)V"

    locals_org = "locals"
    locals_new_1= "    .locals 6"
    locals_new_2 = "    .locals 6"
    locals_new_3 = "    .locals 6"

    targetStatement_1 = "locals;"
    targetStatement_2 = "locals"
    targetStatement_3 = "locals"

    text_toBeAdd_1 = " \
        new-instance v4, Ljava/lang/Exception; \n \
        const-string v5, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v4,v5}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v4}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v5, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    text_toBeAdd_2 = " \
        new-instance v4, Ljava/lang/Exception; \n \
        const-string v5, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v4,v5}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v4}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v5, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    text_toBeAdd_3 = " \
        new-instance v4, Ljava/lang/Exception; \n \
        const-string v5, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v4,v5}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v4}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v5, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
        # # second API
        if APIname_2 in line:  # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:  # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:  # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue
        # #
        # # # # API_3
        if APIname_3 in line:  # locate the API method
            flag = 3
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 3 and locals_org in line:  # change the locals
            text_part1.append(locals_new_3)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_3:  # locals is the place to insert
                text_part1.append(text_toBeAdd_3)
                # print "target 3 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 3 and targetStatement_3 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_3)
            flag = 0
            # flag_goPart2 = 1
            # print "target 3 %s: %d" % (line.strip(), index)
            continue

        else:
            text_part1.append(line)
        #
        APIfile.close()
        os.rename(APIfilePath, APIfilePath + "_bak")
        fw = open(APIfilePath, 'w+')
        for line in text_part1:
            # fw.write(line + '\n')
            fw.write(line)

#
# ==================================firebase================= 14 15
def firebase(app, testPath):

    APIfileName = "FirebaseAnalytics.smali"
    APIname_1 = ".method public final setUserId(Ljava/lang/String;)V"
    APIname_2 = ".method public final setUserProperty(Ljava/lang/String;Ljava/lang/String;)V"


    locals_org = "locals"
    locals_new_1= "    .locals 5"
    locals_new_2 = "    .locals 3"

    targetStatement_1 = "locals;"
    targetStatement_2 = "locals"


    text_toBeAdd_1 = " \
        new-instance v3, Ljava/lang/Exception; \n \
        const-string v4, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v3,v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v3}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v4, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    text_toBeAdd_2 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I\n \
        invoke-static{v2, p2},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
        # # second API
        if APIname_2 in line:  # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:  # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:  # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)


# # ==================================ironsource================= 17
def ironsource(app, testPath):
    APIfileName = "IronSource.smali"
    locals_org = "locals"

    APIname_1 = ".method public static setUserId(Ljava/lang/String;)V"
    locals_new_1= "    .locals 3"
    targetStatement_1 = "locals;"

    APIname_2 = ".method public static declared-synchronized setGender(Ljava/lang/String;)V"
    locals_new_2= "    .locals 4"
    targetStatement_2 = "locals;"

    APIname_3 = ".method public static declared-synchronized setAge(I)V"
    locals_new_3= "    .locals 5"
    targetStatement_3 = "locals;"

    text_toBeAdd_1 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    text_toBeAdd_2 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    text_toBeAdd_3 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static {p0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;\n \
        move-result-object v4\n \
        invoke-static{v3, v4},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"



    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
        # # second API
        if APIname_2 in line:  # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:  # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:  # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue
        # #
        # # # # API_3
        if APIname_3 in line:  # locate the API method
            flag = 3
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 3 and locals_org in line:  # change the locals
            text_part1.append(locals_new_3)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_3:  # locals is the place to insert
                text_part1.append(text_toBeAdd_3)
                # print "target 3 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 3 and targetStatement_3 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_3)
            flag = 0
            # flag_goPart2 = 1
            # print "target 3 %s: %d" % (line.strip(), index)
            continue

        else:
            text_part1.append(line)
        #
        APIfile.close()
        os.rename(APIfilePath, APIfilePath + "_bak")
        fw = open(APIfilePath, 'w+')
        for line in text_part1:
            fw.write(line + '\n')
            # fw.write(line)



# ==================================flurry================= 16
def flurry(app, testPath):
    APIfileName = "FlurryAgent.smali"
    locals_org = "locals"

    APIname_1 = ".method public static setUserId(Ljava/lang/String;)V"
    locals_new_1= "    .locals 5"
    targetStatement_1 = "locals;"
    text_toBeAdd_1 = " \
        new-instance v3, Ljava/lang/Exception; \n \
        const-string v4, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v3,v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v3}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v4, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    APIname_2 = ".method public static setGender(B)V"
    locals_new_2= "    .locals 6"
    targetStatement_2 = "locals;"
    text_toBeAdd_2 = " \
        new-instance v3, Ljava/lang/Exception; \n \
        const-string v4, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v3,v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v3}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static {p0}, Ljava/lang/String;->valueOf(B)Ljava/lang/String;\n \
        move-result-object v5\n \
        invoke-static{v4, v5},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_3 = ".method public static setAge(I)V"
    locals_new_3= "    .locals 10"
    targetStatement_3 = "locals;"
    text_toBeAdd_3 = " \
        new-instance v7, Ljava/lang/Exception; \n \
        const-string v8, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v7,v8}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v7}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static {p0}, Ljava/lang/String;->valueOf(B)Ljava/lang/String;\n \
        move-result-object v9\n \
        invoke-static{v8, v8},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    APIname_4 = ".method public static setLocation(FF)V"
    locals_new_4= "    .locals 7"
    targetStatement_4 = "locals;"
    text_toBeAdd_4 = " \
       new-instance v3, Ljava/lang/Exception; \n \
        const-string v4, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v3,v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v3}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static {p0}, Ljava/lang/String;->valueOf(F)Ljava/lang/String;\n \
        move-result-object v5\n \
        invoke-static {p1}, Ljava/lang/String;->valueOf(F)Ljava/lang/String;\n \
        move-result-object v6\n \
        invoke-static{v4, v5, v6},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I"


    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath+app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
# # second API
        if APIname_2 in line:              # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:    # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:                     # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:       # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue
# #
# # # # API_3
        if APIname_3 in line:  # locate the API method
            flag = 3
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 3 and locals_org in line:  # change the locals
            text_part1.append(locals_new_3)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_3:  # locals is the place to insert
                text_part1.append(text_toBeAdd_3)
                # print "target 3 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 3 and targetStatement_3 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_3)
            flag = 0
            # flag_goPart2 = 1
            # print "target 3 %s: %d" % (line.strip(), index)
            continue
#
#  # # API_4
        if APIname_4 in line:  # locate the API method
            flag = 4
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 4 and locals_org in line:  # change the locals
            text_part1.append(locals_new_4)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_4:  # locals is the place to insert
                text_part1.append(text_toBeAdd_4)
                # print "target 4 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 4 and targetStatement_4 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_4)
            flag = 0
            # flag_goPart2 = 1
            print "target 4 %s: %d" % (line.strip(), index)
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)

# ==============================================googleAnalytics=================================================== 17
def googleAnalytics(app, testPath):
    APIfileName = "Tracker.smali"
    locals_org = "locals"

    APIname_1 = ".method public setClientId(Ljava/lang/String;)V"
    locals_new_1= "    .locals 3"
    targetStatement_1 = "locals;"
    text_toBeAdd_1 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"
    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)


# ==============================================newrelic=================================================== 17
def newrelic(app, testPath):
    APIfileName = "NewRelic.smali"
    locals_org = "locals"

    APIname_1 = ".method public static setUserId(Ljava/lang/String;)Z"
    locals_new_1= "    .locals 4"
    targetStatement_1 = "locals;"
    text_toBeAdd_1 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)






##=================================================MixpanelAPI==========================   1
def mixpanel(app, testPath):
    APIfileName = "MixpanelAPI.smali"
    APIname_1 = ".method public identify"

    locals_org = "locals"
    locals_new_1 = "    .locals 5"
    targetStatement_1 = "locals"
    text_toBeAdd_1 = " \
        new-instance v3, Ljava/lang/Exception;\n \
        const-string v4, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v3,v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v3}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v4, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)


#=================================================Leanplum==========================
def leanplum(app, testPath):
    APIfileName = "Leanplum.smali"
    APIname_1 = ".method public static setUserId"
    locals_org = "locals"

    locals_new_1 = "    .locals 5"
    targetStatement_1 = "locals"
    text_toBeAdd_1 = " \
        new-instance v3, Ljava/lang/Exception; \n \
        const-string v4, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v3,v4}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v3}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v4, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljstaticava/lang/String;)I"



    APIname_2 = ".method public static setUserAttributes(Ljava/lang/String;Ljava/util/Map;)V"
    locals_new_2 = "    .locals 6"
    targetStatement_2 = "Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;"
    text_toBeAdd_2 = " \
        new-instance v4, Ljava/lang/Exception; \n \
        const-string v5, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v4,v5}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v4}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v5, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_3 = ".method public static setDeviceId(Ljava/lang/String;)V"
    locals_new_3 = "    .locals 6"
    targetStatement_3 = "locals"
    text_toBeAdd_3 = " \
        new-instance v4, Ljava/lang/Exception; \n \
        const-string v5, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v4,v5}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v4}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v5, p0},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
        # # second API
        if APIname_2 in line:  # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:  # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:  # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue
        # #
        # # # # API_3
        if APIname_3 in line:  # locate the API method
            flag = 3
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 3 and locals_org in line:  # change the locals
            text_part1.append(locals_new_3)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_3:  # locals is the place to insert
                text_part1.append(text_toBeAdd_3)
                # print "target 3 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 3 and targetStatement_3 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_3)
            flag = 0
            # flag_goPart2 = 1
            # print "target 3 %s: %d" % (line.strip(), index)
            continue

        else:
            text_part1.append(line)
    #
        APIfile.close()
        os.rename(APIfilePath, APIfilePath + "_bak")
        fw = open(APIfilePath, 'w+')
        for line in text_part1:
            # fw.write(line + '\n')
            fw.write(line)

# ==============================================branch===================================================
def branch(app, testPath):
    APIfileName = "Branch.smali"
    locals_org = "locals"

    APIname_1 = ".method public setIdentity(Ljava/lang/String;)V"
    locals_new_1= "    .locals 3"
    targetStatement_1 = "locals;"
    text_toBeAdd_1 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath + app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            print "target 1: %d" % index
            continue

        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)


# ==============================================tune===================================================
def tune(app, testPath):
    APIfileName = "Tune.smali"
    locals_org = "locals"

    APIname_1 = ".method public setAge(I)V"
    locals_new_1= "    .locals 5"
    targetStatement_1 = "locals;"
    text_toBeAdd_1 = " \
    new-instance v2, Ljava/lang/Exception; \n \
    const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
    invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
    invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
    invoke-static {p1}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;\n \
    move-result-object v4\n \
    invoke-static{v3, v4},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"



    APIname_2 = ".method public setAndroidId(Ljava/lang/String;)V"
    locals_new_2= "    .locals 3"
    targetStatement_2 = "locals;"
    text_toBeAdd_2 = " \
        new-instance v1, Ljava/lang/Exception; \n \
        const-string v2, \"Xueling:printTrace with parameter:\"\n \
        invoke-direct {v1,v2}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v2, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_3 = ".method public setDeviceId(Ljava/lang/String;)V"
    locals_new_3= "    .locals 4"
    targetStatement_3 = "locals;"
    text_toBeAdd_3 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_4 = ".method public setFacebookUserId(Ljava/lang/String;)V"
    locals_new_4= "    .locals 4"
    targetStatement_4 = "locals;"
    text_toBeAdd_4 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_5 = ".method public setGoogleUserId(Ljava/lang/String;)V"
    locals_new_5= "    .locals 4"
    targetStatement_5 = "locals;"
    text_toBeAdd_5 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"



    APIname_6 = ".method public setTwitterUserId(Ljava/lang/String;)V"
    locals_new_6= "    .locals 4"
    targetStatement_6 = "locals;"
    text_toBeAdd_6 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    APIname_7 = ".method public setUserEmail(Ljava/lang/String;)V"
    locals_new_7= "    .locals 4"
    targetStatement_7 = "locals;"
    text_toBeAdd_7 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_8 = ".method public setUserId(Ljava/lang/String;)V"
    locals_new_8= "    .locals 4"
    targetStatement_8 = "locals;"
    text_toBeAdd_8 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"


    APIname_9 = ".method public setUserName(Ljava/lang/String;)V"
    locals_new_9= "    .locals 4"
    targetStatement_9 = "locals;"
    text_toBeAdd_9 = " \
        new-instance v2, Ljava/lang/Exception; \n \
        const-string v3, \"Third-party API invoke detection:Print StackTrace with parameter:\"\n \
        invoke-direct {v2,v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V\n \
        invoke-virtual {v2}, Ljava/lang/Exception;->printStackTrace()V\n \
        invoke-static{v3, p1},Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I"

    index = -1

    flag = 0

    text_part1 = []

    cmd = "find %s -iname \"%s\" " % (testPath+app, APIfileName)
    path = os.popen(cmd).readlines()
    # print path
    if path:
        APIfilePath = path[0].strip()
    else:
        print 'No ASMs method found!'
        return -1

    # print APIfilePath
    APIfile = open(APIfilePath)
    text_org = APIfile.readlines()
    # print "text_org len before: %d " %len(text_org)

    for line in text_org:
        index += 1

        # # APIname_1
        if APIname_1 in line:  # locate the API method
            flag = 1
            print "%s : %d" % (APIname_1, index)
            text_part1.append(line)
            continue

        if flag == 1 and locals_org in line:  # change the locals
            text_part1.append(locals_new_1)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_1:
                # print "target 1 %s: %d" % (line.strip(), index)        # locals is the place to insert
                text_part1.append(text_toBeAdd_1)
                flag = 0
                continue
            continue

        if flag == 1 and targetStatement_1 in line:  # the place to insert: target 1
            text_part1.append(line)
            text_part1.append(text_toBeAdd_1)
            flag = 0
            # flag_goPart2 = 1
            print "target 1: %d" % index
            continue
# # second API
        if APIname_2 in line:              # locate the API method
            flag = 2
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 2 and locals_org in line:    # change the locals
            text_part1.append(locals_new_2)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_2:                     # locals is the place to insert
                text_part1.append(text_toBeAdd_2)
                # print "target 2 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 2 and targetStatement_2 in line:       # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_2)
            flag = 0
            # flag_goPart2 = 1
            print "target 2 : %s: %d" % (line.strip(), index)
            continue
# #
# # # # API_3
        if APIname_3 in line:  # locate the API method
            flag = 3
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 3 and locals_org in line:  # change the locals
            text_part1.append(locals_new_3)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_3:  # locals is the place to insert
                text_part1.append(text_toBeAdd_3)
                # print "target 3 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 3 and targetStatement_3 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_3)
            flag = 0
            # flag_goPart2 = 1
            # print "target 3 %s: %d" % (line.strip(), index)
            continue
#
#  # # API_4
        if APIname_4 in line:  # locate the API method
            flag = 4
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 4 and locals_org in line:  # change the locals
            text_part1.append(locals_new_4)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_4:  # locals is the place to insert
                text_part1.append(text_toBeAdd_4)
                # print "target 4 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 4 and targetStatement_4 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_4)
            flag = 0
            # flag_goPart2 = 1
            print "target 4 %s: %d" % (line.strip(), index)
            continue

# API_5
        if APIname_5 in line:  # locate the API method
            flag = 5
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 5 and locals_org in line:  # change the locals
            text_part1.append(locals_new_5)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_5:  # locals is the place to insert
                text_part1.append(text_toBeAdd_5)
                # print "target 4 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 5 and targetStatement_5 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_5)
            flag = 0
            # flag_goPart2 = 1
            print "target 5 %s: %d" % (line.strip(), index)
            continue

# API_6
        if APIname_6 in line:  # locate the API method
            flag = 6
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 6 and locals_org in line:  # change the locals
            text_part1.append(locals_new_6)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_6:  # locals is the place to insert
                text_part1.append(text_toBeAdd_6)
                # print "target 4 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 6 and targetStatement_6 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_6)
            flag = 0
            # flag_goPart2 = 1
            print "target 6 %s: %d" % (line.strip(), index)
            continue
# API_7
        if APIname_7 in line:  # locate the API method
            flag = 7
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 7 and locals_org in line:  # change the locals
            text_part1.append(locals_new_7)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_7:  # locals is the place to insert
                text_part1.append(text_toBeAdd_7)
                # print "target 4 %s: %d" % (line.strip(), index)
                flag = 0
                continue
            continue

        if flag == 7 and targetStatement_7 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_7)
            flag = 0
            print "target 7 %s: %d" % (line.strip(), index)
            continue

# API_8
        if APIname_8 in line:  # locate the API method
            flag = 8
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 8 and locals_org in line:  # change the locals
            text_part1.append(locals_new_8)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_8:  # locals is the place to insert
                text_part1.append(text_toBeAdd_8)
                flag = 0
                continue
            continue

        if flag == 8 and targetStatement_8 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_8)
            flag = 0
            print "target 8 %s: %d" % (line.strip(), index)
            continue

# API_9
        if APIname_9 in line:  # locate the API method
            flag = 9
            print "%s: %d" % (line.strip(), index)
            text_part1.append(line)
            continue

        if flag == 9 and locals_org in line:  # change the locals
            text_part1.append(locals_new_9)
            print "%s: %d" % (line.strip(), index)
            if locals_org in targetStatement_9:  # locals is the place to insert
                text_part1.append(text_toBeAdd_9)
                flag = 0
                continue
            continue

        if flag == 8 and targetStatement_9 in line:  # the place to insert
            text_part1.append(line)
            text_part1.append(text_toBeAdd_9)
            flag = 0
            print "target 9 %s: %d" % (line.strip(), index)
            continue
        #
        else:
            text_part1.append(line)
    #
    APIfile.close()
    os.rename(APIfilePath, APIfilePath + "_bak")
    fw = open(APIfilePath, 'w+')
    for line in text_part1:
        # fw.write(line + '\n')
        fw.write(line)

