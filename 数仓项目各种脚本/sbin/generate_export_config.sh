#!/bin/bash
source /etc/profile
JOB_HOME=${JOB_HOME}

python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_traffic_stats_by_channel
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_traffic_page_path
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_user_change
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_user_retention
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_user_stats
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_user_action
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_user_new_buyer_stats
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_good_repeat_purchase_by_tm
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_good_trade_stats_by_tm
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_good_trade_stats_by_cate
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_good_cart_num_top_by_cate
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_trade_stats
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_trade_order_by_province
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_coupon_subsidy_stats
python "${JOB_HOME}/sbin/generate_export_config.py" -d commerce_report -t ads_activity_subsidy_stats