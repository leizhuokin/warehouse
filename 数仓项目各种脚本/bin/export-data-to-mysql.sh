#! /bin/bash
source /etc/profile
DATAX_HOME=${DATAX_HOME}
JOB_DATAX_CONF_EXPORT=${JOB_HOME}/conf/datax/export
HADOOP_HOME=${HADOOP_HOME}
hadoop=$HADOOP_HOME/bin/hadoop
#DataX导出路径不允许存在空文件，该函数作用为清理空文件
handle_export_path(){
  target_file=$1
  for i in `hadoop fs -ls -R $target_file | awk '{print $8}'`; do
    hadoop fs -test -z $i
    if [[ $? -eq 0 ]]; then
      echo "$i文件大小为0，正在删除"
      hadoop fs -rm -r -f $i
    fi
  done
}
#数据导出
export_data() {
  datax_config=$1
  target=$2
  hadoop fs -test -e target
  if [[ $? -eq 0 ]]
  then
    handle_export_path target
    file_count=$(hadoop fs -ls target | wc -l)
    if [ $file_count -gt 0 ]
    then
      set -e;
      $DATAX_HOME/bin/datax.py -p"-Dtarget=$target" $datax_config
      set +e;
    else 
      echo "target 目录为空，跳过~"
    fi
  else
    echo "路径 $export_dir 不存在，跳过~"
  fi
}

tables=(ads_traffic_stats_by_channel ads_traffic_page_path ads_user_change ads_user_retention ads_user_stats ads_user_action ads_user_new_buyer_stats ads_good_repeat_purchase_by_tm ads_good_trade_stats_by_tm ads_good_trade_stats_by_cate ads_good_cart_num_top_by_cate ads_trade_stats ads_trade_order_by_province ads_coupon_subsidy_stats ads_activity_subsidy_stats)
table=$1

case $1 in
"all")
  for i in "${tables[@]}"; do
    echo --------- export report data "${i}" from hdfs to mysql----------
    export_data ${JOB_DATAX_CONF_EXPORT}/commerce_report.${i}.json /dw/commerce/ads/${i}
  done
  ;;
esac