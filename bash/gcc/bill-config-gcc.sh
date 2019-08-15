function setgcc_usage() {
    echo "Usage:  setgcc <branch> [debug]" 2>&1;
    echo "  Example:  setgcc base" 2>&1
    echo "    looks for $HOME/gcc/gcc-mainline-base" 2>&1
    echo "           or $HOME/gcc/gcc-base" 2>&1
    echo "    looks for $HOME/gcc/build/gcc-mainline-base" 2>&1
    echo "           or $HOME/gcc/build/gcc-base" 2>&1
    echo "    looks for $HOME/gcc/install/gcc-mainline-base" 2>&1
    echo "           or $HOME/gcc/install/gcc-base" 2>&1
    echo ""
    echo "  Example:  setgcc pr46556 debug" 2>&1
    echo "    looks for $HOME/gcc/gcc-mainline-pr46556" 2>&1
    echo "           or $HOME/gcc/gcc-pr46556" 2>&1
    echo "    looks for $HOME/gcc/build/gcc-mainline-pr46556-debug" 2>&1
    echo "           or $HOME/gcc/build/gcc-pr46556-debug" 2>&1
    echo "    looks for $HOME/gcc/install/gcc-mainline-pr46556-debug" 2>&1
    echo "           or $HOME/gcc/install/gcc-pr46556-debug" 2>&1
}

function makegcc_usage() {
    echo "Usage:  makegcc <width> [debug | boot]" 2>&1
    echo "" 2>&1
    echo "  Builds GCC using the current Makefile, issuing make" 2>&1
    echo "  with the -j <width> option.  You should run this" 2>&1
    echo "  from your GCC_BUILD directory." 2>&1
    echo "" 2>&1
    echo "  makegcc <width> debug (default) builds with CFLAGS set" 2>&1
    echo "  for debugging; makegcc <width> boot uses default CFLAGS." 2>&1
}

# setgcc <branch> [debug]
#
# Sets GCC_SRC, GCC_BUILD, and GCC_INSTALL appropriately.
function setgcc() {
    local branch=$1
    local debug
    local dir

    if [ $# -eq 0 -o $# -gt 2 ] ; then
        setgcc_usage
        return 1
    else
        if [ $# -eq 2 ] && [ $2 = "debug" ] ; then
            debug="-debug"
        fi

        if [ -d $HOME/gcc/gcc-mainline-$branch ] ; then
            dir="gcc-mainline-$branch"
        elif [ -d $HOME/gcc/gcc-$branch ] ; then
            dir="gcc-$branch"
        else
            echo "Could not find $HOME/gcc/gcc-mainline-$branch or $HOME/gcc/gcc-$branch" 2>&1
            return 1
        fi

        local dirdebug=$dir$debug
        if [ ! -d $HOME/gcc/build/$dirdebug ] ; then
            echo "Could not find $HOME/gcc/build/$dirdebug" 2>&1
            return 1
        fi

        if [ ! -d $HOME/gcc/install/$dirdebug ] ; then
            echo "Could not find $HOME/gcc/install/$dirdebug" 2>&1
            return 1
        fi

        export GCC_SRC=$HOME/gcc/$dir
        export GCC_BUILD=$HOME/gcc/build/$dirdebug
        export GCC_INSTALL=$HOME/gcc/install/$dirdebug

        echo "GCC_SRC     = $GCC_SRC"
        echo "GCC_BUILD   = $GCC_BUILD"
        echo "GCC_INSTALL = $GCC_INSTALL"
    fi
}

# makegcc <width> [debug | boot]
#
# Build GCC in bootstrap or debug mode.
function makegcc() {
    if [ $# -eq 0 -o $# -gt 2 ] ; then
        makegcc_usage
        return 1
    fi

    local jobs=$1
    local build_type=$2

    case "$build_type" in
        "debug")
            make -j $jobs                                 \
                 CFLAGS="-O0 -g3 -fno-inline"             \
                 CXXFLAGS="-O0 -g3 -fno-inline"           \
                 CFLAGS_FOR_BUILD="-O0 -g3 -fno-inline"   \
                 CFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"  \
                 CXXFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" \
                 CXXFLAGS_FOR_TARGET="-O0 -g3 -fno-inline" 2>&1 | tee BUILD.log
            ;;
        "boot")
            make -j $jobs 2>&1 | tee BUILD.log
            ;;
        *)
            makegcc_usage
            ;;
    esac
}
