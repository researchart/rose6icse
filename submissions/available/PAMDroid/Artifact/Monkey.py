import os
import subprocess

def getUserInput(app, testPath):
    answer = raw_input('Would do like to let Monkey run the UI test? (y/n)')
    print answer
    if answer == 'y':
        print 'aaaaa'
        monkey(app, testPath)

def getPackageName(installName):
    cmd = 'aapt dump badging "%s" '%installName
    print cmd
    str= os.popen(cmd).readlines()[0].split(" ")[1]
    return str[6:-1]

def monkey(app, testPath):
    cmd_setting = "adb shell settings put global policy_control immersiver.full=*"
    print cmd_setting
    os.system(cmd_setting)


    # path = paths[j].strip()
    # cmd_install = "adb install %s" % testPath+app+'.apk'
    # print cmd_install
    # os.system(cmd_install)

    packageName = getPackageName(testPath+app+'.apk')
    print packageName


    cmd2 = "adb shell monkey -p  %s  -v 5000" % packageName
    print cmd2
    os.system(cmd2)

    cmd_remove = "adb uninstall %s" % packageName
    print cmd_remove
    os.system(cmd_remove)

    cmd3 = "adb kill-server"
    os.system(cmd3)