#!/usr/bin/env bash

set -o errexit                  # set -e, exit on non-zero status


COLR_RED='\033[0;31m'
COLR_GREEN='\033[0;32m'
COLR_NC='\033[0m' # No Color

WARN='\033[0;31m[WARN]\033[0m'
INFO='\033[0;32m[INFO]\033[0m'


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


#-------------- assignment -------------------------
# Leading colon, see https://www.gnu.org/software/bash/manual/bashref.html#Bourne-Shell-Builtins
# Substitution: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
#     ${}   : Parameter Expansion(Substitution)
#     $()   : Command Substitution
#     $(()) : Arithmetic Expansion
: ${CC="gcc"}                   # assign if CXX is ""
: ${CXX:="g++"}                 # assign if CXX is "" or unset


#-------------- condition -------------------------
# 复杂条件判断，注意 || 和 && 是完全兼容 POSIX 的推荐写法
if [ $x -gt 10 ] && [ $x -lt 20 ]; then
    echo "yes, between 10 and 20"
fi

if [ "$1" == "--dry-run" ]; then
    dry_run=true
    shift
fi

local file=$(realpath $1)
if [ -z $file ]; then
    return 1
fi
local filename=$(basename $file)
local filename_no_ext=${filename%.*}
if [ -z $filename_no_ext ]; then
    echo "Can't parse filename"
    return 1
fi


#-------------- arithmetic -------------------------
# let
let a=5+4
let "a = 5 + 4"
let a++
let "a = 4 * 5"
let "a = $1 + 30"

# expr
expr 5 + 4
expr "5 + 4"
expr 5+4
expr 5 \* $1
expr 11 % 2
a=$( expr 10 - 3 )

# Double Parentheses
a=$(( 4 + 5 ))
a=$((3+5))
b=$(( a + 3 ))
b=$(( $a + 4 ))
echo $b # 12
(( b++ ))
echo $b # 13
(( b += 3 ))
echo $b # 16
a=$(( 4 * 5 ))
echo $a # 20


#-------------- function -------------------------
function myfunc() {
    # $1 代表第一个参数，$N 代表第 N 个参数
    # $# 代表参数个数
    # $0 代表被调用者自身的名字
    # $@ 代表所有参数，类型是个数组，想传递所有参数给其他命令用 cmd "$@"
    # $* 空格链接起来的所有参数，类型是字符串
    local x=$1
    local y=$2
    {shell commands ...}
}

# call a function
myfunc arg1 arg2

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


# for
#-----
for ((n=0;n<10;n++)); do
    echo "hello world $n"
done

#-----
for i in {1..99..2}; do
    if [ $(($i % 2)) -eq 1 ]; then
        echo $i
    fi
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

# select
#-------
select yn in "Yes" "No"; do
    case $yn in
        Yes) echo Yess; break;;
        No) echo Noo; break;;
    esac
done

# read
#-------
read -p "Do you wish to install this program?(y/n) " yn
case $yn in
    [Yy]*) echo Yes ;;
    [Nn]*) echo No  ;;
    *) echo "Please answer yes or no." ;;
esac
