use ${app};

-- 非首日
insert overwrite table dwd_trade_pay_suc_detail_inc partition(dt='${do_date}')
select
    o.id,
    date_format(p.callback_time, 'yyyy-MM-dd') date_id,
    p.user_id,
    o.sku_id,
    o.sku_num,
    o.order_id,
    oi.provice_id,
    oda.activity_id,
    oda.activity_rule_id,
    odc.coupon_id,

    p.callback_time,
    o.source_id,
    o.source_type as source_type_code,
    order_dic.dic_name as source_type_name,
    pay_dic.dic_code as payment_type_code,
    pay_dic.dic_name as payment_type_name,
    o.split_payment_amount,
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
    data.split_total_amount as split_payment_amount,
    data.split_activity_amount,
    data.split_coupon_amount,
    data.sku_num * data.order_price split_original_amount
    from ods_order_detail_inc
where (dt = '${do_date}' or dt = date_add('${do_date}',-1))
and (type = 'insert' or type='boostrap-insert')) o

join (
    select
        data.order_id,
        data.user_id,
        data.payment_type,
        data.callback_time
    from ods_payment_info_inc
    where dt = '${do_date}'
      and type='update'
      and array_contains(map_keys(old), 'payment_status')
      and data.payment_status = '1602'
) p
on o.order_id = p.order_id

left join (
    select
        data.id,
        data.provice_id
    from ods_order_info_inc
    where (dt = '${do_date}' or dt = date_add('${do_date}',-1))
    and (type = 'insert' or type='boostrap-insert')
) oi
on o.order_id = oi.id

left join (
    select
        data.order_detail_id,
        data.activity_id,
        data.activity_rule_id
    from ods_order_detail_activity_inc
    where (dt = '${do_date}' or dt = date_add('${do_date}',-1))
    and (type = 'insert' or type='boostrap-insert')
) oda

on o.id = oda.order_detail_id

left join (
    select
        data.order_detail_id,
        data.coupon_id
    from ods_order_detail_coupon_inc
    where (dt = '${do_date}' or dt = date_add('${do_date}',-1))
    and (type = 'insert' or type='boostrap-insert')
) odc

on o.id = odc.order_detail_id

left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='24'
) order_dic
on o.source_type = order_dic.dic_code
left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='11'
) pay_dic

on p.payment_type = pay_dic.dic_code;