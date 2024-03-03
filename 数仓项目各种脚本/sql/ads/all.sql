use ${app};
-- 各渠道流量统计
insert overwrite table ads_traffic_stats_by_channel
select
    *
from ads_traffic_stats_by_channel
union
select
    '${do_date}' as dt,
    tmp.recent_days,
    channel,
    cast(count(distinct mid_id) as bigint) uv,
    cast(avg(during_time_1d) / 1000 as bigint) avg_duration_sec,
    cast(avg(page_count_1d) as bigint) avg_page,
    cast(count(1) as bigint) session_count,
    cast(sum(if(page_count_1d = 1,1,0)) / count(1) as decimal(16,2)) bouce_rate
from dws_traffic_session_page_view_1d lateral view explode(array(1,7,30)) tmp as recent_days
where dt >= date_add('${do_date}', -(tmp.recent_days-1))
group by tmp.recent_days,channel;


-- 路径分析
insert overwrite table ads_traffic_page_path
select
    *
from ads_traffic_page_path
union
select
    '${do_date}' as dt,
    t2.recent_days,
    t2.source,
    nvl(t2.target, 'null'),
    count(1) path_count
from
(
    select
    recent_days,
    concat('step-',rn,':',page_id) source,
    concat('step-',rn+1,':',next_page_id) target
    from
    (
        select
        tmp.recent_days,
        page_id,
        -- 第一个参数「property」标识想查询的列，「num」标识相对于当前行的第num行，第三个参数是默认值
        lead(page_id,1,null) over (partition by session_id,tmp.recent_days) next_page_id,
        -- lateral view 主要功能是将原本汇总在一条（行）的数据拆分成多条（行）成虚拟表，再与原表进行笛卡尔积，从而得到明细表
        -- 一般情况下经常与explode函数搭配，explode的操作对象（列值）是 ARRAY 或者 MAP
        row_number() over (partition by session_id,tmp.recent_days order by view_time) rn
        from dwd_traffic_page_view_inc lateral view explode(array(1,7,30)) tmp as recent_days
        where dt >= date_add('${do_date}', -(recent_days-1))
    )t1
)t2
group by t2.recent_days,t2.source,t2.target;

-- 用户变动统计

insert overwrite table ads_user_change
select *
from ads_user_change
union
select c.dt,
       c.user_churn_count,
       b.user_back_count
from (select '${do_date}' as dt,
             count(1)        user_churn_count
      from dws_user_user_login_td
      where dt = '${do_date}'
        and login_date_last = date_add('${do_date}', -7)) c -- 昨日流失的用户
         join
     (select count(1)        user_back_count,
             '${do_date}' as dt
      from (
               -- 第一步查询历史流失用户
               select user_id
               from dws_user_user_login_td
               where dt = date_add('${do_date}', -1)
                 and login_date_last >= date_add('${do_date}', -8)) t1 -- 前日历史中全部的流失用户
               inner join
           -- 第二步查询最近7天内变成活跃的用户
               (select user_id
                from dws_user_user_login_td
                where dt = '${do_date}'
                  and login_date_last = '${do_date}') t2  -- 昨日活跃的用户
           on t1.user_id = t2.user_id) b -- 回流用户
         on c.dt = b.dt;

-- 用户留存分析

insert overwrite table ads_user_retention
select * from ads_user_retention -- 将历史数据查出来
union

select
    '${do_date}' as dt,
    login_date_first as create_date,
    datediff('${do_date}',login_date_first) retention_days,
    sum(if(login_date_last='${do_date}',1,0)) retention_count,
    count(1) new_user_count,
    cast(sum(if(login_date_last='${do_date}',1,0)) / count(1) as decimal(16,2)) retention_rate
    from
(
    select
        user_id,
        date_id login_date_first
    from dwd_user_register_inc
    where dt >= date_add('${do_date}',-7) and dt<'${do_date}'
) t1 -- 最近7天的新增用户数

join
(
    select user_id,login_date_last from dws_user_user_login_td where dt = '${do_date}'
) t2 -- 历史的登录用户

on t1.user_id = t2.user_id
group by login_date_first;

-- 用户新增活跃统计

insert overwrite table ads_user_stats
select * from ads_user_stats
union
select
    '${do_date}' as dt,
    n.recent_days,
    n.new_user_count,
    a.active_user_count
