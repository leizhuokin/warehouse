#!/bin/bash
#加载数据到ODS层：业务数据，每日执行一次
do_date=''
app='commerce'
if [ "$2" == "" ];then
  do_date=$(date -d "-1 day" +%F)
else
  do_date=$2
fi
# aaa all 2022-11-13
function load_data() {
    sql=''
    for i in $*; do
      #ods_cart_info_full
      ## 1. 判断路径是否存在【原始路径】
      #获取表名
      old=$i
      s=${old:4} #cart_info_full
      if [ "${old:0-4}" == "full" ]; then
          s="full_${s%%_full}"
      else
        s="inc_${s%%_inc}"
      fi
      in_path="/dw/commerce/source/db/${s}/${do_date}"
      hadoop fs -test -e "${in_path}"
      if [ $? == 0 ];then
        echo "------ ods: load db ${i} data on ${do_date} to hive ------"
        sql=${sql}"load data inpath '${in_path}' overwrite into table ${app}.$i partition(dt='${do_date}');"
      fi
    done
    echo "${sql}"
    hive -e "${sql}"
}

case $1 in
"ods_activity_info_full")
load_data ods_activity_info_full
;;
"ods_activity_rule_full")
load_data ods_activity_rule_full
;;
"ods_base_category1_full")
load_data ods_base_category1_full
;;
"ods_base_category2_full")
load_data ods_base_category2_full
;;
"ods_base_category3_full")
load_data ods_base_category3_full
;;
"ods_base_dic_full")
load_data ods_base_dic_full
;;
"ods_base_province_full")
load_data ods_base_province_full
;;
"ods_base_region_full")
load_data ods_base_region_full
;;
"ods_base_trademark_full")
load_data ods_base_trademark_full
;;
"ods_cart_info_full")
load_data ods_cart_info_full
;;
"ods_cart_info_inc")
load_data ods_cart_info_inc
;;
"ods_comment_info_inc")
load_data ods_comment_info_inc
;;
"ods_coupon_info_full")
load_data ods_coupon_info_full
;;
"ods_coupon_use_inc")
load_data ods_coupon_use_inc
;;
"ods_favor_info_inc")
load_data ods_favor_info_inc
;;
"ods_log_inc")
load_data ods_log_inc
;;
"ods_order_detail_activity_inc")
load_data ods_order_detail_activity_inc
;;
"ods_order_detail_coupon_inc")
load_data ods_order_detail_coupon_inc
;;
"ods_order_detail_inc")
load_data ods_order_detail_inc
;;
"ods_order_info_inc")
load_data ods_order_info_inc
;;
"ods_order_refund_info_inc")
load_data ods_order_refund_info_inc
;;
"ods_order_status_log_inc")
load_data ods_order_status_log_inc
;;
"ods_payment_info_inc")
load_data ods_payment_info_inc
;;
"ods_refund_payment_inc")
load_data ods_refund_payment_inc
;;
"ods_sku_attr_value_full")
load_data ods_sku_attr_value_full
;;
"ods_sku_info_full")
load_data ods_sku_info_full
;;
"ods_sku_sale_attr_value_full")
load_data ods_sku_sale_attr_value_full
;;
"ods_spu_info_full")
load_data ods_spu_info_full
;;
"ods_user_info_inc")
load_data ods_user_info_inc
;;
"all")
load_data "ods_activity_info_full" "ods_activity_rule_full" "ods_base_category1_full" "ods_base_category2_full" "ods_base_category3_full" "ods_base_dic_full" "ods_base_province_full" "ods_base_region_full" "ods_base_trademark_full" "ods_cart_info_full" "ods_cart_info_inc" "ods_comment_info_inc" "ods_coupon_info_full" "ods_coupon_use_inc" "ods_favor_info_inc" "ods_log_inc" "ods_order_detail_activity_inc" "ods_order_detail_coupon_inc" "ods_order_detail_inc" "ods_order_info_inc" "ods_order_refund_info_inc" "ods_order_status_log_inc" "ods_payment_info_inc" "ods_refund_payment_inc" "ods_sku_attr_value_full" "ods_sku_info_full" "ods_sku_sale_attr_value_full" "ods_spu_info_full" "ods_user_info_inc"
;;
* )
echo "Usage: $0 {all|tableName} [date]"
;;
esac