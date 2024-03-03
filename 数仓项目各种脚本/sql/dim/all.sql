use ${app};
insert overwrite table dim_activity_full 
select
    ai.id,
    ar.id as rule_id,
    ai.activity_name,
    ar.activity_type as activity_type_code,
    dic.dic_name as activity_type_name,
    ai.activity_desc,
    ai.start_time,
    ai.end_time,
    ai.create_time,
    ar.condition_amount,
    ar.condition_num,
    ar.benefit_amount,
    ar.benefit_discount,
    ar.benefit_level,
    case ar.activity_type
        when '3101' then concat('满',ar.condition_amount,'元 减',ar.benefit_amount,'元')
        when '3102' then concat('满',ar.condition_num,'件 打',(1-ar.benefit_discount)*10,'折')
        when '3103' then concat('打',(1-ar.benefit_discount)*10,'折')
    end benefit_rule
    from (
    select
        id, activity_name, activity_type, activity_desc, start_time, end_time, create_time, dt
        from ods_activity_info_full where dt = '${do_date}'
              ) ai
left join (
    select
        id, activity_id, activity_type, condition_amount, condition_num, benefit_amount, benefit_discount, benefit_level

        from ods_activity_rule_full
) ar
on  ar.activity_id = ai.id
left join (
    select
        dic_code,
        dic_name
        from ods_base_dic_full where parent_code='31'
) dic
on ar.activity_type = dic.dic_code;

-- 2
use ${app};-- 切换数据库
insert overwrite table dim_coupon_full 
select
    ci.id,
    ci.coupon_name,
    ci.coupon_type as coupon_type_code,
    type_dic.dic_name as coupon_type_name,
    ci.condition_amount,
    ci.condition_num,
    ci.activity_id,
    ci.benefit_amount,
    ci.benefit_discount,
    ci.create_time,
    ci.range_type as range_type_code,
    range_dic.dic_name as range_type_name,
    ci.limit_num,
    ci.taken_count,
    ci.start_time,
    ci.end_time,
    ci.operate_time,
    ci.expire_time,
    ci.range_desc,
    case ci.coupon_type
        when '3201' then concat('满',ci.condition_amount,'元 减',ci.benefit_amount,'元')
        when '3202' then concat('满',ci.condition_num,'件 打',(1-ci.benefit_discount)*10,'折')
        when '3203' then concat('减',ci.benefit_amount,'元')
    end benefit_rule
    from
(select id, coupon_name, coupon_type, condition_amount, condition_num, activity_id, benefit_amount, benefit_discount, create_time, range_type, limit_num, taken_count, start_time, end_time, operate_time, expire_time, range_desc from ods_coupon_info_full) ci
left join
(select dic_code, dic_name from ods_base_dic_full where parent_code='32') type_dic
on ci.coupon_type = type_dic.dic_code
left join
(select dic_code,dic_name from ods_base_dic_full where parent_code='33') range_dic
on ci.range_type = range_dic.dic_code;

use ${app};

insert overwrite table dim_province_full 

select
    p.id,
    p.name,
    p.region_id,
    p.area_code,
    p.iso_code,
    p.iso_3166_2,
    r.region_name
    from
(
    select id, name, region_id, area_code, iso_code, iso_3166_2 from ods_base_province_full
)p
left join
(
    select id,region_name from ods_base_region_full
) r
on p.region_id = r.id;

-- 加载商品维表的数据
use ${app}; -- 切换数据库
with
sku as
(select id, price, sku_name, sku_desc, weight, is_sale, spu_id,tm_id,category3_id from ods_sku_info_full),
spu as
(select id as spu_id, spu_name from ods_spu_info_full),
c1 as
(select id as category1_id, name as category1_name from ods_base_category1_full),
c2 as
(select id as category2_id,category1_id, name as category2_name from ods_base_category2_full),
c3 as
(select id as category3_id,category2_id, name as category3_name from ods_base_category3_full),
tm as
(select id as td_id, tm_name from ods_base_trademark_full),
attr as
(select sku_id,
       collect_set(
           named_struct(
               'attr_id', attr_id,
               'attr_name',attr_name,
               'value_name',value_name
               )
           ) as sku_attr_values
       from ods_sku_attr_value_full group by sku_id),
