__WARN='\033[0;31m[WARN]\033[0m'

__DEBUG_FLAGS='CFLAGS="-O0 -g3 -fno-inline"             \
               CXXFLAGS="-O0 -g3 -fno-inline"           \
               CFLAGS_FOR_BUILD="-O0 -g3 -fno-inline"   \
               CFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"  \
               CXXFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" \
               CXXFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"'

__GCC_SRC_DIR=$HOME/repos/gcc-git
__RELEASE_BUILD_DIR=$HOME/builds/gcc-pristine
__DEBUG_BUILD_DIR=$HOME/builds/debug

alias xgcc="${__RELEASE_BUILD_DIR}/gcc/xgcc -B${__RELEASE_BUILD_DIR}/gcc"
alias xg++="${__RELEASE_BUILD_DIR}/gcc/xg++ -B${__RELEASE_BUILD_DIR}/gcc"
alias xgcc-debug="${__DEBUG_BUILD_DIR}/gcc/xgcc -B${__DEBUG_BUILD_DIR}/gcc"
alias xg++-debug="${__DEBUG_BUILD_DIR}/gcc/xg++ -B${__DEBUG_BUILD_DIR}/gcc"

alias mkgcc-in="make  -j 30  -C"

function mkmaster() {
    local old_branch=$(git -C ${__GCC_SRC_DIR} rev-parse --abbrev-ref HEAD)

    if git -C ${__GCC_SRC_DIR} checkout master ; then
        make -C ${__RELEASE_BUILD_DIR} -j 30 \
            && echo -e "\nmaster build finish time: $(date '+%F %T')\n"
    else
        echo -e "${__WARN} git checkout master failed"
        return 1
    fi

    echo -n "checking out old branch..."
    if git -C ${__GCC_SRC_DIR} checkout ${old_branch} ; then
        echo "done"
    else
        echo -e "\n${__WARN} git checkout old branch failed"
        return 1
    fi
}

function checkmaster() {
    make -C ${__RELEASE_BUILD_DIR} -j 30 -k $@ check
}

function mkdebug() {
    make -C ${__DEBUG_BUILD_DIR}   -j 30 $@  ${__DEBUG_FLAGS} \
        && echo -e "\ndebug build finish time: $(date '+%F %T')"
}

function cfggcc() {
    case "$1" in
        debug)
            local debug_flags=${__DEBUG_FLAGS}
            local bootstrap="--disable-bootstrap"
            ;;
        release)
            ;;
        *)
            echo "Usage:"
            echo "    $0 [debug|release]"
            return 1
            ;;
    esac

    bash -c "${debug_flags} ${__GCC_SRC_DIR}/configure \
        --enable-languages=all     \
        --with-cpu=power9          \
        --disable-multilab         \
        --with-long-double-128     \
        ${bootstrap} --prefix=/tmp/gcc-tmpi"
}
