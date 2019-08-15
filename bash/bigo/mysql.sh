#!/bin/bash

id=$1
table_name=$2
time_stamp=$(date +%s)

mysql_count="select count(1) from ${table_name};"
mysql_select_max="select max(id) from ${table_name};"
mysql_insert_new="insert into ${table_name} \
  (id, appid, title, msg, content, release_time, expired_time) \
  values ($id, '60', 'title', 'message', 'content', '$time_stamp', '$((time_stamp+10800))');"

mysql_command=mysql_select_max
echo "$mysql_command"

output=$(mysql --host="127.0.0.1"     \
               --port=8825            \
               --user="$user"         \
               --password="$password" \
               --silent               \
               --skip-column-names    \
               --database="mydb"    \
               --execute="${mysql_command}")
next_id=$((${output} + 1))
