#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/install/llvm/bin:$HOME/github/emacs/src:$PATH:$HOME/github/ripgrep/target/release:$HOME/repos/skara/build/bin"

igv() {
    local JT_HOME=/usr/lib/jvm/java-8-openjdk-arm64
    cd $HOME/utils/IdealGraphVisualizer && ./igv.sh
    cd -
}

export JAVA_HOME=$HOME/builds/panama/fastdebug/head/images/jdk
export JAVA=${JAVA_HOME}/bin/java
export JAVAC=${JAVA_HOME}/bin/javac

export OJAVA_HOME=$HOME/builds/panama/fastdebug/origin/images/jdk
export OJAVA=${OJAVA_HOME}/bin/java
export OJAVAC=${OJAVA_HOME}/bin/javac

export SJAVA_HOME=$HOME/builds/panama/slowdebug/origin/images/jdk
export SJAVA=${SJAVA_HOME}/bin/java
export SJAVAC=${SJAVA_HOME}/bin/javac
