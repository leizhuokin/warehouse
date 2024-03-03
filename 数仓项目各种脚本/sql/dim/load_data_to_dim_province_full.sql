use ${app};

insert overwrite table dim_province_full partition (dt='${do_date}')

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
    select id, name, region_id, area_code, iso_code, iso_3166_2 from ods_base_province_full where dt='${do_date}'
)p
left join
(
    select id,region_name from ods_base_region_full where dt='${do_date}'
) r
on p.region_id = r.id;