from
(
    select
        recent_days,
        sum(if(date_id >= date_add('${do_date}',-(tmp.recent_days-1)),1,0)) new_user_count
    from dwd_user_register_inc lateral view explode(array(1,7,30)) tmp as recent_days
    where dt >= date_add('${do_date}',-30)
    group by recent_days
) n -- 新增用户统计
join
(
    select
        recent_days,
        sum(if(login_date_last >= date_add('${do_date}',-(tmp.recent_days-1)),1,0)) active_user_count
    from dws_user_user_login_td lateral view explode(array(1,7,30)) tmp as recent_days
    where dt='${do_date}'
    group by tmp.recent_days
)a -- 活跃用户统计
on n.recent_days = a.recent_days;
-- 用户行为漏斗分析

insert overwrite table ads_user_action
select * from ads_user_action
union -- 会做去重
      -- union all 包括重复行
select
    '${do_date}' as dt,
    p.recent_days,
    p.home_count,
    p.good_detail_count,
    c.cart_add_count,
    o.order_count,
    s.payment_count
    from
    (

        select
            1 as recent_days,
            sum(if(page_id = 'home',1,0)) home_count,
            sum(if(page_id = 'good_detail',1,0)) good_detail_count
        from dws_traffic_visitor_page_page_view_1d
        where dt = '${do_date}'
        and page_id in ('home', 'good_detail') -- 最近1日首页浏览统计以及商品详情页的统计
        union all
        select
            recent_days,
            sum(if(page_id = 'home' and view_count > 0,1,0)) home_count,
            sum(if(page_id = 'good_detail' and view_count > 0,1,0)) good_detail_count
            from
        (
            select
                recent_days,
                page_id,
                case recent_days
                    when 7 then view_count_7d
                    when 30 then view_count_30d
                end view_count
            from dws_traffic_visitor_page_page_view_nd lateral view explode(array(7,30)) tmp as recent_days
            where dt='${do_date}'
            and page_id in ('home', 'good_detail') -- 统计周期以及页面ID作为一行统计页面的访问次数
         )p1 group by recent_days -- 以统计周期【7,30】分组，统计每个页面的访客统计
    ) p  -- 统计周期【1,7,30】-访问首页和商品详情的人数
    join
    (
        select
            1 as recent_days,
            count(1) cart_add_count
        from dws_trade_user_cart_add_1d
        where dt = '${do_date}' -- 最近1日的加购人数统计
        union all
        select
            recent_days,
            sum(if(cart_add_count > 0,1,0)) cart_add_count
        from
        (
            select
                recent_days,
                case recent_days
                    when 7 then cart_add_count_7d
                    when 30 then cart_add_count_30d
                end cart_add_count
            from dws_trade_user_cart_add_nd lateral view explode(array(7,30)) tmp as recent_days
            where dt = '${do_date}' -- 用户纬度最近7天，最近30天加购的次数
        ) c1
        group by c1.recent_days -- 统计周期【7,30】对应的加购人数
    ) c  -- 统计周期【1,7,30】-加购人数
    on p.recent_days = c.recent_days
    join
    (
        select
            1 as recent_days,
            count(1) order_count
        from dws_trade_user_order_1d
        where dt = '${do_date}' -- 最近1日的下单的人数统计
        union all
        select
            t.recent_days,
            sum(if(t.order_count > 0,1,0)) order_count
        from
        (
            select
                recent_days,
                case recent_days
                    when 7 then order_count_7d
                    when 30 then order_count_30d
                end order_count
            from dws_trade_user_order_nd lateral view explode(array(7,30)) tmp as recent_days
            where dt = '${do_date}' -- 用户纬度统计7天和30天的下单的单数
        )t group by t.recent_days -- 分组实现7,30周期内用户数【下单的用户数】
    ) o
    on p.recent_days = o.recent_days
    join
    (
        select
            1 as recent_days,
            count(1) payment_count
        from dws_trade_user_payment_1d
        where dt = '${do_date}' -- 最近1日的支付成功的人数统计
        union all
        select
            s1.recent_days,
            sum(if(payment_count>0,1,0)) payment_count
        from
        (
            select
                recent_days,
                case recent_days
                    when 7 then payment_count_7d
                    when 30 then payment_count_30d
                end payment_count
            from dws_trade_user_payment_nd lateral view explode(array(7,30)) tmp as recent_days
            where dt = '${do_date}' --用户纬度最近7/30支付成功的统计
        ) s1
        group by s1.recent_days
    ) s
    on p.recent_days = s.recent_days;

-- 最近7/30日各品牌复购率

