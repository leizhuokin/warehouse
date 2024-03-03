-- 首日加载
use ${app};
set hive.exec.dynamic.partition.mode=nonstrict;
-- 加购事实表
-- 加载数据【首日】
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
-- 下单事实表
insert overwrite table dwd_trade_order_detail_inc partition(dt)
select
    o.id,
    o.dt as date_id,
    oi.user_id,
    o.sku_id,
    o.sku_num,
    o.order_id,
    oi.province_id,
    oda.activity_id,
    oda.activity_rule_id,
    odc.coupon_id,

    o.create_time,
    o.source_id,
    o.source_type as source_type_code,
    dic.dic_name as source_type_name,

    o.split_total_amount,
    o.split_activity_amount,
    o.split_coupon_amount,
    o.split_original_amount,
    o.dt
from
(select
    data.id id,
    data.order_id,
    data.sku_id,
    date_format(data.create_time, 'yyyy-MM-dd') dt,
    data.create_time,
    data.source_id,
    data.source_type,
    data.sku_num,
    data.split_total_amount,
    data.split_activity_amount,
    data.split_coupon_amount,
    data.sku_num * data.order_price split_original_amount
    from ods_order_detail_inc
where dt = '${do_date}'
and type = 'bootstrap-insert') o

left join (
    select
        data.id,
        data.user_id,
        data.province_id
    from ods_order_info_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) oi
on o.order_id = oi.id

left join (
    select
        data.order_detail_id,
        data.activity_id,
        data.activity_rule_id
    from ods_order_detail_activity_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) oda

on o.id = oda.order_detail_id

left join (
    select
        data.order_detail_id,
        data.coupon_id
    from ods_order_detail_coupon_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) odc

on o.id = odc.order_detail_id

left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='24'
) dic

on o.source_type = dic.dic_code;

-- 取消订单事实表
insert overwrite table dwd_trade_order_cancel_detail_inc partition(dt)
select
    o.id,
    date_format(oi.cancel_time, 'yyyy-MM-dd') date_id,
    oi.user_id,
    o.sku_id,
    o.sku_num,
    o.order_id,
    oi.province_id,
    oda.activity_id,
    oda.activity_rule_id,
    odc.coupon_id,

    oi.cancel_time,
    o.source_id,
    o.source_type as source_type_code,
    dic.dic_name as source_type_name,

    o.split_total_amount,
    o.split_activity_amount,
    o.split_coupon_amount,
    o.split_original_amount,
    date_format(oi.cancel_time, 'yyyy-MM-dd') dt
from
(select
    data.id id,
    data.order_id,
    data.sku_id,
    data.source_id,
    data.source_type,
    data.sku_num,
    data.split_total_amount,
    data.split_activity_amount,
    data.split_coupon_amount,
    data.sku_num * data.order_price split_original_amount
    from ods_order_detail_inc
where dt = '${do_date}'
and type = 'bootstrap-insert') o

left join (
    select
        data.id,
        data.user_id,
        data.province_id,
        data.operate_time cancel_time
    from ods_order_info_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
      -- 1003就是订单状态中取消订单的标识
      and data.order_status='1003'
) oi
on o.order_id = oi.id

left join (
    select
        data.order_detail_id,
        data.activity_id,
        data.activity_rule_id
    from ods_order_detail_activity_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) oda

on o.id = oda.order_detail_id

left join (
    select
        data.order_detail_id,
        data.coupon_id
    from ods_order_detail_coupon_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) odc

on o.id = odc.order_detail_id

left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='24'
) dic

on o.source_type = dic.dic_code;

-- 支付成功明细实表
insert overwrite table dwd_trade_pay_suc_detail_inc partition(dt)
select
    o.id,
    date_format(p.callback_time, 'yyyy-MM-dd') date_id,
    p.user_id,
    o.sku_id,
    o.sku_num,
    o.order_id,
    oi.province_id,
    oda.activity_id,
    oda.activity_rule_id,
    odc.coupon_id,

    p.callback_time,
    o.source_id,
    o.source_type as source_type_code,
    order_dic.dic_name as source_type_name,
    pay_dic.dic_code as payment_type_code,
    pay_dic.dic_name as payment_type_name,
    o.split_payment_amount,
    o.split_activity_amount,
    o.split_coupon_amount,
    o.split_original_amount,
    date_format(p.callback_time, 'yyyy-MM-dd') dt
from
(select
    data.id id,
    data.order_id,
    data.sku_id,
    data.source_id,
    data.source_type,
    data.sku_num,
    data.split_total_amount as split_payment_amount,
    data.split_activity_amount,
    data.split_coupon_amount,
    data.sku_num * data.order_price split_original_amount
    from ods_order_detail_inc
where dt = '${do_date}'
and type = 'bootstrap-insert') o

