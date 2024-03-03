#!/bin/bash
source /etc/profile
DATAX_HOME=${DATAX_HOME}
JOB_DATAX_CONF=${JOB_HOME}/conf/datax
HADOOP_HOME=${HADOOP_HOME}

hadoop=$HADOOP_HOME/bin/hadoop
# 如果传入日期则do_date等于传入的日期，否则等于前一天日期
if [ -n "$2" ] ;then
    do_date=$2
else
    do_date=$(date -d "-1 day" +%F)
fi

#处理目标路径，此处的处理逻辑是，如果目标路径不存在，则创建；若存在，则清空，目的是保证同步任务可重复执行
handle_target() {
  $hadoop fs -test -e "$1"
  if [[ $? -eq 1 ]]; then
    echo "路径$1不存在，正在创建......"
    $hadoop fs -mkdir -p "$1"
  else
    echo "路径$1已经存在"
    fs_count=$($hadoop fs -count "$1")
    content_size=$(echo "$fs_count" | awk '{print $3}')
    if [[ $content_size -eq 0 ]]; then
      echo "路径$1为空"
    else
      echo "路径$1不为空，正在清空......"
      $hadoop fs -rm -r -f "$1"/*
    fi
  fi
}

#数据同步
import_data() {
  datax_config=$1
  target_dir=$2

  handle_target "$target_dir"
  python "${DATAX_HOME}/bin/datax.py" -p"-Dtarget=${target_dir}" ${datax_config}
}

case $1 in
"activity_info")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.activity_info.json /dw/commerce/source/db/full_full_activity_info/"${do_date}"
  ;;
"activity_rule")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.activity_rule.json /dw/commerce/source/db/full_activity_rule/"${do_date}"
  ;;
"base_category1")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_category1.json /dw/commerce/source/db/full_base_category1/"${do_date}"
  ;;
"base_category2")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_category2.json /dw/commerce/source/db/full_base_category2/"${do_date}"
  ;;
"base_category3")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_category3.json /dw/commerce/source/db/full_base_category3/"${do_date}"
  ;;
"base_dic")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_dic.json /dw/commerce/source/db/full_base_dic/"${do_date}"
  ;;
"base_province")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_province.json /dw/commerce/source/db/full_base_province/"${do_date}"
  ;;
"base_region")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_region.json /dw/commerce/source/db/full_base_region/"${do_date}"
  ;;
"base_trademark")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_trademark.json /dw/commerce/source/db/full_base_trademark/"${do_date}"
  ;;
"cart_info")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.cart_info.json /dw/commerce/source/db/full_cart_info/"${do_date}"
  ;;
"coupon_info")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.coupon_info.json /dw/commerce/source/db/full_coupon_info/"${do_date}"
  ;;
"sku_attr_value")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.sku_attr_value.json /dw/commerce/source/db/full_sku_attr_value/"${do_date}"
  ;;
"sku_info")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.sku_info.json /dw/commerce/source/db/full_sku_info/"${do_date}"
  ;;
"sku_sale_attr_value")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.sku_sale_attr_value.json /dw/commerce/source/db/full_sku_sale_attr_value/"${do_date}"
  ;;
"spu_info")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.spu_info.json /dw/commerce/source/db/full_spu_info/"${do_date}"
  ;;
"all")
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.activity_info.json /dw/commerce/source/db/full_activity_info/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.activity_rule.json /dw/commerce/source/db/full_activity_rule/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_category1.json /dw/commerce/source/db/full_base_category1/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_category2.json /dw/commerce/source/db/full_base_category2/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_category3.json /dw/commerce/source/db/full_base_category3/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_dic.json /dw/commerce/source/db/full_base_dic/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_province.json /dw/commerce/source/db/full_base_province/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_region.json /dw/commerce/source/db/full_base_region/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.base_trademark.json /dw/commerce/source/db/full_base_trademark/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.cart_info.json /dw/commerce/source/db/full_cart_info/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.coupon_info.json /dw/commerce/source/db/full_coupon_info/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.sku_attr_value.json /dw/commerce/source/db/full_sku_attr_value/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.sku_info.json /dw/commerce/source/db/full_sku_info/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.sku_sale_attr_value.json /dw/commerce/source/db/full_sku_sale_attr_value/"${do_date}"
  import_data "${JOB_DATAX_CONF}"/full/full_commerce.spu_info.json /dw/commerce/source/db/full_spu_info/"${do_date}"
  ;;
* )
echo "Usage: $0 {all|tableName} [date]"
;;
esac
