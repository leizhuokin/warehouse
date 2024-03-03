#!/bin/bash
hive_host=node01
app=commerce
JOB_SQL=${JOB_HOME}/sql/dwd
table=$1
tables=(dwd_trade_cart_add_inc dwd_trade_order_detail_inc dwd_trade_order_cancel_detail_inc dwd_trade_pay_suc_detail_inc)
## 每日数据
do_date=$2
if [ "${do_date}" == "" ];then
  do_date=$(date -d "-1 day" +%F)
fi

function load_data() {
   ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/load_data_to_$1.sql"
}
function load_all_data() {
   ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/all.sql"
}

# $1 数组变量 $2 是否包含这个元素 0,1
#function contains() {
#    arr=$1
#    [[ ${arr[@]/$2/} != ${arr[@]} ]]; echo $?
#}

case ${table} in
"all")
load_all_data
;;
* )
  load_data "${table}"
;;
esac