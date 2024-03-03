use ${app};
-- 各渠道流量统计
drop table if exists ads_traffic_stats_by_channel;
create external table ads_traffic_stats_by_channel
(
    dt                  string comment '统计日期',
    recent_days         bigint comment '最近的天数:1:最近1天;7:最近7天;30:最近30天',
    channel             string comment '渠道',
    uv                  bigint comment '访客数',
    avg_duration_sec    bigint comment '会话平均停留时长，单位:秒',
    avg_page            bigint comment '会话平均浏览的页面数',
    session_count       bigint comment '会话数',
    bounce_rate         decimal(16,2) comment '跳出率'
)
comment '各渠道流量统计'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_traffic_stats_by_channel';

-- 路径分析
drop table if exists ads_traffic_page_path;
create external table ads_traffic_page_path
(
    dt          string comment '统计日期',
    recent_days bigint comment '最近的天数:1:最近1天;7:最近7天;30:最近30天',
    source      string comment '起始页面ID',
    target      string comment '最终跳转页面ID',
    path_count  bigint comment '跳转次数'
)
comment '路径分析'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_traffic_page_path';

-- 用户变动统计
drop table if exists ads_user_change;
create external table ads_user_change
(
    dt              string comment '统计日期',
    -- recent_days     bigint comment '最近天数：1,7,30',
    user_churn_count    bigint comment '流失用户统计',
    user_back_count    bigint comment '回流用户统计'
)
comment '用户变动统计'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_user_change';

-- 用户留存分析
drop table if exists ads_user_retention;
create external table ads_user_retention
(
    dt              string comment '统计日期',
    create_date     string comment '用户新增的日期',
    retention_days  bigint comment '截止统计日期留存天数',
    retention_count bigint comment '留存用户数',
    new_user_count  bigint comment '新增用户',
    retention_rate  decimal(16,2) comment '留存率'
)
comment '用户留存分析'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_user_retention';

-- 用户新增活跃统计
drop table if exists ads_user_stats;
create external table ads_user_stats
(
    dt                  string comment '统计日期',
    recent_days         bigint comment '统计周期：1,7,30',
    new_user_count      bigint comment '新增用户统计',
    active_user_count   bigint comment '活跃用户统计'
)
comment '用户新增活跃统计'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_user_stats';

-- 用户行为漏斗分析
drop table if exists ads_user_action;
create external table ads_user_action
(
    dt              string comment '统计日期', -- 2022-11-13
    recent_days     bigint comment '统计周期：1,7,30', -- lateral view explode(array(1,7,30)) tmp as recent_days
    home_count      bigint comment '首页浏览统计', -- dws_traffic_visitor_page....
    good_detail_count   bigint comment '商品详情页统计：人数', -- dws_traffic_visitor_page....
    cart_add_count      bigint comment '加购人数统计', -- dws_cart_add
    order_count      bigint comment '下单人数统计', -- dws_order
    payment_count      bigint comment '支付成功人数统计' -- dws_payment
)
comment '用户行为漏斗分析'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_user_action';

-- 最近7/30日各品牌复购率
drop table if exists ads_good_repeat_purchase_by_tm;
create external table ads_good_repeat_purchase_by_tm
(
    dt          string comment '统计日期',
    recent_days bigint comment '统计周期：7,30',
    tm_id       string comment '品牌ID',
    tm_name     string comment '品牌名称',
    repeat_rate decimal(16,2) comment '复购率'
)
comment '最近7/30日各品牌复购率'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_good_repeat_purchase_by_tm';

-- 各品牌商品交易统计
drop table if exists ads_good_trade_stats_by_tm;
create external table ads_good_trade_stats_by_tm
(
    dt                      string comment '统计日期',
    recent_days             bigint comment '统计周期',
    tm_id                   string comment '品牌ID',
    tm_name                 string comment '品牌名称',
    order_count             bigint comment '下单统计', -- user_order sum(order_count)
    order_user_count        bigint comment '下单人次', -- sum(if(  ,1,0))
    order_refund_count      bigint comment '退单统计', -- user_order_refund sum(order_count)
    order_refund_user_count bigint comment '退单人次'  -- sum(if(  ,1,0))
)
comment '各品牌商品交易统计'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_good_trade_stats_by_tm';

-- 交易综合统计

