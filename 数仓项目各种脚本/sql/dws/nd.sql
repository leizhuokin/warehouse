use ${app};
-- 最近n日【7,30】
-- 交易域
-- 交易域用户商品粒度订单最近n日汇总
insert overwrite table dws_trade_user_sku_order_nd partition(dt = '${do_date}')
select
    user_id,
    sku_id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    sum(if(dt>=date_add('${do_date}',-6),order_count_1d,0)) order_count_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_num_1d,0)) order_num_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_original_amount_1d,0)) order_original_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_activity_amount_1d,0)) order_activity_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_coupon_amount_1d,0)) order_coupon_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_total_amount_1d,0)) order_total_amount_7d,
    sum(order_count_1d) order_count_30d,
    sum(order_num_1d) order_num_30d,
    sum(order_original_amount_1d) order_original_amount_30d,
    sum(order_activity_amount_1d) order_activity_amount_30d,
    sum(order_coupon_amount_1d) order_coupon_amount_30d,
    sum(order_total_amount_1d) order_total_amount_30d
from dws_trade_user_sku_order_1d
where dt>=date_add('${do_date}',-29) and dt <= '${do_date}'
group by user_id,sku_id,sku_name,category1_id,category1_name,category2_id,category2_name,category3_id,category3_name,tm_id,tm_name;

-- 交易域用户商品粒度退单最近n日汇总

insert overwrite table dws_trade_user_sku_order_refund_nd partition (dt = '${do_date}')
select
    user_id,
    sku_id,
    sku_name,
    category1_id,
    category1_name,
    category2_id,
    category2_name,
    category3_id,
    category3_name,
    tm_id,
    tm_name,
    sum(if(dt>=date_add('${do_date}',-6),order_refund_count_1d,0)) order_refund_count_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_refund_num_1d,0)) order_refund_num_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_refund_amount_1d,0)) order_refund_amount_7d,
    sum(order_refund_count_1d) order_count_30d,
    sum(order_refund_num_1d) order_num_30d,
    sum(order_refund_amount_1d) order_original_amount_30d
from dws_trade_user_sku_order_refund_1d
where dt >= date_add('${do_date}',-29) and dt <= '${do_date}'
group by user_id,sku_id,sku_name,category1_id,category1_name,category2_id,category2_name,category3_id,category3_name,tm_id,tm_name;

-- 交易域用户粒度订单

insert overwrite table dws_trade_user_order_nd partition (dt = '${do_date}')
select
    user_id,
    sum(if(dt>=date_add('${do_date}',-6), order_count_1d, 0)) order_count_7d,
    sum(if(dt>=date_add('${do_date}',-6), order_num_1d, 0)) order_num_7d,
    sum(if(dt>=date_add('${do_date}',-6), order_original_amount_1d, 0)) order_original_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6), order_activity_amount_1d, 0)) order_activity_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6), order_coupon_amount_1d, 0)) order_coupon_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6), order_total_amount_1d, 0)) order_total_amount_7d,
    sum(order_count_1d) order_count_30d,
    sum(order_num_1d) order_num_30d,
    sum(order_original_amount_1d) order_original_amount_30d,
    sum(order_activity_amount_1d) order_activity_amount_30d,
    sum(order_coupon_amount_1d) order_coupon_amount_30d,
    sum(order_total_amount_1d) order_total_amount_30d
from dws_trade_user_order_1d
where dt >= date_add('${do_date}',-29) and dt <= '${do_date}'
group by user_id;

-- 交易域用户粒度退单

insert overwrite table dws_trade_user_order_refund_nd partition (dt = '${do_date}')
select
    user_id,
    sum(if(dt>= date_add('${do_date}',-6),order_refund_count_1d,0)) order_refund_count_7d,
    sum(if(dt>= date_add('${do_date}',-6),order_refund_num_1d,0)) order_refund_num_7d,
    sum(if(dt>= date_add('${do_date}',-6),order_refund_amount_1d,0)) order_refund_amount_7d,
    sum(order_refund_count_1d) order_refund_count_30d,
    sum(order_refund_num_1d) order_refund_num_30d,
    sum(order_refund_amount_1d) order_refund_amount_30d
from dws_trade_user_order_refund_1d
where dt >= date_add('${do_date}', -29) and dt<= '${do_date}'
group by user_id;
-- 交易域用户粒度加购

insert overwrite table dws_trade_user_cart_add_nd partition (dt = '${do_date}')
select
    user_id,
    sum(if(dt>=date_add('${do_date}',-6),cart_add_count_1d,0)) cart_add_count_7d,
    sum(if(dt>=date_add('${do_date}',-6),cart_add_num_1d,0)) cart_add_num_7d,
    sum(cart_add_count_1d) cart_add_count_30d,
    sum(cart_add_num_1d) cart_add_num_30d
from dws_trade_user_cart_add_1d
where dt >= date_add('${do_date}', -29) and dt<= '${do_date}'
group by user_id;
-- 交易域用户粒度支付

insert overwrite table dws_trade_user_payment_nd partition (dt='${do_date}')
select
    user_id,
    sum(if(dt>=date_add('${do_date}',-6),payment_count_1d, 0)) payment_count_7d,
    sum(if(dt>=date_add('${do_date}',-6),payment_num_1d, 0)) payment_num_7d,
    sum(if(dt>=date_add('${do_date}',-6),payment_amount_1d, 0)) payment_amount_7d,
    sum(payment_count_1d) payment_count_30d,
    sum(payment_num_1d) payment_num_30d,
    sum(payment_amount_1d) payment_amount_30d
