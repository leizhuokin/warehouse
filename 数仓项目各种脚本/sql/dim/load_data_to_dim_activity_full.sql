use ${app};
insert overwrite table dim_activity_full partition (dt = '${do_date}')
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

        from ods_activity_rule_full where dt='${do_date}'
) ar
on  ar.activity_id = ai.id
left join (
    select
        dic_code,
        dic_name
        from ods_base_dic_full where dt = '${do_date}' and parent_code='31'
) dic
on ar.activity_type = dic.dic_code;
