
LIB_PATH=./CommentCollection/lib
POI_PATH=$LIB_PATH/poi-ooxml-4.0.1.jar:$LIB_PATH/poi-4.0.1.jar:$LIB_PATH/poi-ooxml-schemas-4.0.1.jar
POI_PATH=$POI_PATH:$LIB_PATH/poi-lib/activation-1.1.1.jar:$LIB_PATH/poi-lib/commons-codec-1.11.jar:$LIB_PATH/poi-lib/commons-collections4-4.2.jar:$LIB_PATH/poi-lib/commons-compress-1.18.jar:$LIB_PATH/poi-lib/commons-logging-1.2.jar:$LIB_PATH/poi-lib/commons-math3-3.6.1.jar:$LIB_PATH/poi-lib/jaxb-api-2.3.0.jar:$LIB_PATH/poi-lib/jaxb-core-2.3.0.1.jar:$LIB_PATH/poi-lib/jaxb-impl-2.3.0.1.jar:$LIB_PATH/poi-lib/junit-4.12.jar:$LIB_PATH/poi-lib/log4j-1.2.17.jar

AST_PATH=$LIB_PATH/org.eclipse.jdt.core_3.15.0.v20180905-0317.jar:$LIB_PATH/org.eclipse.equinox.common_3.10.100.v20180827-1235.jar:$LIB_PATH/org.eclipse.core.resources_3.13.100.v20180828-0158.jar:$LIB_PATH/org.eclipse.core.jobs_3.10.100.v20180817-1215.jar:$LIB_PATH/org.eclipse.core.runtime_3.15.0.v20180817-1401.jar:$LIB_PATH/org.eclipse.osgi_3.13.100.v20180827-1536.jar:$LIB_PATH/org.eclipse.equinox.preferences_3.7.200.v20180827-1235.jar:$LIB_PATH/org.eclipse.core.contenttype_3.7.100.v20180817-1401.jar

NLP_PATH=$LIB_PATH/stanford-corenlp-3.9.2.jar:$LIB_PATH/stanford-corenlp-3.9.2-models.jar:$LIB_PATH/opennlp-tools-1.9.0.jar
JDOM_PATH=$LIB_PATH/jdom-2.0.6.jar




#export CLASSPATH=$POI_PATH:$AST_PATH:$NLP_PATH:$JDOM_PATH:./CommentCollection/src:./:$CLASSPATH
export CLASSPATH=./CommentCollection/src:./:$CLASSPATH
export CLASSPATH=$CLASSPATH:$LIB_PATH/*:$LIB_PATH/poi-lib/*
echo $CLASSPATH

javac ./CommentCollection/src/cs/purdue/edu/propagate/util/DonePropagator.java



HOW_HOME=$PWD
PROJECT_SRC=$HOW_HOME/Nicad_input/input_apachedb/
CODE_CLONE_RESULT=$HOW_HOME/code_clone_results/apachedb.txt
OUTPUT=$HOW_HOME/apachedb_result.xlsx
java cs.purdue.edu.propagate.util.DonePropagator $PROJECT_SRC $CODE_CLONE_RESULT  $OUTPUT


HOW_HOME=$PWD
PROJECT_SRC=$HOW_HOME/Nicad_input/input_collections/
CODE_CLONE_RESULT=$HOW_HOME/code_clone_results/collections.txt
OUTPUT=$HOW_HOME/collections_result.xlsx
java cs.purdue.edu.propagate.util.DonePropagator $PROJECT_SRC $CODE_CLONE_RESULT  $OUTPUT

HOW_HOME=$PWD
PROJECT_SRC=$HOW_HOME/Nicad_input/input_guava/
CODE_CLONE_RESULT=$HOW_HOME/code_clone_results/guava.txt
OUTPUT=$HOW_HOME/guava_result.xlsx
java cs.purdue.edu.propagate.util.DonePropagator $PROJECT_SRC $CODE_CLONE_RESULT  $OUTPUT

HOW_HOME=$PWD
PROJECT_SRC=$HOW_HOME/Nicad_input/input_jdk/
CODE_CLONE_RESULT=$HOW_HOME/code_clone_results/jdk.txt
OUTPUT=$HOW_HOME/jdk_result.xlsx
java cs.purdue.edu.propagate.util.DonePropagator $PROJECT_SRC $CODE_CLONE_RESULT  $OUTPUT

HOW_HOME=$PWD
PROJECT_SRC=$HOW_HOME/Nicad_input/input_joda/
CODE_CLONE_RESULT=$HOW_HOME/code_clone_results/joda.txt
OUTPUT=$HOW_HOME/joda_result.xlsx
java cs.purdue.edu.propagate.util.DonePropagator $PROJECT_SRC $CODE_CLONE_RESULT  $OUTPUT