from dws_trade_user_payment_1d
where dt >= date_add('${do_date}',-29) and dt <= '${do_date}'
group by user_id;
-- 交易域省份粒度订单

insert overwrite table dws_trade_province_order_nd partition (dt = '${do_date}')
select
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    sum(if(dt>=date_add('${do_date}',-6),order_count_1d,0)) order_count_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_num_1d,0)) order_num_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_original_amount_1d,0)) order_original_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_activity_amount_1d,0)) order_activity_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_coupon_amount_1d,0)) order_coupon_amount_7d,
    sum(if(dt>=date_add('${do_date}',-6),order_total_amount_1d,0)) order_total_amount_7d,
    sum(order_count_1d) order_count_30d,
    sum(order_num_1d) order_num_30d,
    sum(order_original_amount_1d) order_original_amount_30d,
    sum(order_activity_amount_1d) order_activity_amount_30d,
    sum(order_coupon_amount_1d) order_coupon_amount_30d,
    sum(order_total_amount_1d) order_total_amount_30d
from dws_trade_province_order_1d
where dt >= date_add('${do_date}',-29) and dt<='${do_date}'
group by province_id,province_name,area_code,iso_code,iso_3166_2;
-- 交易域优惠券粒度订单

-- 数据加载
insert overwrite table dws_trade_coupon_order_nd partition (dt='${do_date}')
select
    c.coupon_id,
    c.coupon_name,
    c.coupon_type_code,
    c.coupon_type_name,
    c.coupon_rule,
    c.start_date,
    c.taken_count,
    o.order_count_7d,
    o.order_original_amount_7d,
    o.order_coupon_amount_7d,
    o.order_total_amount_7d,
    o.order_count_30d,
    o.order_original_amount_30d,
    o.order_coupon_amount_30d,
    o.order_total_amount_30d
from
(
select
    id coupon_id,
    coupon_name,
    coupon_type_code,
    coupon_type_name,
    benefit_rule coupon_rule,
    date_format(start_time, 'yyyy-MM-dd') start_date,
    taken_count
from dim_coupon_full
where dt = '${do_date}' and date_format(start_time,'yyyy-MM-dd') >= date_add('${do_date}',-29)
) c
left join
(
    select
        coupon_id,
        count(distinct if(dt>=date_add('${do_date}',-6),order_id,null)) order_count_7d, -- TODO 待验证结果的准确性
        sum(if(dt>=date_add('${do_date}',-6),split_original_amount,0)) order_original_amount_7d,
        sum(if(dt>=date_add('${do_date}',-6),split_coupon_amount,0)) order_coupon_amount_7d,
        sum(if(dt>=date_add('${do_date}',-6),split_total_amount,0)) order_total_amount_7d,
        count( distinct order_id) order_count_30d,
        sum(split_original_amount) order_original_amount_30d,
        sum(split_coupon_amount) order_coupon_amount_30d,
        sum(split_total_amount) order_total_amount_30d
    from dwd_trade_order_detail_inc
    where coupon_id is not null and dt <= '${do_date}' and dt >= date_add('${do_date}',-29)
    group by coupon_id
)o
on c.coupon_id = o.coupon_id;

-- 交易域活动粒度订单

insert overwrite table dws_trade_activity_order_nd partition (dt='${do_date}')
select
    c.activity_id,
    c.activity_name,
    c.activity_type_code,
    c.activity_type_name,
    c.activity_rule,
    c.start_date,
    o.order_count_7d,
    o.order_original_amount_7d,
    o.order_original_amount_7d,
    o.order_total_amount_7d,
    o.order_count_30d,
    o.order_original_amount_30d,
    o.order_original_amount_30d,
    o.order_total_amount_30d
from
(
select
    id activity_id,
    activity_name,
    activity_type_code,
    activity_type_name,
    benefit_rule activity_rule,
    date_format(start_time, 'yyyy-MM-dd') start_date
from dim_activity_full
where dt = '${do_date}' and date_format(start_time,'yyyy-MM-dd') >= date_add('${do_date}',-29)
) c
left join
(
    select
        activity_id,
        count(distinct if(dt>=date_add('${do_date}',-6),order_id,null)) order_count_7d, -- TODO 待验证结果的准确性
        sum(if(dt>=date_add('${do_date}',-6),split_original_amount,0)) order_original_amount_7d,
        sum(if(dt>=date_add('${do_date}',-6),split_activity_amount,0)) order_coupon_amount_7d,
        sum(if(dt>=date_add('${do_date}',-6),split_total_amount,0)) order_total_amount_7d,
        count( distinct order_id) order_count_30d,
        sum(split_original_amount) order_original_amount_30d,
        sum(split_activity_amount) order_coupon_amount_30d,
        sum(split_total_amount) order_total_amount_30d
    from dwd_trade_order_detail_inc
    where activity_id is not null and dt <= '${do_date}' and dt >= date_add('${do_date}',-29)
    group by activity_id
)o
on c.activity_id = o.activity_id;
-- 流量域
-- 流量域访客页面粒度页面浏览
insert overwrite table dws_traffic_visitor_page_page_view_nd partition(dt='${do_date}')
select
    mid_id,
    brand,
    model,
    operate_system,
    page_id,
    sum(if(dt>=date_add('${do_date}',-6),during_time_1d,0)),
    sum(if(dt>=date_add('${do_date}',-6),view_count_1d,0)),
    sum(during_time_1d),
    sum(view_count_1d)
from dws_traffic_visitor_page_page_view_1d
where dt>=date_add('${do_date}',-29)
and dt<='${do_date}'
group by mid_id,brand,model,operate_system,page_id;