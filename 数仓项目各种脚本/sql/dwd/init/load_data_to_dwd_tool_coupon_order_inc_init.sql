use ${app};
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dwd_tool_coupon_order_inc partition (dt)
select
    data.id,
    data.coupon_id,
    data.user_id,
    date_format(data.using_time,'yyyy-MM-dd') date_id,
    data.order_id,
    data.using_time as order_time,
    date_format(data.using_time,'yyyy-MM-dd') date_id
from ods_coupon_use_inc
where dt='${do_date}'
and type='bootstrap-insert'
and data.using_time is not null;