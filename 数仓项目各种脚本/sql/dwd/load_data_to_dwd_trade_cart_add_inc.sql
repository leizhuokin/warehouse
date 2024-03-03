-- 加载非首日
use ${app};
insert overwrite table dwd_trade_cart_add_inc partition(dt='${do_date}')
select
    c.id,
    c.user_id,
    c.sku_id,
    c.date_id,
    c.create_time,
    c.source_id,
    c.source_type as source_type_code,
    dic.dic_name,
    c.sku_num
    from
(select
    data.id id,
    data.user_id user_id,
    data.sku_id as sku_id,
    date_format(from_utc_timestamp(ts * 1000, 'GMT+8'),'yyyy-MM-dd') date_id,
    date_format(from_utc_timestamp(ts * 1000, 'GMT+8'),'yyyy-MM-dd HH:mm:ss') create_time,
    data.source_id as source_id,
    data.source_type,
    data.sku_num
    from ods_cart_info_inc
where dt='${do_date}'
and (type = 'insert' or (type = 'update' and old['sku_num'] is not null and data.sku_num > cast(old['sku_num'] as int)))) c
left join (
    select
        dic_code,
        dic_name
        from ods_base_dic_full
             where dt='${do_date}'
             and parent_code = '24'
    ) dic
on c.source_type = dic.dic_code;