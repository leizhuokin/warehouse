use ${app};
set hive.exec.dynamic.partition.mode=nonstrict;
-- 历史至今
-- 交易域
-- 用户粒度订单
-- 首日
insert overwrite table dws_trade_user_order_td partition(dt='${do_date}')
select
    user_id,
    min(dt) login_date_first,
    max(dt) login_date_last,
    sum(nvl(order_count_1d,0)) order_count,
    sum(nvl(order_num_1d,0)) order_num,
    sum(nvl(order_original_amount_1d,0)) order_original_amount_td,
    sum(nvl(order_activity_amount_1d,0)) order_activity_amount_td,
    sum(nvl(order_coupon_amount_1d,0)) order_coupon_amount_td,
    sum(nvl(order_total_amount_1d,0)) order_total_amount_td
from dws_trade_user_order_1d
group by user_id;

-- 用户粒度支付
-- 首日
insert overwrite table dws_trade_user_payment_td partition(dt='${do_date}')
select
    user_id,
    min(dt) payment_date_first,
    max(dt) payment_date_last,
    sum(payment_count_1d) payment_count,
    sum(payment_num_1d) payment_num,
    sum(payment_amount_1d) payment_amount
from dws_trade_user_payment_1d
group by user_id;
-- 用户域
-- 用户粒度登录
-- 首日
insert overwrite table dws_user_user_login_td partition(dt='${do_date}')
select
    u.id,
    nvl(login_date_last,date_format(create_time,'yyyy-MM-dd')),
    nvl(login_count_td,1)
from
(
    select
        id,
        create_time
    from dim_user_zip
    where dt='9999-12-31'
)u
left join
(
    select
        user_id,
        max(dt) login_date_last,
        count(1) login_count_td
    from dwd_user_login_inc
    group by user_id
)l
on u.id=l.user_id;