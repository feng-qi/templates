#!/bin/bash

set -e

JTREG_VERSION=4.2
JTREG_NUMBER=b14
JTREG_JUNIT=4.10
JTREG_TESTNG=6.9.5
JTREG_JCOMMANDER=1.72

JT_ROOT=/home/qifen01/repos/jtreg
mkdir -p $JT_ROOT
# cd $JT_ROOT
cd $JT_ROOT && rm -rf jtreg-hg
hg clone http://hg.openjdk.java.net/code-tools/jtreg jtreg-hg
cd jtreg-hg
hg update -r jtreg$JTREG_VERSION-$JTREG_NUMBER -C

hg import -u bot -m "Workaround asmtools classLoader issue" ~/ci-scripts/docker/images/ubuntu/openjdk-test.rootfs.modified/tmp/jtreg-fix-classloader.patch
hg import -u bot -m "Add armie support" ~/ci-scripts/docker/images/ubuntu/openjdk-test.rootfs.modified/tmp/jtreg-armie-support.patch

cd ..
mkdir -p $JT_ROOT/dependencies
wget https://github.com/downloads/junit-team/junit/junit-$JTREG_JUNIT.jar -O $JT_ROOT/dependencies/junit-$JTREG_JUNIT.jar
wget http://central.maven.org/maven2/org/testng/testng/$JTREG_TESTNG/testng-$JTREG_TESTNG.jar -O $JT_ROOT/dependencies/testng-$JTREG_TESTNG.jar
wget http://central.maven.org/maven2/com/beust/jcommander/$JTREG_JCOMMANDER/jcommander-$JTREG_JCOMMANDER.jar -O $JT_ROOT/dependencies/jcommander-$JTREG_JCOMMANDER.jar

cd $JT_ROOT/dependencies
hg clone http://hg.openjdk.java.net/code-tools/asmtools asmtools-src
JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8 ant -f asmtools-src/build/build.xml -Dbuildprod.dir=$JT_ROOT/dependencies/asmtools-build
cp $JT_ROOT/dependencies/asmtools-build/release/lib/asmtools.jar $JT_ROOT/dependencies

cd $JT_ROOT
ant -v -f jtreg-hg/make/build.xml                                           \
    -Djavatest.jar=/home/qifen01/jars/javatest.jar                          \
    -Djh.jar=/home/qifen01/jars/jh.jar                                      \
    -Djhall.jar=/home/qifen01/jars/jhall.jar                                \
    -Djunit.jar=$JT_ROOT/dependencies/junit-$JTREG_JUNIT.jar                \
    -Dtestng.jar=$JT_ROOT/dependencies/testng-$JTREG_TESTNG.jar             \
    -Djcommander.jar=$JT_ROOT/dependencies/jcommander-$JTREG_JCOMMANDER.jar \
    -Dasmtools.jar=$JT_ROOT/dependencies/asmtools.jar                       \
    -Dbuild.version=$JTREG_VERSION -Dbuild.number=$JTREG_NUMBER

cp /usr/share/java/javatest.jar jtreg-hg/dist/jtreg/lib
cp jtreg-hg/dist/jtreg/lib/jtreg.jar jtreg-hg/dist/jtreg/
