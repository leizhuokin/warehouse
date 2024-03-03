#!/bin/bash
#用于初始化数据仓库SQL
app='commerce'
hive_host=node01
JOB_SQL=${JOB_HOME}/sql
function create_table() {
    path="${JOB_SQL}/init/$1.sql"
    echo "${path}"
    ssh "${hive_host}" "hive --hivevar app=${app} -f ${path}"
}
case $1 in
"ods")
create_table ods
;;
"dim")
create_table dim
;;
"dwd")
create_table dwd
;;
"dws")
create_table dws
;;
"ads")
create_table ads
;;
"all")
create_table ods
create_table dim
create_table dwd
create_table dws
create_table ads
;;
esac