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
            local build_type="debug"
            local dir=${__DEBUG_BUILD_DIR} ;;
        release)
            local build_type="release"
            local dir=${__RELEASE_BUILD_DIR} ;;
        pristine)
            local build_type="pristine"
            local dir=${__PRISTINE_BUILD_DIR} ;;
        *)
            echo "Usage:"
            echo "    build <debug|release|pristine> [-j]"
            return 1 ;;
    esac
    shift

    bash -c "cd ${dir} && make -j ${__DEFAULT_JOB_COUNT} $@" \
        && echo -e "\n${build_type} build finish time: $(date '+%F %T')"
}

function config() {
    case "$1" in
        debug)
            local src_dir=${__GCC_SRC_DIR}
            local debug_flags=${__DEBUG_FLAGS}
            local bootstrap="--disable-bootstrap" ;;
        release)
            local src_dir=${__GCC_SRC_DIR} ;;
        pristine)
            local src_dir=${__GCC_SRC_PRISTINE_DIR} ;;
        *)
            echo "Usage:"
            echo "    config <debug|release|pristine>"
            return 1 ;;
    esac
    shift

    bash -c "${debug_flags} ${src_dir}/configure \
        --enable-languages=all \
        --with-cpu=power9      \
        --disable-multilab     \
        --with-long-double-128 \
        ${bootstrap} --prefix=/tmp/gcc-tmpi"
}

# CFLAGS="-O0 -g3 -fno-inline" CXXFLAGS="-O0 -g3 -fno-inline" CFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" CFLAGS_FOR_TARGET="-O0 -g3 -fno-inline" CXXFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" CXXFLAGS_FOR_TARGET="-O0 -g3 -fno-inline" \
#       ${__GCC_SRC_PRISTINE_DIR}/configure --enable-languages=all --with-cpu=power9 --disable-multilab --with-long-double-128 --prefix=/tmp/gcc-tmpi
