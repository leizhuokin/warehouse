use ${app};-- 切换数据库
insert overwrite table dim_coupon_full partition (dt = '${do_date}')
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
(select id, coupon_name, coupon_type, condition_amount, condition_num, activity_id, benefit_amount, benefit_discount, create_time, range_type, limit_num, taken_count, start_time, end_time, operate_time, expire_time, range_desc from ods_coupon_info_full where dt = '${do_date}') ci
left join
(select dic_code, dic_name from ods_base_dic_full where dt = '${do_date}' and parent_code='32') type_dic
on ci.coupon_type = type_dic.dic_code
left join
(select dic_code,dic_name from ods_base_dic_full where dt = '${do_date}' and parent_code='33') range_dic
on ci.range_type = range_dic.dic_code;