drop table if exists ads_trade_stats;
create external table ads_trade_stats
(
    dt                      string          comment '统计日期',
    recent_days             bigint          comment '统计周期：1,7,30',
    order_count             bigint          comment '订单数',
    order_user_count        bigint          comment '下单人数',
    order_original_count    decimal(16,2)   comment '订单的原始金额',
    order_total_count       decimal(16,2)   comment '订单的最终金额', -- dws_trade_user_order_1d,nd
    order_refund_count      bigint          comment '退单数',
    order_refund_user_count bigint          comment '退单人数'
)
comment '交易综合统计'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_trade_stats';

-- 优惠券补贴率
drop table if exists ads_coupon_subsidy_stats;
create external table ads_coupon_subsidy_stats
(
    dt              string          comment '统计日期',
    recent_days     string          comment '统计周期【7,30】',
    coupon_id       string          comment '优惠券ID',
    coupon_name     string          comment '优惠券名称',
    start_date      string          comment '优惠券发布日期',
    rule_name       string          comment '优惠券规则：满100减10',
    subsidy_rate    decimal(16,2)   comment '补贴率'
)
comment '优惠券补贴率'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_coupon_subsidy_stats';

-- 各分类商品购物车存量Top10
drop table if exists ads_good_cart_num_top_by_cate;
create external table ads_good_cart_num_top_by_cate
(
    dt                          string  comment '统计日期',
    category1_id                string  comment '一级分类ID',
    category1_name              string  comment '一级分类名称',
    category2_id                string  comment '二级分类ID',
    category2_name              string  comment '二级分类名称',
    category3_id                string  comment '三级分类ID',
    category3_name              string  comment '三级分类名称',
    sku_id                      string  comment '商品ID',
    sku_name                    string  comment '商品名称',
    cart_num                    string  comment '购物车中商品的数量',
    rk                          string  comment '排名'
)
comment '各分类商品购物车存量Top10'
row format delimited fields terminated by '\t'
location '/dw/commerce/ads/ads_good_cart_num_top_by_cate';

-- 最近30天发布的活动的补贴率
drop table if exists ads_activity_subsidy_stats;
create external table ads_activity_subsidy_stats
(
    dt            string comment '统计日期',
    recent_days   string comment '统计周期【7,30】',
    activity_id   string comment '活动id',
    activity_name string comment '活动名称',
    start_date    string comment '活动开始日期',
    rule_name     string comment '优惠券规则：满100减10',
    subsidy_rate  decimal(16, 2) comment '补贴率'
) comment '活动统计'
    row format delimited fields terminated by '\t'
    location '/dw/commerce/ads/ads_activity_subsidy_stats';

-- 新增交易用户统计
drop table if exists ads_user_new_buyer_stats;
create external table ads_user_new_buyer_stats
(
    dt                     string comment '统计日期',
    recent_days            bigint comment '最近天数,1:最近1天,7:最近7天,30:最近30天',
    new_order_user_count   bigint comment '新增下单人数',
    new_payment_user_count bigint comment '新增支付人数'
) comment '新增交易用户统计'
    row format delimited fields terminated by '\t'
    location '/dw/commerce/ads/ads_user_new_buyer_stats';

-- 各省份交易统计
drop table if exists ads_trade_order_by_province;
create external table ads_trade_order_by_province
(
    dt                 string comment '统计日期',
    recent_days        bigint comment '最近天数,1:最近1天,7:最近7天,30:最近30天',
    province_id        string comment '省份id',
    province_name      string comment '省份名称',
    area_code          string comment '地区编码',
    iso_code           string comment '国际标准地区编码',
    iso_code_3166_2    string comment '国际标准地区编码',
    order_count        bigint comment '订单数',
    order_total_amount decimal(16, 2) comment '订单金额'
) comment '各地区订单统计'
    row format delimited fields terminated by '\t'
    location '/dw/commerce/ads/ads_trade_order_by_province';

-- 各品类商品交易统计
drop table if exists ads_good_trade_stats_by_cate;
create external table ads_good_trade_stats_by_cate
(
    dt                      string comment '统计日期',
    recent_days             bigint comment '最近天数,1:最近1天,7:最近7天,30:最近30天',
    category1_id            string comment '一级分类id',
    category1_name          string comment '一级分类名称',
    category2_id            string comment '二级分类id',
    category2_name          string comment '二级分类名称',
    category3_id            string comment '三级分类id',
    category3_name          string comment '三级分类名称',
    order_count             bigint comment '订单数',
    order_user_count        bigint comment '订单人数',
    order_refund_count      bigint comment '退单数',
    order_refund_user_count bigint comment '退单人数'
) comment '各分类商品交易统计'
    row format delimited fields terminated by '\t'
    location '/dw/commerce/ads/ads_good_trade_stats_by_cate';