use ${app};
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