#!/bin/bash
CURRENT_DIR=$(cd $(dirname $0) || exit; pwd)
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t activity_info
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t activity_rule
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_category1
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_category2
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_category3
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_dic
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_province
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_region
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t base_trademark
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t cart_info
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t coupon_info
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t sku_attr_value
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t sku_info
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t sku_sale_attr_value
python "${CURRENT_DIR}"/generate_mysql2hdfs_json.py -d commerce -t spu_info