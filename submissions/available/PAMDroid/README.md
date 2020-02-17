<font size=5>**PAMDroid** </font>     
PAMDroid is a semi-automated approach to detect the misconfiguration of analytic services.  


<font size=5>**Dataset** </font>     
* Analytic Services  
We identified the 18 most popular analytic services using published statistics provided by AppBrain, a company specializing in app marketing and promotion. We collected the ASMs provided by the selected analytic services.

* Apps  
The too 1,000 free apps containing at least one invocation of the studied ASMs were collected from PlayDrone, a collection of meta data for Android apps on the Google Play store. We identified those apps which invoked ASMs by analyzing their smali code.


<font size=5>**Study Results** </font>  
The study results described in the paper can be found in /results/.      
* Misconfiguration (Using PII) in ASMs  
The file "/results/Invocation_1000.xlsx" includes the ASMs invocation of the 1000 apps under study. Among the 1000 apps, we found misconfigurations in 120 apps. In the file, the first column indicates the name of apps, the second column indicates the ASM that has been invoked by apps, the column 'value 1' and 'value 2' represents the parameters that has been passed to the ASMs. The last column 'Information Type' indicates the PII information type of the parameter values. 

* Policy Violations and Misalignment  
According to the invocation results, there are 120 apps having the misconfiguration issue. We manually inspect the privacy policy of those 120 apps and report the misalignment. The 120 privacy policies can be found in /PrivacyPolicies_120/. We reported misalignment in 27 apps and the detailed information can be found in "/results/PrivacyPolicyMisalignment.xlsx". In this file, column B to F represents the invocation results, column G and H are the data collection and sharing related text extracted from the privacy policy, column I J K are the decisions made by three of the authors, column L is the final decision. "Violation" in the final decision is also called "misalignment" in the paper. 


<font size=5>**Obtaining the Tool** </font>  
* The script for performing the study is under the directory /Artifact/;  
 
* "app-analytic.xlsx" lists all the apps and the analytic service providers they use. In the file, the first column indicates the name of the analytic service and the second column indicates the apps that using this analytic service. 

* Due to space limit, we can't upload all the 1000 apk files here. We put some apk files for testing under /testApp/. The name list of the 1000 apps can be found in the file 'app-analytic.xlsx'. If you want to test on other apps that not in /testApp/, you could download the apk file from googlePlay using the tool "gplaycli". Detail instruction of gplaycli can be found at https://github.com/matlink/gplaycli



<font size=5>**Run PAMDroid** </font>  

* To reproduce the results in the paper, the following preparation is needed:
    1. Install apktool, instructions can be found at https://ibotpeaches.github.io/Apktool/  
    2. Install Android Debug Bridge (adb), instructions can be found at https://developer.android.com/studio/command-line/adb   
    3. Have an android phone for dynamic analysis, connect the phone to your computer and enable USB debugging in the device system settings, under Developer options.  
    4. Our pre-defined user profile    
            First Name: UTSA   
            Last Name: Research  
            Username: utsaResearch  
            Email: utsaresearch2018@gmail.com  
            PassWord: uuuu8888 
              
    5. Our test device info: (your test device will be different)  
            IMEI: 355458061189396  
            Android ID: 757601f43fe6cab0  
            Serial Number: ZX1G22KHQK  
            Ads ID: ce3b1e33-8e03-4664-aafc-8d50f474a442  

* Steps to reproduce the result using PAMDroid (we take the app "com.texty.sms" as an example). Before start, make sure your test device is connected to the computer and USB debugging is enabled.   
    1. Download the apkfile "com.texty.sms.apk" from the directory /testApp/  (If you want to test on other apps, you can find other sample apps in the same directory.)

    2. Check the file "APP-Analytic" and find which analytic service is used in this app. In this example, "com.texty.sms" is using "Crashlytics". 

    3. In the PAMDroid.py, line 8, put the analytic service there. e.g. analyticService = 'Crashlytics'. Update the testPath to where your local path of the apk file. Run PAMdDoid.py (under python 2.7). 

    4. UI testing, when the program prints "please perform UI test", open the app on the test device.  At the same time, the program will ask whether you would like to perform UI testing by Monkey or not.
        * After you manually open the app, if the app requires login, please input 'n' and then manually login using the predefined user profile. In this example, the app "com.texty.sms.apk" requires email login, so we manually login with the username and password provided in the previous section.  
        
        * After you manually open the app, if the app does not need to login, you can just input 'y' to let Monkey to perform UI testing.  

    5. After finishing UI testing, there will be a generated system log, in this example, it will be "com.texty.sms.log". In the log file, search for the pre-defined flag "API invoke detection" to identify our instrumentation. You will find several invocations and one of them is "Third-party API invoke detection:Print StackTrace with parameter: utsaresearch2018@gmail.com". This means the developer is using email address on the ASM. Right before this flag, a callStack is provided and the top level of this callStack indicates which ASM has been invoked. In this example, the top level is "com.crashlytics.android.Crashlytics.setUserEmail(SourceFile: 258)" which means the developer invoked the ASM "Crashlytics.setUserEmail" and the parameter is the user's email address. 

    6. Check each flag, if the logged parameter of ASM is a PII:  
        * Read the app's privacy policy, report if find  misalignment
        * Read terms of use of the analytic service, report if find violation 


