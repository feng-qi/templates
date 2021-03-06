__WARN='\033[0;31m[WARN]\033[0m'

__DEBUG_FLAGS='CFLAGS="-O0 -g3 -fno-inline"             \
               CXXFLAGS="-O0 -g3 -fno-inline"           \
               CFLAGS_FOR_BUILD="-O0 -g3 -fno-inline"   \
               CFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"  \
               CXXFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" \
               CXXFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"'

__GCC_SRC_DIR=$HOME/repos/gcc-git
__GCC_SRC_PRISTINE_DIR=$HOME/repos/gcc-pristine
__DEBUG_BUILD_DIR=$HOME/builds/debug
__RELEASE_BUILD_DIR=$HOME/builds/release
__PRISTINE_BUILD_DIR=$HOME/builds/pristine
__DEFAULT_JOB_COUNT=30

alias xgcc-debug="${__DEBUG_BUILD_DIR}/gcc/xgcc -B${__DEBUG_BUILD_DIR}/gcc"
alias xg++-debug="${__DEBUG_BUILD_DIR}/gcc/xg++ -B${__DEBUG_BUILD_DIR}/gcc"
alias xgcc-release="${__RELEASE_BUILD_DIR}/gcc/xgcc -B${__RELEASE_BUILD_DIR}/gcc"
alias xg++-release="${__RELEASE_BUILD_DIR}/gcc/xg++ -B${__RELEASE_BUILD_DIR}/gcc"
alias xgcc-pristine="${__PRISTINE_BUILD_DIR}/gcc/xgcc -B${__PRISTINE_BUILD_DIR}/gcc"
alias xg++-pristine="${__PRISTINE_BUILD_DIR}/gcc/xg++ -B${__PRISTINE_BUILD_DIR}/gcc"
alias xgcc=xgcc-debug
alias xg++=xg++-debug

function makein() {
    if [ $# -ne 2 ] && [ $# -ne 4 ]; then
        echo "Usage:"
        echo "    makein <directory> <target> [-j jobs]"
        return 1
    fi
    bash -i -c "cd $1 \
         && make -k -j ${__DEFAULT_JOB_COUNT} $2 $3 $4 \
         && ${__GCC_SRC_PRISTINE_DIR}/contrib/test_summary > test_summary.output"
}

function clean() {
    case $1 in
        debug)
            local dir=${__DEBUG_BUILD_DIR} ;;
        release)
            local dir=${__RELEASE_BUILD_DIR} ;;
        pristine)
            local dir=${__PRISTINE_BUILD_DIR} ;;
        *)
            echo "Usage:"
            echo "    clean <debug|release|pristine>"
            return 1 ;;
    esac

    bash -c "cd ${dir} && rm -rf *"
}

function check() {
    case $1 in
        debug)
            local dir=${__DEBUG_BUILD_DIR} ;;
        release)
            local dir=${__RELEASE_BUILD_DIR} ;;
        pristine)
            local dir=${__PRISTINE_BUILD_DIR} ;;
        *)
            echo "Usage:"
            echo "    check <debug|release|pristine> [-j]"
            return 1 ;;
    esac
    shift

    bash -c "cd ${dir} && make -j ${__DEFAULT_JOB_COUNT} -k $@ check"
    bash -c "cd ${dir} && ${__GCC_SRC_PRISTINE_DIR}/contrib/test_summary > test_summary.output"
}

function build() {
    case $1 in
        debug)
            local build_dir=${__DEBUG_BUILD_DIR} ;;
        release)
            local build_dir=${__RELEASE_BUILD_DIR} ;;
        pristine)
            local build_dir=${__PRISTINE_BUILD_DIR} ;;
        *)
            echo "Usage:"
            echo "    build <debug|release|pristine> [-j]"
            return 1 ;;
    esac
    shift

    bash -c "cd ${build_dir} && make -j ${__DEFAULT_JOB_COUNT} $@" \
        && echo -e "\nbuild finished(${build_dir}) time: $(date '+%F %T')"
}

function config() {
    case "$1" in
        debug)
            local build_dir=${__DEBUG_BUILD_DIR}
            local src_dir=${__GCC_SRC_DIR}
            local debug_flags=${__DEBUG_FLAGS}
            local bootstrap="--disable-bootstrap" ;;
        release)
            local build_dir=${__RELEASE_BUILD_DIR}
            local src_dir=${__GCC_SRC_DIR} ;;
        pristine)
            local build_dir=${__PRISTINE_BUILD_DIR}
            local src_dir=${__GCC_SRC_PRISTINE_DIR} ;;
        *)
            echo "Usage:"
            echo "    config <debug|release|pristine>"
            return 1 ;;
    esac
    shift

    if ! [ -z "$(ls -A ${build_dir})" ]; then
        echo "Build directory (${build_dir}) is not empty"
        return 2
    fi

    bash -c "cd ${build_dir} && \
        ${debug_flags} ${src_dir}/configure \
        --enable-languages=all \
        --with-cpu=power9      \
        --disable-multilib     \
        --with-long-double-128 \
        ${bootstrap} --prefix=/tmp/gcc-tmpi"
}

# CFLAGS="-O0 -g3 -fno-inline" CXXFLAGS="-O0 -g3 -fno-inline" CFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" CFLAGS_FOR_TARGET="-O0 -g3 -fno-inline" CXXFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" CXXFLAGS_FOR_TARGET="-O0 -g3 -fno-inline" \
#       ${__GCC_SRC_PRISTINE_DIR}/configure --enable-languages=all --with-cpu=power9 --disable-multilib --with-long-double-128 --prefix=/tmp/gcc-tmpi
