#!/bin/bash

filename="$1"
redis_key="$2"
while read -r line; do
    uids="${uids} $line"
done < "$filename"

host="-h 127.0.0.1"
port="-p 6379"
auth="-a $redis_password"

command="rpush ${redis_key} ${uids}"

redis-cli ${auth} ${host} ${port} ${command}
