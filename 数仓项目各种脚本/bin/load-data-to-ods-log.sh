#!/bin/bash
#加载数据到ODS层：日志数据，每日执行一次
app='commerce'
do_date=''
if [ "$1" == "" ];then
  do_date=$(date -d "-1 day" +%F)
else
  do_date=$1
fi
echo "-----------------ods: load log data on ${do_date} to hive-------------------"
sql="load data inpath '/dw/commerce/source/log/${do_date}' into table ${app}.ods_log_inc partition (dt = '${do_date}');"
hive -e "${sql}"