left join (
    select
        data.order_id,
        data.user_id,
        data.payment_type,
        data.callback_time
    from ods_payment_info_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
      and data.payment_status = '1602'
) p
on o.order_id = p.order_id

left join (
    select
        data.id,
        data.province_id
    from ods_order_info_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) oi
on o.order_id = oi.id

left join (
    select
        data.order_detail_id,
        data.activity_id,
        data.activity_rule_id
    from ods_order_detail_activity_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) oda

on o.id = oda.order_detail_id

left join (
    select
        data.order_detail_id,
        data.coupon_id
    from ods_order_detail_coupon_inc
    where dt = '${do_date}'
      and type='bootstrap-insert'
) odc

on o.id = odc.order_detail_id

left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='24'
) order_dic
on o.source_type = order_dic.dic_code
left join (
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt = '${do_date}'
      and parent_code='11'
) pay_dic

on p.payment_type = pay_dic.dic_code;


-- 交易域退单事务事实表
insert overwrite table dwd_trade_order_refund_inc partition(dt)
select
    ri.id,
    user_id,
    order_id,
    sku_id,
    province_id,
    date_format(create_time,'yyyy-MM-dd') date_id,
    create_time,
    refund_type,
    type_dic.dic_name,
    refund_reason_type,
    reason_dic.dic_name,
    refund_reason_txt,
    refund_num,
    refund_amount,
    date_format(create_time,'yyyy-MM-dd')
from
(
    select
        data.id,
        data.user_id,
        data.order_id,
        data.sku_id,
        data.refund_type,
        data.refund_num,
        data.refund_amount,
        data.refund_reason_type,
        data.refund_reason_txt,
        data.create_time
    from ods_order_refund_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)ri
left join
(
    select
        data.id,
        data.province_id
    from ods_order_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)oi
on ri.order_id=oi.id
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code = '15'
)type_dic
on ri.refund_type=type_dic.dic_code
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code = '13'
)reason_dic
on ri.refund_reason_type=reason_dic.dic_code;

-- 交易域退款成功
insert overwrite table dwd_trade_refund_pay_suc_inc partition(dt)
select
    rp.id,
    user_id,
    rp.order_id,
    rp.sku_id,
    province_id,
    payment_type,
    dic_name,
    date_format(callback_time,'yyyy-MM-dd') date_id,
    callback_time,
    refund_num,
    total_amount,
    date_format(callback_time,'yyyy-MM-dd')
from
(
    select
        data.id,
        data.order_id,
        data.sku_id,
        data.payment_type,
        data.callback_time,
        data.total_amount
    from ods_refund_payment_inc
    where dt='${do_date}'
    and type = 'bootstrap-insert'
    and data.refund_status='1602'
)rp
left join
(
    select
        data.id,
        data.user_id,
        data.province_id
    from ods_order_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)oi
on rp.order_id=oi.id
left join
(
    select
        data.order_id,
        data.sku_id,
        data.refund_num
    from ods_order_refund_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)ri
on rp.order_id=ri.order_id
and rp.sku_id=ri.sku_id
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code='11'
)dic
on rp.payment_type=dic.dic_code;

-- 工具域-优惠券领取事务-事实表
-- 首日
insert overwrite table dwd_tool_coupon_get_inc partition (dt)
select
    data.id,
    data.coupon_id,
    data.user_id,
    date_format(data.get_time,'yyyy-MM-dd') date_id,
    data.get_time,
    date_format(data.get_time,'yyyy-MM-dd') date_id
from ods_coupon_use_inc
where dt='${do_date}'
and type='bootstrap-insert';

-- 工具域-使用优惠券下单事务-事实表
-- 首日
insert overwrite table dwd_tool_coupon_order_inc partition (dt)
select
    data.id,
    data.coupon_id,
    data.user_id,
    date_format(data.using_time,'yyyy-MM-dd') date_id,
    data.order_id,
    data.using_time as order_time,
    date_format(data.using_time,'yyyy-MM-dd') date_id
from ods_coupon_use_inc
where dt='${do_date}'
and type='bootstrap-insert'
and data.using_time is not null;

-- 工具域优惠券使用支付事实表
insert overwrite table dwd_tool_coupon_pay_inc partition(dt)
select
    data.id,
    data.coupon_id,
    data.user_id,
    data.order_id,
    date_format(data.used_time,'yyyy-MM-dd') date_id,
    data.used_time,
    date_format(data.used_time,'yyyy-MM-dd')
from ods_coupon_use_inc
where dt='${do_date}'
and type='bootstrap-insert'
and data.used_time is not null;

-- 互动域-收藏商品事实表
insert overwrite table dwd_interaction_favor_add_inc partition(dt)
select
    data.id,
    data.user_id,
    data.sku_id,
    date_format(data.create_time,'yyyy-MM-dd') date_id,
    data.create_time,
    date_format(data.create_time,'yyyy-MM-dd')
