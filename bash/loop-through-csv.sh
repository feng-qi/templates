#!/bin/bash

# sed 1d /home/qifen01/github/renaissance.out.csv | while IFS=, read -r benchmark_name nanos col3
# do
#     echo "I got: $benchmark_name | $nanos"
# done


renaissance_data () {
    local file=out.csv
    local data

    # local csv=$(sed 1d ${file})
    while IFS=, read -r name score col3; do
        data="${data}renaissance/${name},$score,nanos\n"
    done <<< $(cat /home/qifen01/github/renaissance.out.csv)
    # done <<< ${csv}

    echo -n -e "${data}"
}

renaissance_data
