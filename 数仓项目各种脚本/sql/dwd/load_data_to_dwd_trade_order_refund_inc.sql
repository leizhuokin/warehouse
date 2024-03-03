use ${app};
insert overwrite table dwd_trade_order_refund_inc partition(dt='${do_date}')
select
    ri.id,
    user_id,
    order_id,
    sku_id,
    province_id,
    date_format(create_time,'yyyy-MM-dd') date_id,
    create_time,
    refund_type,
    type_dic.dic_name,
    refund_reason_type,
    reason_dic.dic_name,
    refund_reason_txt,
    refund_num,
    refund_amount
from
(
    select
        data.id,
        data.user_id,
        data.order_id,
        data.sku_id,
        data.refund_type,
        data.refund_num,
        data.refund_amount,
        data.refund_reason_type,
        data.refund_reason_txt,
        data.create_time
    from ods_order_refund_info_inc
    where dt='${do_date}'
    and type='insert'
)ri
left join
(
    select
        data.id,
        data.province_id
    from ods_order_info_inc
    where dt='${do_date}'
    and type='update'
    and data.order_status='1005'
    and array_contains(map_keys(old),'order_status')
)oi
on ri.order_id=oi.id
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code = '15'
)type_dic
on ri.refund_type=type_dic.dic_code
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code = '13'
)reason_dic
on ri.refund_reason_type=reason_dic.dic_code;