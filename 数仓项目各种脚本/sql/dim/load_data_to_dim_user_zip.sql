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
        from ods_user_info_inc where dt = '${do_date}'
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
  cast(date_add('${do_date}',-1) as string) end_date,
  cast(date_add('${do_date}',-1) as string) dt
from tmp
where old_id is not null and new_id is not null;