sale_attr as
(select sku_id,
       collect_set(
           named_struct(
               'sale_attr_id', sale_attr_id,
               'sale_attr_name',sale_attr_name,
               'sale_attr_value_name',sale_attr_value_name
               )
           ) as sku_attr_values
       from ods_sku_sale_attr_value_full group by sku_id)

insert overwrite table dim_sku_full 

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

use ${app};
set hive.exec.dynamic.partition.mode=nostrict;
with tmp as (
select
    old.id old_id,
    old.login_name old_login_name,
    old.nick_name old_nick_name,
    old.name old_name,
    old.phone_num  old_phone_num,
    old.email old_email,
    old.user_level old_user_level,
    old.birthday old_birthday,
    old.gender old_gender,
    old.create_time old_create_time,
    old.operate_time old_operate_time,
    old.status old_status,
    old.start_date old_start_date,
    old.end_date old_end_date,
    new.id new_id,
    new.login_name new_login_name,
    new.nick_name new_nick_name,
    new.name new_name,
    new.phone_num  new_phone_num,
    new.email new_email,
    new.user_level new_user_level,
    new.birthday new_birthday,
    new.gender new_gender,
    new.create_time new_create_time,
    new.operate_time new_operate_time,
    new.status new_status,
    new.start_date new_start_date,
    new.end_date new_end_date
    from
(
    select
        id,
        login_name,
        nick_name,
        name,
        phone_num,
        email,
        user_level,
        birthday,
        gender,
        create_time,
        operate_time,
        status,
        start_date,
        end_date
        from dim_user_zip where dt = '9999-12-31'
) old

full outer join
(
    select
        id,
        login_name,
        nick_name,
        name,
        phone_num,
        email,
        user_level,
        birthday,
        gender,
        create_time,
        operate_time,
        status,
        dt start_date,
        '9999-12-31' end_date
        from (
        select
            data.id,
            data.login_name,
            data.nick_name,
            data.name,
            data.phone_num,
            data.email,
            data.user_level,
            data.birthday,
            data.gender,
            data.create_time,
            data.operate_time,
            data.status,
            row_number() over (partition by data.id order by ts desc) rn,
            dt
        from ods_user_info_inc
     ) t1 where rn =1
) new
on old.id = new.id
)
insert overwrite table dim_user_zip partition (dt)
select
    if(new_id is not null, new_id,old_id),
    if(new_id is not null, new_login_name,old_login_name),
    if(new_id is not null, new_nick_name,old_nick_name),
    if(new_id is not null, new_name,old_name),
    if(new_id is not null, new_phone_num,old_phone_num),
    if(new_id is not null, new_email,old_email),
    if(new_id is not null, new_user_level,old_user_level),
    if(new_id is not null, new_birthday,old_birthday),
    if(new_id is not null, new_gender,old_gender),
    if(new_id is not null, new_create_time,old_create_time),
    if(new_id is not null, new_operate_time,old_operate_time),
    if(new_id is not null, new_status,old_status),
    if(new_id is not null, new_start_date,old_start_date),
    if(new_id is not null, new_end_date,old_end_date),
    if(new_id is not null, new_end_date,old_end_date) dt
from tmp
union all
select
  old_id,
  old_login_name,
  old_nick_name,
  old_name,
  old_phone_num,
  old_email,
  old_user_level,
  old_birthday,
  old_gender,
  old_create_time,
  old_operate_time,
  old_status,
  old_start_date,
  cast(date_add('2024-01-01',-1) as string) end_date,
  cast(date_add('2024-01-01',-1) as string) dt
from tmp
where old_id is not null and new_id is not null;