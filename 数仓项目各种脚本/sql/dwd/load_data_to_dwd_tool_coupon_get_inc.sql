use ${app};

-- 工具域-优惠券领取事务-事实表
insert overwrite table dwd_tool_coupon_get_inc partition (dt='${do_date}')
select
    data.id,
    data.coupon_id,
    data.user_id,
    date_format(data.get_time,'yyyy-MM-dd') date_id,
    data.get_time,
    date_format(data.get_time,'yyyy-MM-dd') date_id
from ods_coupon_use_inc
where dt='${do_date}'
and type='insert';