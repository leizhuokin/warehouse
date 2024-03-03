use ${app};

insert overwrite table dim_user_zip partition (dt = '9999-12-31')
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
    '${do_date}' start_date,
    '9999-12-31' end_date
    from ods_user_info_inc where dt='${do_date}' and type='bootstrap-insert';
