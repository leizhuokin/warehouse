#!/bin/bash
#load-data-to-dwd-init.sh all 2022-11-13
hive_host=node01
app=commerce
JOB_SQL=${JOB_HOME}/sql/dwd
table=$1
tables=(dwd_trade_cart_add_inc dwd_trade_order_detail_inc dwd_trade_order_cancel_detail_inc dwd_trade_pay_suc_detail_inc)
## 每日数据
do_date=$2
if [ "${do_date}" == "" ];then
  echo "必须添加初始化日期"
  exit
fi
function load_all_data() {
   ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/init/all.sql"
}
case ${table} in
"all")
load_all_data
;;
* )
  echo "目前仅支持all参数"
;;
esac