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
-- 历史至今
-- 交易域
-- 用户粒度订单
-- 每日
insert overwrite table dws_trade_user_order_td partition(dt='${do_date}')
select
    nvl(old.user_id,new.user_id),
    if(new.user_id is not null and old.user_id is null,'${do_date}',old.order_date_first),
    if(new.user_id is not null,'${do_date}',old.order_date_last),
    nvl(old.order_count_td,0)+nvl(new.order_count_1d,0),
    nvl(old.order_num_td,0)+nvl(new.order_num_1d,0),
    nvl(old.order_original_amount_td,0)+nvl(new.order_original_amount_1d,0),
    nvl(old.order_activity_amount_td,0)+nvl(new.order_activity_amount_1d,0),
    nvl(old.order_coupon_amount_td,0)+nvl(new.order_coupon_amount_1d,0),
    nvl(old.order_total_amount_td,0)+nvl(new.order_total_amount_1d,0)
from
(
    select
        user_id,
        order_date_first,
        order_date_last,
        order_count_td,
        order_num_td,
        order_original_amount_td,
        order_activity_amount_td,
        order_coupon_amount_td,
        order_total_amount_td
    from dws_trade_user_order_td
    where dt=date_add('${do_date}',-1)
)old
full outer join
(
    select
        user_id,
        order_count_1d,
        order_num_1d,
        order_original_amount_1d,
        order_activity_amount_1d,
        order_coupon_amount_1d,
        order_total_amount_1d
    from dws_trade_user_order_1d
    where dt='${do_date}'
)new
on old.user_id=new.user_id;
-- 用户粒度支付
-- 每日
insert overwrite table dws_trade_user_payment_td partition(dt='${do_date}')
select
    nvl(old.user_id,new.user_id),
    if(old.user_id is null and new.user_id is not null,'${do_date}',old.payment_date_first),
    if(new.user_id is not null,'${do_date}',old.payment_date_last),
    nvl(old.payment_count_td,0)+nvl(new.payment_count_1d,0),
    nvl(old.payment_num_td,0)+nvl(new.payment_num_1d,0),
    nvl(old.payment_amount_td,0)+nvl(new.payment_amount_1d,0)
from
(
    select
        user_id,
        payment_date_first,
        payment_date_last,
        payment_count_td,
        payment_num_td,
        payment_amount_td
    from dws_trade_user_payment_td
    where dt=date_add('${do_date}',-1)
)old
full outer join
(
    select
        user_id,
        payment_count_1d,
        payment_num_1d,
        payment_amount_1d
    from dws_trade_user_payment_1d
    where dt='${do_date}'
)new
on old.user_id=new.user_id;
-- 用户域
-- 用户粒度登录

-- 每日
insert overwrite table dws_user_user_login_td partition(dt='${do_date}')
select
    nvl(old.user_id,new.user_id),
    if(new.user_id is null,old.login_date_last,'${do_date}'),
    nvl(old.login_count_td,0)+nvl(new.login_count_1d,0)
from
(
    select
        user_id,
        login_date_last,
        login_count_td
    from dws_user_user_login_td
    where dt=date_add('${do_date}',-1)
)old
full outer join
(
    select
        user_id,
        count(1) login_count_1d
    from dwd_user_login_inc
    where dt='${do_date}'
    group by user_id
)new
on old.user_id=new.user_id;