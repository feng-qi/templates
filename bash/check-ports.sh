# $1: IP
# $2: port
function check_port() {
    if [ $# -ne 2 ]; then
        echo 'check_port needs 2 args'
        exit 1
    fi
    nc -zv $1 $2
}
