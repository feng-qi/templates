__GCC_SRC_DIR=$HOME/repos/gcc-git
__RELEASE_BUILD_DIR=$HOME/builds/master
__DEBUG_BUILD_DIR=$HOME/builds/debug
__RELEASE_EXE_DIR=$__RELEASE_BUILD_DIR/gcc
__DEBUG_EXE_DIR=$__DEBUG_BUILD_DIR/gcc

alias xgcc="$__RELEASE_EXE_DIR/xgcc -B$__RELEASE_EXE_DIR"
alias xg++="$__RELEASE_EXE_DIR/xg++ -B$__RELEASE_EXE_DIR"
alias xgcc-debug="$__DEBUG_EXE_DIR/xgcc -B$__DEBUG_EXE_DIR"
alias xg++-debug="$__DEBUG_EXE_DIR/xg++ -B$__DEBUG_EXE_DIR"

alias mkrelease="make -C $__RELEASE_BUILD_DIR -j 30"

__DEBUG_FLAGS='CFLAGS="-O0 -g3 -fno-inline"             \
               CXXFLAGS="-O0 -g3 -fno-inline"           \
               CFLAGS_FOR_BUILD="-O0 -g3 -fno-inline"   \
               CFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"  \
               CXXFLAGS_FOR_BUILD="-O0 -g3 -fno-inline" \
               CXXFLAGS_FOR_TARGET="-O0 -g3 -fno-inline"'

alias mkdebug="make -C ${__DEBUG_BUILD_DIR}   -j 30   ${__DEBUG_FLAGS}"

alias cfggcc.="${__DEBUG_FLAGS} $__GCC_SRC_DIR/configure \
    --enable-languages=all \
    --with-cpu=power9      \
    --disable-multilab     \
    --with-long-double-128 \
    --prefix=/tmp/gcc-tmpi \
    --disable-bootstrap"