from ods_favor_info_inc
where dt='${do_date}'
and type = 'bootstrap-insert';

-- 评价
insert overwrite table dwd_interaction_comment_inc partition(dt)
select
    id,
    user_id,
    sku_id,
    order_id,
    date_format(create_time,'yyyy-MM-dd') date_id,
    create_time,
    appraise,
    dic_name,
    date_format(create_time,'yyyy-MM-dd')
from
(
    select
        data.id,
        data.user_id,
        data.sku_id,
        data.order_id,
        data.create_time,
        data.appraise
    from ods_comment_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)ci
left join
(
    select
        dic_code,
        dic_name
    from ods_base_dic_full
    where dt='${do_date}'
    and parent_code='12'
)dic
on ci.appraise=dic.dic_code;

-- 流量域-页面浏览事务事实表
-- 无需首日

-- 流量域-app启动事务事实表
-- 无需首日

-- 动作
-- 无需首日

-- 曝光
-- 无需首日
-- 错误事实表
-- 无需首日

-- 用户域-注册
insert overwrite table dwd_user_register_inc partition(dt)
select
    ui.user_id,
    date_format(create_time,'yyyy-MM-dd') date_id,
    create_time,
    channel,
    province_id,
    version_code,
    mid_id,
    brand,
    model,
    operate_system,
    date_format(create_time,'yyyy-MM-dd')
from
(
    select
        data.id user_id,
        data.create_time
    from ods_user_info_inc
    where dt='${do_date}'
    and type='bootstrap-insert'
)ui
left join
(
    select
        common.ar area_code,
        common.ba brand,
        common.ch channel,
        common.md model,
        common.mid mid_id,
        common.os operate_system,
        common.uid user_id,
        common.vc version_code
    from ods_log_inc
    where dt='${do_date}'
    and page.page_id='register'
    and common.uid is not null
)log
on ui.user_id=log.user_id
left join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)bp
on log.area_code=bp.area_code;

-- 交易域-购物车周期性快照-事实表
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

-- 流量域-页面浏览事务事实表
insert overwrite table dwd_traffic_page_view_inc partition(dt='${do_date}')
select
    date_format(from_utc_timestamp(log.ts, 'GMT+8'), 'yyyy-MM-dd') date_id,
    p.province_id,
    log.brand,
    log.channel,
    log.is_new,
    log.model,
    log.mid_id,
    log.operate_system,
    log.version_code,
    log.user_id,
    log.page_item,
    log.page_item_type,
    log.last_page_id,
    log.page_id,
    log.source_type,
    date_format(from_utc_timestamp(log.ts, 'GMT+8'), 'yyyy-MM-dd HH:mm:ss') view_time,
    concat(log.mid_id,'-',last_value(log.session_start_point,true) over (partition by mid_id order by ts)) session_id,
    log.during_time
from
(select
    ts,
    common.ar area_code,
    common.ba brand,
    common.ch channel,
    common.is_new is_new,
    common.md model,
    common.mid mid_id,
    common.os operate_system,
    common.vc version_code,
    common.uid user_id,
    page.item page_item,
    page.item_type page_item_type,
    page.last_page_id last_page_id,
    page.page_id page_id,
    page.source_type source_type,
    if(page.last_page_id is null,ts,null) session_start_point,
    page.during_time during_time
from ods_log_inc
where dt = '${do_date}'
and page is not null) log

left join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)p
on log.area_code = p.area_code;

insert overwrite table dwd_traffic_start_inc partition(dt='${do_date}')
select
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd') date_id,
    province_id,
    brand,
    channel,
    is_new,
    model,
    mid_id,
    operate_system,
    user_id,
    version_code,
    entry,
    open_ad_id,
    loading_time,
    open_ad_ms,
    open_ad_skip_ms
from
(
    select
        common.ar area_code,
        common.ba brand,
        common.ch channel,
        common.is_new,
        common.md model,
        common.mid mid_id,
        common.os operate_system,
        common.uid user_id,
        common.vc version_code,
        `start`.entry,
        `start`.loading_time,
        `start`.open_ad_id,
        `start`.open_ad_ms,
        `start`.open_ad_skip_ms,
        ts
    from ods_log_inc
    where dt='${do_date}'
    and `start` is not null
)log
left join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)bp
on log.area_code=bp.area_code;

-- 流量域动作事务事实表
insert overwrite table dwd_traffic_action_inc partition(dt='${do_date}')
select
    province_id,
    brand,
    channel,
    is_new,
    model,
    mid_id,
    operate_system,
    user_id,
    version_code,
    during_time,
    page_item,
    page_item_type,
    last_page_id,
    page_id,
    source_type,
    action_id,
    action_item,
    action_item_type,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd') date_id,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd HH:mm:ss') action_time
