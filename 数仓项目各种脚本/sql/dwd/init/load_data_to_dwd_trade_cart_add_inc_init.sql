-- 加载数据【首日/非首日】
use ${app};
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table dwd_trade_cart_add_inc partition (dt)
select
    c.id,
    c.user_id,
    c.sku_id,
    c.dt as date_id,
    c.create_time,
    c.source_id,
    c.source_type as source_type_code,
    dic.dic_name,
    c.sku_num,
    c.dt
    from
    (select
    data.id as id,
    data.user_id as user_id,
    data.sku_id as sku_id,
    data.create_time as create_time,
    data.source_id as source_id,
    data.source_type,
    data.sku_num,
    date_format(data.create_time,'yyyy-MM-dd') dt

    from ods_cart_info_inc
where dt='${do_date}'
and type = 'bootstrap-insert') c
left join (
    select
        dic_code,
        dic_name
        from ods_base_dic_full
             where dt='${do_date}'
             and parent_code = '24'
    ) dic
on c.source_type = dic.dic_code;