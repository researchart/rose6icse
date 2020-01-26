# Fax -- License
* Install Java
* Install Ant
* Install Python 2.7
* Fax requires that the Z3 dynamic link library (libz3.so on Unix-like platforms) as well as the dynamic link library for the Z3/Java API (libz3java.so on Unix-like platforms) be in your dynamic library path ($LD\_LIBRARY\_PATH on Unix-like platforms; just PATH on Windows).
  * For Windows: copy lib/libz3/libz3.dll and lib/libz3/libz3java.dll to %JAVA_HOME%\bin\.
  * For Unix-like platforms: 
    * add java.library.path into file /etc/profile (export LD\_LIBRARY\_PATH=$LD\_LIBRARY\_PATH:/[your\_library\_path]).
    * copy lib/libz3/libz3.so and lib/libz3/libz3java.so to [your\_library\_path]
    * source /etc/profile
* Prepare Android environment, the version of Android SDK is 17 and the version of Android SDK Tools should lower than 25.2.3.
* Run "java -version", "python", "ant -version", "android create project" to check whether these tools are successfully configured.
* For quick start, you can run: runFax.sh or runFax.bat
