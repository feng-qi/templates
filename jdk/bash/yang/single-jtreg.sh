#!/bin/bash

if [ $# -ne 1 ] ; then
  msg "Usage : $0  <build-jdk-folder>"
  msg "Sample : $0 build-slowdebug"
  err "Invalid usage!"
fi

src_dir=$PWD
build_dir=$src_dir/$1
build_jdk_dir=$build_dir/images/jdk
#module_opt="-nativepath:$build_dir/images/test/hotspot/jtreg/native"
jtworkdir=$build_dir/jtwork
reportroot=$build_dir/jtreports
report_dir="$reportroot/$testname"
safe mkdir -p $jtworkdir
safe mkdir -p $reportroot
safe mkdir -p $report_dir

JT_HOME=/home/yanzha01/jdk/jtreg/jtreg-hg/dist/jtreg
jtreg="$JT_HOME/bin/jtreg"
jtdiff="$JT_HOME/bin/jtdiff"
#incubator/vector/Byte128VectorTests.java
#incubator/vector/Short128VectorTests.java
#incubator/vector/Int128VectorTests.java
#incubator/vector/Long128VectorTests.java
#incubator/vector/Float128VectorTests.java
#incubator/vector/Double128VectorTests.java
#incubator/vector/Byte64VectorTests.java
#incubator/vector/Short64VectorTests.java
#incubator/vector/Int64VectorTests.java
#incubator/vector/Long64VectorTests.java
#incubator/vector/Float64VectorTests.java
#incubator/vector/Double64VectorTests.java
#incubator/vector/Byte128VectorLoadStoreTests.java
#incubator/vector/Short128VectorLoadStoreTests.java
#incubator/vector/Int128VectorLoadStoreTests.java
#incubator/vector/Long128VectorLoadStoreTests.java
#incubator/vector/Float128VectorLoadStoreTests.java
#incubator/vector/Double128VectorLoadStoreTests.java
#incubator/vector/Byte64VectorLoadStoreTests.java
#incubator/vector/Short64VectorLoadStoreTests.java
#incubator/vector/Int64VectorLoadStoreTests.java
#incubator/vector/Long64VectorLoadStoreTests.java
#incubator/vector/Float64VectorLoadStoreTests.java
#incubator/vector/Double64VectorLoadStoreTests.java
#incubator/vector/VectorReshapeTests.java
#incubator/vector/Short128VectorTests.java
#incubator/vector/Int128VectorTests.java
#incubator/vector/Long128VectorTests.java
#incubator/vector/VectorHash.java

java_list="
incubator/vector
"

java_list="
incubator/vector/Byte128VectorTests.java
incubator/vector/Short128VectorTests.java
incubator/vector/Int128VectorTests.java
incubator/vector/Long128VectorTests.java
incubator/vector/Byte64VectorTests.java
incubator/vector/Short64VectorTests.java
incubator/vector/Int64VectorTests.java
incubator/vector/Long64VectorTests.java
"
java_list3="
incubator/vector/Float64VectorTests.java
incubator/vector/Float128VectorTests.java
incubator/vector/Double64VectorTests.java
incubator/vector/Double128VectorTests.java
incubator/vector/VectorReshapeTests.java
incubator/vector/Float64VectorTests.java
incubator/vector/Float128VectorTests.java
incubator/vector/Double64VectorTests.java
incubator/vector/Double128VectorTests.java
java/lang/invoke/VarHandles/VarHandleTestAccessLong.java
java/lang/invoke/VarHandles/VarHandleTestMethodHandleAccessLong.java
java/lang/invoke/VarHandles/VarHandleTestMethodHandleAccessShort.java
"
#      -vmoptions:"--add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:+PrintAssembly -XX:-TieredCompilation" \
#      -vmoptions:"--add-modules jdk.incubator.vector -XX:+UseVectorApiIntrinsics" \
#      -vmoptions:"--add-modules jdk.incubator.vector -XX:+DebugVectorApi" \
#      $src_dir/git_dev/test/jdk/jdk/$test_case
for test_case in $java_list
do
  name=$(cut -d/ -f3 <<< $test_case | cut -d. -f1)
  workdir=$jtworkdir$name
  run $jtreg -othervm -a -ea -esa -va \
      -vmoptions:"--add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions  -XX:+DebugVectorApi -XX:-TieredCompilation" \
      -ignore:quiet -timeoutFactor:16 \
      -J-Xmx4g -testjdk:$build_jdk_dir -server -r:$report_dir -w:$workdir \
      $src_dir/git_dev/test/jdk/jdk/$test_case
done

jtreg -othervm -a -ea -esa -va \
      -vmoptions:"--add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:+DebugVectorApi -XX:-TieredCompilation -XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation -XX:PrintIdealGraphLevel=2 -XX:PrintIdealGraphAddress=localhost -XX:CompileCommand=compileonly,$input.*" \
      -ignore:quiet -timeoutFactor:16 \
      -J-Xmx4g -testjdk:$HOME/builds/panama-build/jdk -server -r:$HOME/builds/panama-build/JTreport -w:$HOME/builds/panama-build/JTwork \
      $HOME/repos/panama/test/jdk/jdk/incubator/vector/Byte128VectorTests.java
