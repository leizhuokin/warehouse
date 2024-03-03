-- 加载商品维表的数据
use ${app}; -- 切换数据库
with
sku as
(select id, price, sku_name, sku_desc, weight, is_sale, spu_id,tm_id,category3_id from ods_sku_info_full where dt = '${do_date}'),
spu as
(select id as spu_id, spu_name from ods_spu_info_full where dt = '${do_date}'),
c1 as
(select id as category1_id, name as category1_name from ods_base_category1_full where dt = '${do_date}'),
c2 as
(select id as category2_id,category1_id, name as category2_name from ods_base_category2_full where dt = '${do_date}'),
c3 as
(select id as category3_id,category2_id, name as category3_name from ods_base_category3_full where dt = '${do_date}'),
tm as
(select id as td_id, tm_name from ods_base_trademark_full where dt = '${do_date}'),
attr as
(select sku_id,
       collect_set(
           named_struct(
               'attr_id', attr_id,
               'attr_name',attr_name,
               'value_name',value_name
               )
           ) as sku_attr_values
       from ods_sku_attr_value_full where dt = '${do_date}' group by sku_id),
sale_attr as
(select sku_id,
       collect_set(
           named_struct(
               'sale_attr_id', sale_attr_id,
               'sale_attr_name',sale_attr_name,
               'sale_attr_value_name',sale_attr_value_name
               )
           ) as sku_attr_values
       from ods_sku_sale_attr_value_full where dt = '${do_date}' group by sku_id)

insert overwrite table dim_sku_full partition (dt='${do_date}')

select
    sku.id,
    sku.price,
    sku.sku_name,
    sku.sku_desc,
    sku.weight,
    sku.is_sale,
    sku.spu_id,
    spu.spu_name,
    sku.tm_id,
    tm.tm_name,
    c1.category1_id,
    c1.category1_name,
    c2.category2_id,
    c2.category2_name,
    c3.category3_id,
    c3.category3_name,
    attr.sku_attr_values as attrs,
    sale_attr.sku_attr_values as sale_attrs
from sku
left outer join spu on sku.spu_id = spu.spu_id
left join c3 on sku.category3_id = c3.category3_id
left join c2 on c3.category2_id = c2.category2_id
left join c1 on c2.category1_id = c1.category1_id
left join tm on tm.td_id = sku.tm_id
left join attr on attr.sku_id=sku.id
left join sale_attr on sale_attr.sku_id=sku.id;