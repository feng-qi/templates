#!/usr/bin/env bash

set -o errexit                  # set -e, exit on non-zero status


COLR_RED='\033[0;31m'
COLR_GREEN='\033[0;32m'
COLR_NC='\033[0m' # No Color

WARN='\033[0;31m[WARN]\033[0m'
INFO='\033[0;32m[WARN]\033[0m'


#-------------- sort -------------------------
sort file                          # 排序文件
sort -r file                       # 反向排序（降序）
sort -n file                       # 使用数字而不是字符串进行比较
sort -t: -k 3n /etc/passwd         # 按 passwd 文件的第三列进行排序
sort -u file                       # 去重排序


#-------------- redirection -------------------------
n>&                                # 将标准输出 dup/合并 到文件描述符 n
n<&                                # 将标准输入 dump/合并 定向为描述符 n
n>&m                               # 文件描述符 n 被作为描述符 m 的副本，输出用
n<&m                               # 文件描述符 n 被作为描述符 m 的副本，输入用
&>file                             # 将标准输出和标准错误重定向到文件
<&-                                # 关闭标准输入
>&-                                # 关闭标准输出
n>&-                               # 关闭作为输出的文件描述符 n
n<&-                               # 关闭作为输入的文件描述符 n
diff <(cmd1) <(cmd2)               # 比较两个命令的输出


#-------------- condition -------------------------
# 复杂条件判断，注意 || 和 && 是完全兼容 POSIX 的推荐写法
if [ $x -gt 10 ] && [ $x -lt 20 ]; then
    echo "yes, between 10 and 20"
fi


#-------------- function -------------------------
function myfunc() {
    # $1 代表第一个参数，$N 代表第 N 个参数
    # $# 代表参数个数
    # $0 代表被调用者自身的名字
    # $@ 代表所有参数，类型是个数组，想传递所有参数给其他命令用 cmd "$@"
    # $* 空格链接起来的所有参数，类型是字符串
    {shell commands ...}
}

# useful functions
command_exists () {
    type "$1" &> /dev/null ;
}

package_installed () {
    dpkg -s "$1" &> /dev/null ;
    # dpkg-query -l "$1" &>/dev/null ;
}


#-------------- loop & switch -------------------------
# while
while [ $# -gt 0 ]; do
    case "$1" in
        base)
            install_utils
            shift
            ;;
        *)
            echo -e "${WARN} Unrecognized Argument: ${COLR_RED}$1${COLR_NC}"
            exit 1
            ;;
    esac
done


# for
#-----
for ((n=0;n<10;n++)); do
    echo "hello world $n"
done

#-----
for i in {1..10}; do
    echo "hello world $i"
done

#-----
for pkg in ${pkgs[@]}; do
    if ! package_installed ${pkg} ; then
        echo -e "${INFO} ${COLR_GREEN}${pkg}${COLR_NC} installing"
        sudo apt install -y ${pkg}
        echo -e "${INFO} ${COLR_GREEN}${pkg}${COLR_NC} installed"
    else
        echo -e "${WARN} ${COLR_RED}${pkg}${COLR_NC} already exists! Skipped!"
    fi
done
