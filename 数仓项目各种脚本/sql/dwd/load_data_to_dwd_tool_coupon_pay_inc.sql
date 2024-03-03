use ${app};
insert overwrite table dwd_tool_coupon_pay_inc partition(dt='${do_date}')
select
    data.id,
    data.coupon_id,
    data.user_id,
    data.order_id,
    date_format(data.used_time,'yyyy-MM-dd') date_id,
    data.used_time
from ods_coupon_use_inc
where dt='${do_date}'
and type='update'
and array_contains(map_keys(old),'used_time');