use ${app};
set hive.exec.dynamic.partition.mode=nonstrict;
-- 工具域优惠券使用支付事实表
insert overwrite table dwd_tool_coupon_pay_inc partition(dt)
select
    data.id,
    data.coupon_id,
    data.user_id,
    data.order_id,
    date_format(data.used_time,'yyyy-MM-dd') date_id,
    data.used_time,
    date_format(data.used_time,'yyyy-MM-dd')
from ods_coupon_use_inc
where dt='${do_date}'
and type='bootstrap-insert'
and data.used_time is not null;