#!/bin/bash

# sed 1d /home/qifen01/github/renaissance.out.csv | while IFS=, read -r benchmark_name nanos col3
# do
#     echo "I got: $benchmark_name | $nanos"
# done


# renaissance_data () {
#     # local file=/home/qifen01/test/ascii-table.txt
#     local data

#     # local csv=$(sed 1d ${file})
#     while read -r name mode cnt score discard1 error units; do
#         # data="${data}renaissance/${name},$score,nanos\n"
#         data="${data}renaissance/${name} \t ${mode} \t ${cnt} \t $score \t ${discard1} \t ${error} \t ${units}\n"
#     done <<< $(cat /home/qifen01/test/ascii-table.txt)
#     # done <<< ${csv}

#     echo -n -e "${data}"
# }

# renaissance_data

renaissance_jmh_data(){
    local file=/home/qifen01/test/renaissance-jmh/jmh-result.txt.backup
    local renaissance_version="0.10.0"
    local data

    while read -r name mode cnt score discard1 error unit; do
        if [ ${mode} = "thrpt" ]; then
            local prefer_large=1
        else
            local prefer_large=0
        fi

        data="${data}renaissance/${name},${renaissance_version},${score},${unit},$prefer_large,${error}\n"
    done <<< $(sed -e '1d' -e '/dummy/d' ${file})

    echo -e -n "$data"
}

renaissance_jmh_data

test() {
    local abc='abc'
    # echo ${#abc}

    local SZ=252
    if [[ ${#abc} -gt ${SZ} ]]; then
        echo 'greater than'
    else
        echo 'less than'
    fi
}

# test
