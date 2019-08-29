#!/usr/bin/env bash

export JT_JAVA=/usr/lib/jvm/jdk13
export JT_HOME=$HOME/repos/jtreg/jtreg-hg/dist/jtreg
alias jtreg='/home/qifen01/repos/jtreg/jtreg-hg/dist/jtreg/bin/jtreg'
alias jtdiff='/home/qifen01/repos/jtreg/jtreg-hg/dist/jtreg/bin/jtdiff'

igv() {
    local JT_HOME=/usr/lib/jvm/java-8-openjdk-arm64
    cd /home/qifen01/utils/IdealGraphVisualizer && ./igv.sh
    cd -
}

export JAVA_HOME=$HOME/builds/panama-build/jdk
export JAVA=$JAVA_HOME/bin/java
export JAVAC=$JAVA_HOME/bin/javac

options_comm="-XX:+UnlockDiagnosticVMOptions -XX:-TieredCompilation"
options_vect="-XX:+TraceLoopOpts -XX:+Verbose -XX:+TraceLoopLimitCheck"
options_verify="-XX:-TieredCompilation"
module="--add-modules jdk.incubator.vector"
# options_ig="-XX:PrintIdealGraphLevel=2 -XX:PrintIdealGraphAddress=10.169.139.34"
options_ig="-XX:PrintIdealGraphLevel=2 -XX:PrintIdealGraphAddress=127.0.0.1"

Javac() {
    bash -c "$JAVAC $module $@"
}

Java() {
    bash -c "$JAVA $module $@"
}

J() {
    local filename=$1
    local filename_no_ext=${filename%.*}
    Javac $filename && Java $filename_no_ext
}

Jshow() {
    if [ $# -lt 1 ]; then
        echo "Usage:"
        echo "    $0 [-c] [-d|--dry-run] <file> [function [function [...]]]"
        echo "      -c: do compile first"
        echo "      -d: only print command that will run"
        return 1
    fi

    local COLR_RED='\033[0;31m'
    local COLR_GREEN='\033[0;32m'
    local COLR_NC='\033[0m' # No Color
    local WARN='\033[0;31m[WARN]\033[0m'
    local INFO='\033[0;32m[INFO]\033[0m'

    local dry_run=false
    local need_compile=false
    while [[ "$1" =~ ^(-c|-d|--dry-run)$ ]]; do
        case "$1" in
            -c)
                need_compile=true
                shift ;;
            -d|--dry-run)
                dry_run=true
                shift ;;
            *)
                break ;;
        esac
    done

    # get file and function names
    local file=$(realpath $1)
    shift
    if [ -z $file ]; then
        return 1
    fi
    local filename=$(basename $file)
    local filename_no_ext=${filename%.*}
    if [ -z $filename_no_ext ]; then
        echo "Can't parse filename"
        return 1
    fi

    # do compile
    local cmd=""
    if $need_compile; then
        cmd="$JAVAC $module $file"
        echo -e "${INFO} Compiling: $cmd"
        $dry_run || bash -c "$cmd"
    fi

    local funcs=$@              # the rest is function names
    if [ -z $funcs ]; then      # if no function name specified
        # cmd="$JAVA $module $options_comm $options_vect $options_ig -XX:CompileCommand=compileonly,$filename_no_ext.* $filename_no_ext"
        cmd="$JAVA $module $options_comm $options_vect $options_ig $filename_no_ext"
        echo -e "${INFO} Running command: $cmd"
        $dry_run || bash -c "$cmd"
        # return 0
    else
        for func in $funcs; do
            cmd="$JAVA $module $options_comm $options_vect $options_ig -XX:CompileCommand=compileonly,$filename_no_ext.$func $filename_no_ext"
            echo -e "${INFO} Running command: $cmd"
            $dry_run || bash -c "$cmd"
        done
    fi
}
