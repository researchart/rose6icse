import os
import instrumentation
import Monkey
from multiprocessing import Process
import pexpect
import sys

app = 'com.texty.sms'
analyticService = 'Crashlytics'
testPath = '/home/xueling/git/rose6icse/submissions/available/XuelingZhang/testAPP/'


# #decode the apk file into smali code
decodeCmd = "apktool d %s -o %s%s" % (testPath+app+'.apk', testPath, app)
print decodeCmd
os.system(decodeCmd)

##perfomr corresponding intrumentation according to the analytic service
if analyticService == 'Tune':
    instrumentation.tune(app, testPath)

if analyticService == 'Mixpanel':
    instrumentation.mixpanel(app, testPath)

if analyticService == 'Branch':
    instrumentation.branch(app, testPath)

if analyticService == 'Leanplum':
    instrumentation.leanplum(app, testPath)

if analyticService == 'Crashlytics':
    instrumentation.crashlytics(app, testPath)

if analyticService == 'Appsee':
    instrumentation.appsee(app, testPath)

if analyticService == 'Applovin':
    instrumentation.applovin(app, testPath)

if analyticService == 'Appsflyer':
    instrumentation.appsflyer(app, testPath)

if analyticService == 'Firebase':
    instrumentation.firebase(app, testPath)

if analyticService == 'Ironsource':
    instrumentation.ironsource(app, testPath)

if analyticService == 'Flurry':
    instrumentation.flurry(app, testPath)

if analyticService == 'GoogleAnalytics':
    instrumentation.googleAnalytics(app, testPath)

if analyticService == 'Newrelic':
    instrumentation.newrelic(app, testPath)

#rebuild
rm = "rm %s" %(testPath+app+'.apk')
os.system(rm)
rebuildCmd = "apktool b %s -o %s" % (testPath+app, testPath+app+'_1.apk')
os.system(rebuildCmd)


#Generate key for app
KeyGenCmd = "keytool -genkey -alias abc.keystore -keyalg RSA -validity 20000 -keystore %s%s"%(testPath, app+'.keystore')
print KeyGenCmd
child = pexpect.spawn(KeyGenCmd, logfile = sys.stdout)

#password
try:
    if(child.expect([pexpect.TIMEOUT, 'password'])):
        child.sendline('123456')
except:
    print (str(child))


#re-enter password
try:
    if (child.expect([pexpect.TIMEOUT, 'Re-enter'])):
        child.sendline('123456')
except:
    print (str(child))


# last name
try:
    if (child.expect([pexpect.TIMEOUT, 'last'])):
        child.sendline('zhang')
except:
    print (str(child))


# unit
try:
    if (child.expect([pexpect.TIMEOUT, 'unit'])):
        child.sendline('utsa')
except:
    print (str(child))


# organization
try:
    if (child.expect([pexpect.TIMEOUT, 'organization'])):
        child.sendline('utsa')
except:
 print (str(child))


# city
try:
    if (child.expect([pexpect.TIMEOUT, 'City'])):
        child.sendline('SA')
except:
    print (str(child))


# state
try:
    if (child.expect([pexpect.TIMEOUT, 'State'])):
        child.sendline('Tx')
except:
    print (str(child))

# country code
try:
    if (child.expect([pexpect.TIMEOUT, 'country code'])):
        child.sendline('01')
except:
    print (str(child))

# correct?
try:
    if (child.expect([pexpect.TIMEOUT, 'correct'])):
        child.sendline('y')
except:
    print (str(child))


# RETURN
try:
    if (child.expect([pexpect.TIMEOUT, 'RETURN'])):
        child.sendline('\n')
except:
    print (str(child))


try:
    child.expect([pexpect.TIMEOUT, pexpect.EOF])
except:
    print (str(child))

# assign the key to the new apk file
assignCmd = "jarsigner -verbose -keystore %s%s -storepass 123456 -signedjar %s%s %s%s abc.keystore" %(testPath, app+'.keystore',testPath,app+'.apk', testPath, app+'_1.apk')
print assignCmd
child = pexpect.spawn(assignCmd, logfile = sys.stdout)

#password
try:
    if(child.expect([pexpect.TIMEOUT, 'password'])):
        child.sendline('123456')
except:
    print (str(child))
try:
    child.expect([pexpect.TIMEOUT, pexpect.EOF])
except:
    print (str(child))

###install the app and run GUI test, make sure your mobile device in connected to the computer
cmd_install = 'adb install ' + testPath + app + '.apk'
print cmd_install
os.system(cmd_install)
cmd_logcat_c = 'adb logcat -c'
print cmd_logcat_c
os.system(cmd_logcat_c)
cmd_logcat_out = 'adb logcat > ' + testPath + app +'.log'
print cmd_logcat_out
print 'please perform UI test............'

p = Process(target= Monkey.getUserInput(app, testPath))
p.start()
os.system(cmd_logcat_out)







