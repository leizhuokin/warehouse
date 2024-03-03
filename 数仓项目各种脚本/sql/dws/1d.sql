-- 最近1日

-- 交易域
-- 加购：用户
-- 每日加载
use ${app};
insert overwrite table dws_trade_user_cart_add_1d partition(dt='${do_date}')
select
    user_id,
    count(1) cart_add_count_id,
    sum(sku_num) cart_add_num_id
from dwd_trade_cart_add_inc
where dt = '${do_date}'
group by user_id;
-- 订单：用户商品粒度
-- 每日
insert overwrite table dws_trade_user_sku_order_1d partition(dt='${do_date}')
select
    o.user_id,
    o.sku_id,
    s.sku_name,
    s.category1_id,
    s.category1_name,
    s.category2_id,
    s.category2_name,
    s.category3_id,
    s.category3_name,
    s.tm_id,
    s.tm_name,
    o.order_count_1d,
    o.order_num_1d,
    o.order_original_amount_1d,
    o.order_activity_amount_1d,
    o.order_coupon_amount_1d,
    o.order_total_amount_1d
from
(
    select
        user_id,
        sku_id,
        count(1) order_count_1d,
        sum(sku_num) order_num_1d,
        sum(split_original_amount) order_original_amount_1d,
        sum(nvl(split_activity_amount,0.0)) order_activity_amount_1d,
        sum(nvl(split_coupon_amount,0.0)) order_coupon_amount_1d,
        sum(split_total_amount) order_total_amount_1d
    from dwd_trade_order_detail_inc
    where dt = '${do_date}'
    group by user_id,sku_id
) o
left join (
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        tm_id,
        tm_name
    from dim_sku_full
    where dt = '${do_date}'
) s
on o.sku_id = s.id;

-- 退单：用户商品粒度
-- 每日
insert overwrite table dws_trade_user_sku_order_refund_1d partition(dt = '${do_date}')
select
    o.user_id,
    o.sku_id,
    s.sku_name,
    s.category1_id,
    s.category1_name,
    s.category2_id,
    s.category2_name,
    s.category3_id,
    s.category3_name,
    s.tm_id,
    s.tm_name,
    o.order_refund_count_1d,
    o.order_refund_num_1d,
    o.order_refund_amount_1d
from
(
    select
        user_id,
        sku_id,
        count(1) order_refund_count_1d,
        sum(refund_num) order_refund_num_1d,
        sum(refund_amount) order_refund_amount_1d
    from dwd_trade_order_refund_inc
    where dt = '${do_date}'
    group by user_id,sku_id
) o
left join (
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        tm_id,
        tm_name
    from dim_sku_full
    where dt = '${do_date}'
) s
on o.sku_id = s.id;


-- 用户粒度订单
-- 每日
insert overwrite table dws_trade_user_order_1d partition(dt='${do_date}')
select
    user_id,
    count(distinct order_id) order_count_1d, -- 先去重后统计
    sum(sku_num),
    sum(split_original_amount) order_original_amount_1d,
    sum(nvl(split_activity_amount,0.0)) order_activity_amount_1d,
    sum(nvl(split_coupon_amount,0.0)) order_coupon_amount_1d,
    sum(split_total_amount) order_total_amount_1d
from dwd_trade_order_detail_inc
where dt = '${do_date}'
group by user_id;

-- 省份粒度的订单最近1日汇总表
-- 每日
insert overwrite table dws_trade_province_order_1d partition(dt='${do_date}')
select
    o.province_id,
    p.province_anme,
    p.area_code,
    p.iso_code,
    p.iso_3166_2,
    o.order_count_1d,
    o.order_num_1d,
    o.order_original_amount_1d,
    o.order_activity_amount_1d,
    o.order_coupon_amount_1d,
    o.order_total_amount_1d
from
(
    select
        province_id,
        count(distinct order_id) order_count_1d, -- 先去重后统计
        sum(sku_num) order_num_1d,
        sum(split_original_amount) order_original_amount_1d,
        sum(nvl(split_activity_amount,0.0)) order_activity_amount_1d,
        sum(nvl(split_coupon_amount,0.0)) order_coupon_amount_1d,
        sum(split_total_amount) order_total_amount_1d
    from dwd_trade_order_detail_inc
    where dt = '${do_date}'
    group by province_id
)o
left join (
    select
        id,
        name province_anme,
        area_code,
        iso_code,
        iso_3166_2
    from dim_province_full
    where dt = '${do_date}'
)p
on o.province_id = p.id;


-- 退单：用户粒度
-- 每日
insert overwrite table dws_trade_user_order_refund_1d partition(dt='${do_date}')
select
    user_id,
    count(1) order_refund_count_1d, -- TODO 不严谨
    sum(refund_num) order_refund_num_1d,
    sum(refund_amount) order_refund_amount_1d
from dwd_trade_order_refund_inc
where dt = '${do_date}'
group by user_id;

--交易域用户粒度支付最近1日汇总
--每日加载
insert overwrite table dws_trade_user_payment_1d partition(dt='${do_date}')
select
    user_id,
    count(distinct order_id),
    sum(sku_num),
    sum(split_payment_amount)
from dwd_trade_pay_suc_detail_inc
where dt = '${do_date}'
group by user_id;
-- 流量域
-- 流量域会话粒度页面浏览最近1日汇总
-- 加载数据
insert overwrite table dws_traffic_session_page_view_1d partition(dt='${do_date}')
select
    session_id,
    mid_id,
    brand,
    model,
    operate_system ,
    version_code,
    channel,
    sum(during_time) during_time_1d,
    count(1) page_count_1d
from dwd_traffic_page_view_inc
where dt = '${do_date}'
group by session_id,mid_id,brand,model,operate_system,version_code,channel;

-- 流量域访客页面粒度页面浏览最近1日汇总

insert overwrite table dws_traffic_visitor_page_page_view_1d partition (dt='${do_date}')
select
    mid_id,
    page_id,
    brand,
    model,
    operate_system,
    sum(during_time) during_time_1d,
    count(1) view_count_1d
from dwd_traffic_page_view_inc
where dt = '${do_date}'
group by mid_id,page_id,brand,model,operate_system;