insert overwrite table ads_good_repeat_purchase_by_tm
select * from ads_good_repeat_purchase_by_tm
union
select
    '${do_date}' as dt,
    t2.recent_days,
    tm_id,
    tm_name,
    cast(sum(if(order_count>=2,1,0)) / sum(if(order_count>=1,1,0)) as decimal(16,2)) repeat_rate
from
(
    select
        recent_days,
        user_id,
        tm_id,
        tm_name,
        sum(order_count) as order_count
    from
    (
        select
            recent_days,
            user_id,
            tm_id,
            tm_name,
            case recent_days
                when 7 then order_count_7d
                when 30 then order_count_30d
            end order_count
        from dws_trade_user_sku_order_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt = '${do_date}'
    ) t1 -- 仅仅查出来符合条件的订单信息【用户商品纬度】
    group by recent_days,user_id,tm_id,tm_name
) t2 -- 每个用户针对每个品牌，每个统计周期内的下单数量
group by t2.recent_days,t2.tm_name,t2.tm_id;

-- 各品牌商品交易统计
insert overwrite table ads_good_trade_stats_by_tm
select * from ads_good_trade_stats_by_tm
union
select
    '${do_date}' as dt,
    nvl(o.recent_days,r.recent_days),
    nvl(o.tm_id,r.tm_id),
    nvl(o.tm_name,r.tm_name),
    nvl(o.order_count,0),
    nvl(o.order_user_count,0),
    nvl(r.order_refund_count,0),
    nvl(r.order_refund_user_count,0) -- nvl可以让我们join后的数据不为null，而是默认值
from
(
    select
        1 as recent_days,
        tm_id,
        tm_name,
        sum(order_count_1d) as order_count,
        count(distinct user_id) as order_user_count
    from dws_trade_user_sku_order_1d
    where dt = '${do_date}'
    group by tm_id,tm_name
    union all
    select
        o1.recent_days,
        tm_id,
        tm_name,
        sum(order_count) as order_count,
        count(distinct if(order_count>0,user_id,null)) as order_user_count
    from
    (
        select
            tmp.recent_days,
            user_id,
            tm_id,
            tm_name,
            case recent_days
                when 7 then order_count_7d
                when 30 then order_count_30d
            end order_count
        from dws_trade_user_sku_order_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt = '${do_date}'
    ) o1
    group by recent_days,tm_id,tm_name
) o
full outer join
(
    select
        1 as recent_days,
        tm_id,
        tm_name,
        sum(order_refund_count_1d) order_refund_count,
        count(distinct user_id) order_refund_user_count
    from dws_trade_user_sku_order_refund_1d
    where dt = '${do_date}'
    group by tm_id,tm_name
    union all
    select
        r1.recent_days,
        tm_id,
        tm_name,
        sum(order_refund_count),
        count(distinct if(order_refund_count>0,user_id,null)) -- TODO 待测试
    from
    (
        select
            recent_days,
            user_id,
            tm_id,
            tm_name,
            case recent_days
                when 7 then order_refund_count_7d
                when 30 then order_refund_count_30d
            end order_refund_count
        from dws_trade_user_sku_order_refund_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt = '${do_date}'
    ) r1
    group by r1.recent_days,r1.tm_id,r1.tm_name
) r
on o.recent_days = r.recent_days
and o.tm_id = r.tm_id
and o.tm_name = r.tm_name;

-- 交易综合统计
insert overwrite table ads_trade_stats
select * from ads_trade_stats
union
select
    '${do_date}' as dt,
    nvl(o.recent_days,r.recent_days),
    nvl(o.order_count,0),
    nvl(o.order_user_count,0),
    nvl(o.order_original_amount,0),
    nvl(o.order_total_amount,0),
    nvl(r.order_refund_count,0),
    nvl(r.order_refund_user_count,0)
