#!/bin/bash

#TestLongVectorM
input_files="
TestIntVector
"
#export JAVA_DIR=/usr/lib/jvm/java-8-oracle/bin
export JAVA_DIR=$(realpath $1)/images/jdk/bin
#options_vect="-XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation -XX:CompilerDirectivesFile=./compiler_directive.txt  -XX:+PrintAssembly -XX:+TraceLoopOpts -XX:+TraceSuperWord -XX:+Verbose -XX:+TraceNewVectors -XX:+PrintIntrinsics "
#options_vect="-XX:+UnlockDiagnosticVMOptions  -XX:+PrintIntrinsics "
options_vect="-XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation  -XX:+TraceLoopOpts -XX:+Verbose -XX:+TraceLoopLimitCheck"
#options_vect="-XX:+UnlockDiagnosticVMOptions -XX:+TraceLoopOpts -XX:-TieredCompilation  -XX:+TraceSuperWord -XX:+Verbose -XX:+TraceNewVectors"
#options_vect="-XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation -XX:+PrintAssembly"
#options_vect="-XX:+UnlockDiagnosticVMOptions -XX:+PrintCompilation -XX:CompilerDirectivesFile=./compiler_directive.txt  -XX:+PrintAssembly  -XX:+Verbose -XX:-TieredCompilation"
#options_verify="-XX:-TieredCompilation -XX:+DebugVectorApi  "
options_verify="-XX:-TieredCompilation "
module="--add-modules jdk.incubator.vector"
options_ig="-XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation -XX:PrintIdealGraphLevel=2 -XX:PrintIdealGraphAddress=10.169.36.88"
arch=$(uname -m)

if [ "$2"x == "make"x ]; then
  run cd $(realpath $1)
  run make hotspot
  run cp ./jdk/lib/server/libjvm.so ./images/jdk/lib/server/libjvm.so
  run cd -
fi
#-XX:+UseVectorApiIntrinsics
for input in $input_files
do
    run $JAVA_DIR/javac $module  $input.java | tee $input."$arch".compile
    #$run $JAVA_DIR/java $module $input
    #run $JAVA_DIR/java $module $options_verify  $input | tee $input."$arch".verify.bad
    run $JAVA_DIR/java $module $options_vect -XX:CompileCommand=compileonly,$input.*  $input  2>&1 | tee $input.java."$arch".rc.asm
    #run $JAVA_DIR/java $module $options_ig -XX:CompileCommand=compileonly,$input.* $input
done


~/builds/panama-build/jdk/bin/javac --add-modules jdk.incubator.vector /home/qifen01/test/java/Test.java

~/builds/panama-build/jdk/bin/java --add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation  -XX:+TraceLoopOpts -XX:+Verbose -XX:+TraceLoopLimitCheck -XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation -XX:PrintIdealGraphLevel=2 -XX:PrintIdealGraphAddress=localhost -XX:CompileCommand=compileonly,Test.ADDByte128VectorTests /home/qifen01/test/java/Test.java

~/builds/panama-build/jdk/bin/java --add-modules jdk.incubator.vector -XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation  -XX:+TraceLoopOpts -XX:+Verbose -XX:+TraceLoopLimitCheck -XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation -XX:PrintIdealGraphLevel=2 -XX:PrintIdealGraphAddress=10.169.139.34 -XX:CompileCommand=compileonly,Test.* /home/qifen01/test/java/Test.java

/home/qifen01/builds/panama-build/jdk/bin/java \
    --add-modules jdk.incubator.vector         \
    -XX:+UnlockDiagnosticVMOptions             \
    -XX:-TieredCompilation                     \
    -XX:+TraceLoopOpts                         \
    -XX:+Verbose                               \
    -XX:+TraceLoopLimitCheck                   \
    -XX:PrintIdealGraphLevel=2                 \
    -XX:PrintIdealGraphAddress=10.169.139.34   \
    -XX:CompileCommand=compileonly,Test.* /home/qifen01/test/java/Test.java
