#!/bin/bash
hive_host=node01
app=commerce
JOB_SQL=${JOB_HOME}/sql
## 每日数据
do_date=$2
if [ "${do_date}" == "" ];then
  do_date=$(date -d "-1 day" +%F)
fi

case $1 in
"dim_sku_full")
    ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/dim/load_data_to_dim_sku_full.sql"
;;
"dim_coupon_full")
    ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/dim/load_data_to_dim_coupon_full.sql"
;;
"dim_activity_full")
    ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/dim/load_data_to_dim_activity_full.sql"
;;
"dim_province_full")
    ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/dim/load_data_to_dim_province_full.sql"
;;
"dim_user_zip")
    ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/dim/load_data_to_dim_user_zip_init.sql"
;;

"all")
    ssh "${hive_host}" "hive --hivevar app=${app} --hivevar do_date=${do_date} -f ${JOB_SQL}/dim/all.sql"
;;
esac