from
(
    select
        1 as recent_days,
        sum(order_count_1d) order_count,
        count(1)    order_user_count,
        sum(order_original_amount_1d) order_original_amount,
        sum(order_total_amount_1d) order_total_amount
    from dws_trade_user_order_1d
    where dt = '${do_date}' -- 最近1天的订单统计
    union all
    select
        o1.recent_days,
        sum(order_count) as order_count,
        sum(if(order_count>0,1,0)) order_user_count,
        sum(order_original_amount) as order_original_amount,
        sum(order_total_amount) as order_total_amount
    from
    (
        select
            tmp.recent_days,
            case recent_days
                when 7 then order_count_7d
                when 30 then order_count_30d
            end order_count,
            case recent_days
                when 7 then order_original_amount_7d
                when 30 then order_original_amount_30d
            end order_original_amount,
            case recent_days
                when 7 then order_total_amount_7d
                when 30 then order_total_amount_30d
            end order_total_amount
        from dws_trade_user_order_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt = '${do_date}'
    ) o1 group by o1.recent_days -- 最近7/30天的订单统计
) o -- 最近n日下单统计 TODO 是否包含退单
-- join
full outer join
(
    select
        1 as recent_days,
        sum(order_refund_count_1d) order_refund_count,
        count(1) order_refund_user_count
    from dws_trade_user_order_refund_1d
    where dt = '${do_date}'
    union all
    select
        r1.recent_days,
        sum(order_refund_count) as order_refund_count,
        sum(if(order_refund_count>0,1,0)) order_refund_user_count
    from
    (
        select
            tmp.recent_days,
            case recent_days
                when 7 then order_refund_count_7d
                when 30 then order_refund_count_30d
            end order_refund_count
        from dws_trade_user_order_refund_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt = '${do_date}'
    ) r1 group by r1.recent_days
) r
on o.recent_days = r.recent_days;

-- 优惠券补贴率
insert overwrite table ads_coupon_subsidy_stats
select * from ads_coupon_subsidy_stats
union
select
    '${do_date}' as dt,
    c.recent_days,
    c.coupon_id,
    c.coupon_name,
    c.start_date,
    c.coupon_rule as rule_name,
    cast(c.order_coupon_amount/c.order_original_amount as decimal(16,2)) subsidy_rate
from
(
    select
        tmp.recent_days,
        coupon_id,
        coupon_name,
        start_date,
        coupon_rule,
        case recent_days
            when 7 then order_coupon_amount_7d
            when 30 then order_coupon_amount_30d
        end order_coupon_amount,
        case recent_days
            when 7 then order_original_amount_7d
            when 30 then order_original_amount_30d
        end order_original_amount
    from dws_trade_coupon_order_nd lateral view explode(array(7,30)) tmp as recent_days
    where dt = '${do_date}'
) c group by c.recent_days,c.coupon_id,c.coupon_name,c.start_date,c.coupon_rule;

-- 各分类商品购物车存量Top10
insert overwrite table ads_good_cart_num_top_by_cate
select * from ads_good_cart_num_top_by_cate
union
select
    '${do_date}' as dt,
    f.category1_id,
    f.category1_name,
    f.category2_id,
    f.category2_name,
    f.category3_id,
    f.category3_name,
    f.id,
    f.sku_name,
    f.sku_num,
    f.rk
from
(
    select
        id,
        sku_name,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        c.sku_num,
        rank() over (partition by category1_id,category2_id,category3_id order by c.sku_num desc ) rk --注意
    from
    (
        select * from
        (
            select
                sku_id,
                sum(sku_num) as sku_num
            from dwd_trade_cart_full
            where dt = '${do_date}'
            group by sku_id
        ) c1
        left join
        (
            select
                id,
                sku_name,
                category1_id,
                category1_name,
                category2_id,
                category2_name,
                category3_id,
                category3_name
            from dim_sku_full
            where dt = '${do_date}'
        ) k1 on c1.sku_id = k1.id
    ) c
) f
where f.rk <= 10;

-- 最近30天发布的活动的补贴率
-- 数据加载
insert overwrite table ads_activity_subsidy_stats
select * from ads_activity_subsidy_stats
union
select
    '${do_date}' as dt,
    c.recent_days,
    c.activity_id,
    c.activity_name,
    c.start_date,
    c.activity_rule as rule_name,
    cast(c.order_activity_amount/c.order_original_amount as decimal(16,2)) subsidy_rate
from
(
    select
        tmp.recent_days,
        activity_id,
        activity_name,
        start_date,
        activity_rule,
        case recent_days
            when 7 then order_activity_amount_7d
            when 30 then order_activity_amount_30d
        end order_activity_amount,
        case recent_days
            when 7 then order_activity_amount_7d
            when 30 then order_activity_amount_30d
        end order_original_amount
    from dws_trade_activity_order_nd lateral view explode(array(7,30)) tmp as recent_days
    where dt = '${do_date}'
) c group by c.recent_days,c.activity_id,c.activity_name,c.start_date,c.activity_rule;

-- 新增交易用户统计
insert overwrite table ads_user_new_buyer_stats
select * from ads_user_new_buyer_stats
union
select
    '${do_date}',
    odr.recent_days,
    new_order_user_count,
    new_payment_user_count
