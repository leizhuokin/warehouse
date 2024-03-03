use ${app};
-- 非首日
insert overwrite table dwd_trade_order_cancel_detail_inc partition(dt='${do_date}')
select
    o.id,
    date_format(oi.cancel_time, 'yyyy-MM-dd') date_id,
    oi.user_id,
    o.sku_id,
    o.sku_num,
    o.order_id,
    oi.provice_id,
    oda.activity_id,
    oda.activity_rule_id,
    odc.coupon_id,

    oi.cancel_time,
    o.source_id,
    o.source_type as source_type_code,
    dic.dic_name as source_type_name,

    o.split_total_amount,
    o.split_activity_amount,
    o.split_coupon_amount,
    o.split_original_amount
from
(select
    data.id id,
    data.order_id,
    data.sku_id,
    data.source_id,
    data.source_type,
    data.sku_num,
    data.split_total_amount,
    data.split_activity_amount,
    data.split_coupon_amount,
    data.sku_name * data.order_price split_original_amount
    from ods_order_detail_inc
where (dt = '${do_date}' or dt = date_add('${do_date}',-1)) -- 分区
and (type = 'insert' or type = 'bootstrap-insert')
) o -- 重要

left join (
    select
        data.id,
        data.user_id,
        data.provice_id,
        data.operate_time cancel_time
    from ods_order_info_inc
    where dt = '${do_date}'
      and type='update'
      -- 1003就是订单状态中取消订单的标识
      and data.order_status='1003'
      and array_contains(map_keys(old), 'order_status')
) oi
on o.order_id = oi.id

left join (
    select
        data.order_detail_id,
        data.activity_id,
        data.activity_rule_id
    from ods_order_detail_activity_inc
    where (dt = '${do_date}' or dt = date_add('${do_date}',-1)) -- 分区
    and (type = 'insert' or type = 'bootstrap-insert')
) oda

on o.id = oda.order_detail_id

left join (
    select
        data.order_detail_id,
        data.coupon_id
    from ods_order_detail_coupon_inc
    where (dt = '${do_date}' or dt = date_add('${do_date}',-1)) -- 分区
    and (type = 'insert' or type = 'bootstrap-insert')
) odc

on o.id = odc.order_detail_id

left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='24'
) dic

on o.source_type = dic.dic_code;