from
(
    select
        common.ar area_code,
        common.ba brand,
        common.ch channel,
        common.is_new,
        common.md model,
        common.mid mid_id,
        common.os operate_system,
        common.uid user_id,
        common.vc version_code,
        page.during_time,
        page.item page_item,
        page.item_type page_item_type,
        page.last_page_id,
        page.page_id,
        page.source_type,
        action.action_id,
        action.item action_item,
        action.item_type action_item_type,
        action.ts
    from ods_log_inc lateral view explode(actions) tmp as action
    where dt='${do_date}'
    and actions is not null
)log
left join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)bp
on log.area_code=bp.area_code;

-- 流量域曝光事务事实表
insert overwrite table dwd_traffic_display_inc partition(dt='${do_date}')
select
    province_id,
    brand,
    channel,
    is_new,
    model,
    mid_id,
    operate_system,
    user_id,
    version_code,
    during_time,
    page_item,
    page_item_type,
    last_page_id,
    page_id,
    source_type,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd') date_id,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd HH:mm:ss') display_time,
    display_type,
    display_item,
    display_item_type,
    display_order,
    display_pos_id
from
(
    select
        common.ar area_code,
        common.ba brand,
        common.ch channel,
        common.is_new,
        common.md model,
        common.mid mid_id,
        common.os operate_system,
        common.uid user_id,
        common.vc version_code,
        page.during_time,
        page.item page_item,
        page.item_type page_item_type,
        page.last_page_id,
        page.page_id,
        page.source_type,
        display.display_type as display_type,
        display.item display_item,
        display.item_type display_item_type,
        display.`order` display_order,
        display.pos_id display_pos_id,
        ts
    from ods_log_inc lateral view explode(displays) tmp as display
    where dt='${do_date}'
    and displays is not null
)log
left join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)bp
on log.area_code=bp.area_code;

-- 用户域用户登录事务事实表
insert overwrite table dwd_user_login_inc partition(dt='${do_date}')
select
    user_id,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd') date_id,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd HH:mm:ss') login_time,
    channel,
    province_id,
    version_code,
    mid_id,
    brand,
    model,
    operate_system
from
(
    select
        user_id,
        channel,
        area_code,
        version_code,
        mid_id,
        brand,
        model,
        operate_system,
        ts
    from
    (
        select
            user_id,
            channel,
            area_code,
            version_code,
            mid_id,
            brand,
            model,
            operate_system,
            ts,
            row_number() over (partition by session_id order by ts) rn
        from
        (
            select
                user_id,
                channel,
                area_code,
                version_code,
                mid_id,
                brand,
                model,
                operate_system,
                ts,
                concat(mid_id,'-',last_value(session_start_point,true) over(partition by mid_id order by ts)) session_id
            from
            (
                select
                    common.uid user_id,
                    common.ch channel,
                    common.ar area_code,
                    common.vc version_code,
                    common.mid mid_id,
                    common.ba brand,
                    common.md model,
                    common.os operate_system,
                    ts,
                    if(page.last_page_id is null,ts,null) session_start_point
                from ods_log_inc
                where dt='${do_date}'
                and page is not null
            )t1
        )t2
        where user_id is not null
    )t3
    where rn=1
)t4
left join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)bp
on t4.area_code=bp.area_code;
set hive.vectorized.execution.enabled = false;
-- 流量域错误事务事实表
insert overwrite table dwd_traffic_error_inc partition(dt='${do_date}')
select
    province_id,
    brand,
    channel,
    is_new,
    model,
    mid_id,
    operate_system,
    user_id,
    version_code,
    page_item,
    page_item_type,
    last_page_id,
    page_id,
    source_type,
    entry,
    loading_time,
    open_ad_id,
    open_ad_ms,
    open_ad_skip_ms,
    actions,
    displays,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd') date_id,
    date_format(from_utc_timestamp(ts,'GMT+8'),'yyyy-MM-dd HH:mm:ss') error_time,
    error_code,
    error_msg
from
(
    select
        common.ar area_code,
        common.ba brand,
        common.ch channel,
        common.is_new,
        common.md model,
        common.mid mid_id,
        common.os operate_system,
        common.uid user_id,
        common.vc version_code,
        page.during_time,
        page.item page_item,
        page.item_type page_item_type,
        page.last_page_id,
        page.page_id,
        page.source_type,
        `start`.entry,
        `start`.loading_time,
        `start`.open_ad_id,
        `start`.open_ad_ms,
        `start`.open_ad_skip_ms,
        actions,
        displays,
        err.error_code,
        err.msg error_msg,
        ts
    from ods_log_inc
    where dt='${do_date}'
    and err is not null
)log
join
(
    select
        id province_id,
        area_code
    from ods_base_province_full
    where dt='${do_date}'
)bp
on log.area_code=bp.area_code;