from
(
    select
        recent_days,
        sum(if(order_date_first>=date_add('${do_date}',-recent_days+1),1,0)) new_order_user_count
    from dws_trade_user_order_td lateral view explode(array(1,7,30)) tmp as recent_days
    where dt='${do_date}'
    group by recent_days
)odr
join
(
    select
        recent_days,
        sum(if(payment_date_first>=date_add('${do_date}',-recent_days+1),1,0)) new_payment_user_count
    from dws_trade_user_payment_td lateral view explode(array(1,7,30)) tmp as recent_days
    where dt='${do_date}'
    group by recent_days
)pay
on odr.recent_days=pay.recent_days;

-- 各省份交易统计
insert overwrite table ads_trade_order_by_province
select * from ads_trade_order_by_province
union
select
    '${do_date}' as dt,
    1 as recent_days,
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    order_count_1d,
    order_total_amount_1d
from dws_trade_province_order_1d
where dt='${do_date}'
union
select
    '${do_date}' dt,
    recent_days,
    province_id,
    province_name,
    area_code,
    iso_code,
    iso_3166_2,
    sum(order_count),
    sum(order_total_amount)
from
(
    select
        recent_days,
        province_id,
        province_name,
        area_code,
        iso_code,
        iso_3166_2,
        case recent_days
            when 7 then order_count_7d
            when 30 then order_count_30d
        end order_count,
        case recent_days
            when 7 then order_total_amount_7d
            when 30 then order_total_amount_30d
        end order_total_amount
    from dws_trade_province_order_nd lateral view explode(array(7,30)) tmp as recent_days
    where dt='${do_date}'
)t1
group by recent_days,province_id,province_name,area_code,iso_code,iso_3166_2;

-- 各品类商品交易统计
insert overwrite table ads_good_trade_stats_by_cate
select * from ads_good_trade_stats_by_cate
union
select
    '${do_date}' as dt,
    nvl(odr.recent_days,refund.recent_days),
    nvl(odr.category1_id,refund.category1_id),
    nvl(odr.category1_name,refund.category1_name),
    nvl(odr.category2_id,refund.category2_id),
    nvl(odr.category2_name,refund.category2_name),
    nvl(odr.category3_id,refund.category3_id),
    nvl(odr.category3_name,refund.category3_name),
    nvl(order_count,0),
    nvl(order_user_count,0),
    nvl(order_refund_count,0),
    nvl(order_refund_user_count,0)
from
(
    select
        1 recent_days,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        sum(order_count_1d) order_count,
        count(distinct(user_id)) order_user_count
    from dws_trade_user_sku_order_1d
    where dt='${do_date}'
    group by category1_id,category1_name,category2_id,category2_name,category3_id,category3_name
    union all
    select
        recent_days,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        sum(order_count),
        count(distinct(if(order_count>0,user_id,null)))
    from
    (
        select
            recent_days,
            user_id,
            category1_id,
            category1_name,
            category2_id,
            category2_name,
            category3_id,
            category3_name,
            case recent_days
                when 7 then order_count_7d
                when 30 then order_count_30d
            end order_count
        from dws_trade_user_sku_order_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt='${do_date}'
    )t1
    group by recent_days,category1_id,category1_name,category2_id,category2_name,category3_id,category3_name
)odr
full outer join
(
    select
        1 recent_days,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        sum(order_refund_count_1d) order_refund_count,
        count(distinct(user_id)) order_refund_user_count
    from dws_trade_user_sku_order_refund_1d
    where dt='${do_date}'
    group by category1_id,category1_name,category2_id,category2_name,category3_id,category3_name
    union all
    select
        recent_days,
        category1_id,
        category1_name,
        category2_id,
        category2_name,
        category3_id,
        category3_name,
        sum(order_refund_count),
        count(distinct(if(order_refund_count>0,user_id,null)))
    from
    (
        select
            recent_days,
            user_id,
            category1_id,
            category1_name,
            category2_id,
            category2_name,
            category3_id,
            category3_name,
            case recent_days
                when 7 then order_refund_count_7d
                when 30 then order_refund_count_30d
            end order_refund_count
        from dws_trade_user_sku_order_refund_nd lateral view explode(array(7,30)) tmp as recent_days
        where dt='${do_date}'
    )t1
    group by recent_days,category1_id,category1_name,category2_id,category2_name,category3_id,category3_name
)refund
on odr.recent_days=refund.recent_days
and odr.category1_id=refund.category1_id
and odr.category1_name=refund.category1_name
and odr.category2_id=refund.category2_id
and odr.category2_name=refund.category2_name
and odr.category3_id=refund.category3_id
and odr.category3_name=refund.category3_name;