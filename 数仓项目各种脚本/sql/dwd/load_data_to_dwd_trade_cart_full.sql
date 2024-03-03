use ${app};
insert overwrite table dwd_trade_cart_full partition(dt='${do_date}')
select
    id,
    user_id,
    sku_id,
    sku_name,
    sku_num
from ods_cart_info_full
where dt='${do_date}'
and is_ordered = '0';