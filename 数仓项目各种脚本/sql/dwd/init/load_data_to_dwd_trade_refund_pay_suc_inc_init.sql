use ${app};
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dwd_trade_refund_pay_suc_inc partition(dt)
select
    rp.id,
    user_id,
    rp.order_id,
    rp.sku_id,
    province_id,
    payment_type,
    dic_name,
    date_format(callback_time,'yyyy-MM-dd') date_id,
    callback_time,
    refund_num,
    total_amount,
    date_format(callback_time,'yyyy-MM-dd')
from
(
    select
        data.id,
        data.order_id,
        data.sku_id,
        data.payment_type,
        data.callback_time,
        data.total_amount
    from ods_refund_payment_inc
    where dt='${do_date}'
    and type = 'bootstrap-insert'
    and data.refund_status='1602'
)rp
left join
(
    select
        data.id,
        data.user_id,
        data.province_id
    from ods_order_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)oi
on rp.order_id=oi.id
left join
(
    select
        data.order_id,
        data.sku_id,
        data.refund_num
    from ods_order_refund_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)ri
on rp.order_id=ri.order_id
and rp.sku_id=ri.sku_id
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code='11'
)dic
on rp.payment_type=dic.dic_code;