#!/bin/bash
source /etc/profile
#默认值
start_date=2022-10-25
end_date=2022-11-13
if [ "$1" != "" ];then
  start_date=$1
fi
if [ "$2" != "" ];then
  end_date=$2
fi
start_date=$(date -d "${start_date}" +"%Y%m%d")
end_date=$(date -d "${end_date}" +"%Y%m%d")
cur_date=$start_date
date_list=""
while [ "${cur_date}" -le "${end_date}" ];do
  date_list="$date_list $cur_date"
  cur_date=$(date -d "${cur_date} +1 day" +"%Y%m%d")
done
for i in ${date_list}; do
  mock_date=$(date -d "${i}" +"%Y-%m-%d")
  echo "-------mock db data on ${mock_date} ---------"
  start-mock-dbs.sh "${mock_date}"
  echo "running, please wait ..."
  sleep 30s
done
echo "模拟生成${start_date}至${end_date}数据执行完毕"
