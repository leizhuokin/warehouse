-- 最近1日
use ${app};
-- 交易域
-- 加购：用户
drop table if exists dws_trade_user_cart_add_1d;
create external table dws_trade_user_cart_add_1d
(
    user_id string comment '用户ID',
    cart_add_count_1d bigint comment '最近1日加购次数',
    cart_add_num_1d bigint comment '最近1日加购商品的件数'
)comment '交易域用户粒度加购最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_cart_add_1d'
tblproperties ('orc.compress' = 'snappy');

-- 订单：用户商品粒度
drop table if exists dws_trade_user_sku_order_1d;
create external table dws_trade_user_sku_order_1d
(
    user_id string comment '用户ID',
    sku_id  string comment '商品ID',
    sku_name string comment '商品的名称',
    category1_id string comment '一级分类ID',
    category1_name string comment '一级分类名称',
    category2_id string comment '二级分类ID',
    category2_name string comment '二级分类ID',
    category3_id string comment '三级分类ID',
    category3_name string comment '三级分类ID',
    tm_id   string comment '品牌ID',
    tm_name string comment '品牌名称',
    order_count_1d bigint comment '最近1日下单次数',
    order_num_1d bigint comment '最近1日下单件数',
    order_original_amount_1d decimal(16,2) comment '最近1日下单原始金额',
    order_activity_amount_1d decimal(16,2) comment '最近1日下单活动优惠的金额',
    order_coupon_amount_1d decimal(16,2) comment '最近1日下单件优惠券优惠的金额',
    order_total_amount_1d decimal(16,2) comment '最近1日下单最终金额'
)comment '交易域中用户商品粒度订单的最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_sku_order_1d'
tblproperties ('orc.compress' = 'snappy');

-- 退单：用户商品粒度
drop table if exists dws_trade_user_sku_order_refund_1d;
create external table dws_trade_user_sku_order_refund_1d
(
    user_id string comment '用户ID',
    sku_id  string comment '商品ID',
    sku_name string comment '商品的名称',
    category1_id string comment '一级分类ID',
    category1_name string comment '一级分类名称',
    category2_id string comment '二级分类ID',
    category2_name string comment '二级分类ID',
    category3_id string comment '三级分类ID',
    category3_name string comment '三级分类ID',
    tm_id   string comment '品牌ID',
    tm_name string comment '品牌名称',
    order_refund_count_1d bigint comment '最近1日退单次数',
    order_refund_num_1d bigint comment '最近1日退单件数',
    order_refund_amount_1d bigint comment '最近1日退单金额'
)comment '交易域中用户商品粒度退单的最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_sku_order_refund_1d'
tblproperties ('orc.compress' = 'snappy');

-- 用户粒度订单
drop table if exists dws_trade_user_order_1d;
create external table dws_trade_user_order_1d
(
    user_id string comment '用户ID',
    order_count_1d  bigint comment '最近1日下单次数',
    order_num_1d  bigint comment '最近1日下单商品件数',
    order_original_amount_1d  decimal(16,2) comment '最近1日下单原始金额',
    order_activity_amount_1d  decimal(16,2) comment '最近1日下单活动优惠金额',
    order_coupon_amount_1d  decimal(16,2) comment '最近1日下单优惠券优惠金额',
    order_total_amount_1d  decimal(16,2) comment '最近1日下单最终支付的金额'
)comment '交易域中用户粒度订单的最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_order_1d'
tblproperties ('orc.compress' = 'snappy');

-- 省份粒度的订单最近1日汇总表
drop table if exists dws_trade_province_order_1d;
create external table dws_trade_province_order_1d
(
    province_id string comment '省份ID',
    province_name string comment '省份名称',
    area_code string comment '地区编码',
    iso_code string comment '旧版ISO-3166-2编码',
    iso_3166_2 string comment '新版ISO-3166-2编码',
    order_count_1d string comment '最近1日下单次数',
    order_num_1d  bigint comment '最近1日下单商品件数',
    order_original_amount_1d  decimal(16,2) comment '最近1日下单原始金额',
    order_activity_amount_1d  decimal(16,2) comment '最近1日下单活动优惠金额',
    order_coupon_amount_1d  decimal(16,2) comment '最近1日下单优惠券优惠金额',
    order_total_amount_1d  decimal(16,2) comment '最近1日下单最终支付的金额'
) comment '交易域省份粒度订单最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_province_order_1d'
tblproperties ('orc.compress' = 'snappy');

-- 退单：用户粒度
drop table if exists dws_trade_user_order_refund_1d;
create external table dws_trade_user_order_refund_1d
(
    user_id string comment '用户ID',
    order_refund_count_1d bigint comment '最近1日退单次数',
    order_refund_num_1d bigint comment '最近1日退单件数',
    order_refund_amount_1d bigint comment '最近1日退单金额'
)comment '交易域中用户粒度退单的最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_order_refund_1d'
tblproperties ('orc.compress' = 'snappy');

--交易域用户粒度支付最近1日汇总
drop table if exists dws_trade_user_payment_1d;
create external table dws_trade_user_payment_1d
(
    user_id string comment '用户ID',
    payment_count_1d bigint comment '最近1日的支付次数',
    payment_num_1d bigint comment '最近1日的支付商品的件数',
    payment_amount_1d decimal(16,2) comment '最近1日的支付的总金额'
)
comment '交易域用户粒度支付最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_payment_1d'
tblproperties ('orc.compress' = 'snappy');

-- 流量域
-- 流量域会话粒度页面浏览最近1日汇总
drop table if exists dws_traffic_session_page_view_1d;
create external table dws_traffic_session_page_view_1d
(
    session_id string comment '会话ID',
    mid_id string comment '设备ID',
    brand string comment '手机品牌',
    model string comment '手机型号',
    operate_system string comment '操作系统',
    version_code string comment 'APP 版本号',
    channel string comment '渠道',
    during_time_1d bigint comment '最近1日访问时长',
    page_count_1d bigint comment '最近1日访问页面数'
)
comment '流量域会话粒度页面浏览最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_traffic_session_page_view_1d'
tblproperties ('orc.compress' = 'snappy');

-- 流量域访客页面粒度页面浏览最近1日汇总
drop table if exists dws_traffic_visitor_page_page_view_1d;
create external table dws_traffic_visitor_page_page_view_1d
(
    mid_id string comment '访客ID',
    page_id string comment '页面ID',
    brand string comment '手机品牌',
    model string comment '手机型号',
    operate_system string comment '操作系统',
    during_time_1d bigint comment '最近1日访问时长',
    view_count_1d bigint comment '最近1日访问次数'
)
comment '流量域访客页面粒度页面浏览最近1日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_traffic_visitor_page_page_view_1d'
tblproperties ('orc.compress' = 'snappy');


-- 最近n日【7,30】
-- 交易域
-- 交易域用户商品粒度订单最近n日汇总
drop table if exists dws_trade_user_sku_order_nd;
create external table dws_trade_user_sku_order_nd
(
    user_id string comment '用户ID',
    sku_id string comment '商品ID',
    sku_name string comment '商品的名称',
    category1_id string comment '一级分类ID',
    category1_name string comment '一级分类名称',
    category2_id string comment '二级分类ID',
    category2_name string comment '二级分类ID',
    category3_id string comment '三级分类ID',
    category3_name string comment '三级分类ID',
    tm_id   string comment '品牌ID',
    tm_name string comment '品牌名称',
    order_count_7d bigint comment '最近7日下单次数',
    order_num_7d bigint comment '最近7日下单件数',
    order_original_amount_7d decimal(16,2) comment '最近7日下单原始金额',
    order_activity_amount_7d decimal(16,2) comment '最近7日下单活动优惠的金额',
    order_coupon_amount_7d decimal(16,2) comment '最近7日下单件优惠券优惠的金额',
    order_total_amount_7d decimal(16,2) comment '最近7日下单最终金额',
    order_count_30d bigint comment '最近30日下单次数',
    order_num_30d bigint comment '最近30日下单件数',
    order_original_amount_30d decimal(16,2) comment '最近30日下单原始金额',
    order_activity_amount_30d decimal(16,2) comment '最近30日下单活动优惠的金额',
    order_coupon_amount_30d decimal(16,2) comment '最近30日下单件优惠券优惠的金额',
    order_total_amount_30d decimal(16,2) comment '最近30日下单最终金额'
)
comment '交易域用户商品粒度订单最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_sku_order_nd'
tblproperties ('orc.compress' = 'snappy');

-- 交易域用户商品粒度退单最近n日汇总
drop table if exists dws_trade_user_sku_order_refund_nd;
create external table dws_trade_user_sku_order_refund_nd
(
    user_id string comment '用户ID',
    sku_id  string comment '商品ID',
    sku_name string comment '商品的名称',
    category1_id string comment '一级分类ID',
    category1_name string comment '一级分类名称',
    category2_id string comment '二级分类ID',
    category2_name string comment '二级分类ID',
    category3_id string comment '三级分类ID',
    category3_name string comment '三级分类ID',
    tm_id   string comment '品牌ID',
    tm_name string comment '品牌名称',
    order_refund_count_7d bigint comment '最近7日退单次数',
    order_refund_num_7d bigint comment '最近7日退单件数',
    order_refund_amount_7d bigint comment '最近7日退单金额',
    order_refund_count_30d bigint comment '最近30日退单次数',
    order_refund_num_30d bigint comment '最近30日退单件数',
    order_refund_amount_30d bigint comment '最近30日退单金额'
)
comment '交易域用户商品粒度退单最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_sku_order_refund_nd'
tblproperties ('orc.compress' = 'snappy');


-- 交易域用户粒度订单
drop table if exists dws_trade_user_order_nd;
create external table dws_trade_user_order_nd
(
    user_id string comment '用户ID',
    order_count_7d  bigint comment '最近7日下单次数',
    order_num_7d  bigint comment '最近7日下单商品件数',
    order_original_amount_7d  decimal(16,2) comment '最近7日下单原始金额',
    order_activity_amount_7d  decimal(16,2) comment '最近7日下单活动优惠金额',
    order_coupon_amount_7d  decimal(16,2) comment '最近7日下单优惠券优惠金额',
    order_total_amount_7d  decimal(16,2) comment '最近7日下单最终支付的金额',
    order_count_30d  bigint comment '最近30日下单次数',
    order_num_30d  bigint comment '最近30日下单商品件数',
    order_original_amount_30d  decimal(16,2) comment '最近30日下单原始金额',
    order_activity_amount_30d  decimal(16,2) comment '最近30日下单活动优惠金额',
    order_coupon_amount_30d  decimal(16,2) comment '最近30日下单优惠券优惠金额',
    order_total_amount_30d  decimal(16,2) comment '最近30日下单最终支付的金额'
)
comment '交易域用户粒度订单最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_order_nd'
tblproperties ('orc.compress' = 'snappy');

-- 交易域用户粒度退单
drop table if exists dws_trade_user_order_refund_nd;
create external table dws_trade_user_order_refund_nd
(
    user_id string comment '用户ID',
    order_refund_count_7d bigint comment '最近7日退单次数',
    order_refund_num_7d bigint comment '最近7日退单件数',
    order_refund_amount_7d bigint comment '最近7日退单金额',
    order_refund_count_30d bigint comment '最近30日退单次数',
    order_refund_num_30d bigint comment '最近30日退单件数',
    order_refund_amount_30d bigint comment '最近30日退单金额'
)
comment '交易域用户粒度退单最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_order_refund_nd'
tblproperties ('orc.compress' = 'snappy');

-- 交易域用户粒度加购
drop table if exists dws_trade_user_cart_add_nd;
create external table dws_trade_user_cart_add_nd
(
    user_id string comment '用户ID',
    cart_add_count_7d bigint comment '最近7日加购次数',
    cart_add_num_7d bigint comment '最近7日加购商品的件数',
    cart_add_count_30d bigint comment '最近30日加购次数',
    cart_add_num_30d bigint comment '最近30日加购商品的件数'
)
comment '交易域用户粒度加购最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_cart_add_nd'
tblproperties ('orc.compress' = 'snappy');


-- 交易域用户粒度支付
drop table if exists dws_trade_user_payment_nd;
create external table dws_trade_user_payment_nd
(
    user_id string comment '用户ID',
    payment_count_7d bigint comment '最近7日的支付次数',
    payment_num_7d bigint comment '最近7日的支付商品的件数',
    payment_amount_7d decimal(16,2) comment '最近7日的支付的总金额',
    payment_count_30d bigint comment '最近30日的支付次数',
    payment_num_30d bigint comment '最近30日的支付商品的件数',
    payment_amount_30d decimal(16,2) comment '最近30日的支付的总金额'
)
comment '交易域用户粒度支付最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_user_payment_nd'
tblproperties ('orc.compress' = 'snappy');

-- 交易域省份粒度订单
drop table if exists dws_trade_province_order_nd;
create external table dws_trade_province_order_nd
(
    province_id string comment '省份ID',
    province_name string comment '省份名称',
    area_code string comment '地区编码',
    iso_code string comment '旧版ISO-3166-2编码',
    iso_3166_2 string comment '新版ISO-3166-2编码',
    order_count_7d string comment '最近7日下单次数',
    order_num_7d  bigint comment '最近7日下单商品件数',
    order_original_amount_7d  decimal(16,2) comment '最近7日下单原始金额',
    order_activity_amount_7d  decimal(16,2) comment '最近7日下单活动优惠金额',
    order_coupon_amount_7d  decimal(16,2) comment '最近7日下单优惠券优惠金额',
    order_total_amount_7d  decimal(16,2) comment '最近7日下单最终支付的金额',
    order_count_30d string comment '最近30日下单次数',
    order_num_30d  bigint comment '最近30日下单商品件数',
    order_original_amount_30d  decimal(16,2) comment '最近30日下单原始金额',
    order_activity_amount_30d  decimal(16,2) comment '最近30日下单活动优惠金额',
    order_coupon_amount_30d  decimal(16,2) comment '最近30日下单优惠券优惠金额',
    order_total_amount_30d  decimal(16,2) comment '最近30日下单最终支付的金额'
)
comment '交易域省份粒度订单最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_province_order_nd'
tblproperties ('orc.compress' = 'snappy');

-- 交易域优惠券粒度订单
drop table if exists dws_trade_coupon_order_nd;
create external table dws_trade_coupon_order_nd
(
    coupon_id string comment '优惠券ID',
    coupon_name string comment '优惠券名称',
    coupon_type_code string comment '优惠券类型',
    coupon_type_name string comment '优惠券类型的名称',
    coupon_rule string comment '优惠券使用规则',
    start_date string comment '优惠券发布日期',
    taken_count bigint comment '优惠券的领用次数',
    order_count_7d bigint comment '最近7日使用该优惠券的订单',
    order_original_amount_7d decimal(16,2) comment '最近7日订单原始金额',
    order_coupon_amount_7d decimal(16,2) comment '最近7日订单优惠券优惠金额',
    order_total_amount_7d decimal(16,2) comment '最近7日订单实际支付金额',
    order_count_30d bigint comment '最近30日使用该优惠券的订单',
    order_original_amount_30d decimal(16,2) comment '最近30日订单原始金额',
    order_coupon_amount_30d decimal(16,2) comment '最近30日订单优惠券优惠金额',
    order_total_amount_30d decimal(16,2) comment '最近30日订单实际支付金额'
)
comment '交易域优惠券粒度订单最近n日汇总事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dws/dws_trade_coupon_order_nd'
tblproperties ('orc.compress' = 'snappy');


-- 交易域活动粒度订单
drop table if exists dws_trade_activity_order_nd;
create external table dws_trade_activity_order_nd
(
    activity_id                 string comment '活动id',
    activity_name               string comment '活动名称',
    activity_type_code          string comment '活动类型编码',
    activity_type_name          string comment '活动类型名称',
    activity_rule               string comment '活动规则',
    start_date                  string comment '发布日期',
    order_count_7d              bigint comment '最近7日参与该活动的订单',
    order_original_amount_7d    decimal(16, 2) comment '最近7日参与活动订单原始金额',
    order_activity_amount_7d    decimal(16, 2) comment '最近7日参与活动订单优惠金额',
    order_total_amount_7d       decimal(16, 2) comment '最近7日参与活动订单最终金额',
    order_count_30d             bigint comment '最近30日参与该活动的订单',
    order_original_amount_30d   decimal(16, 2) comment '最近30日参与活动订单原始金额',
    order_activity_amount_30d   decimal(16, 2) comment '最近30日参与活动订单优惠金额',
    order_total_amount_30d      decimal(16, 2) comment '最近30日参与活动订单最终金额'
) comment '交易域活动粒度订单最近n日汇总事实表'
    partitioned by (dt string)
    row format delimited fields terminated by '\t'
    stored as orc
    location '/dw/commerce/dws/dws_trade_activity_order_nd'
    tblproperties ('orc.compress' = 'snappy');

-- 流量域
-- 流量域访客页面粒度页面浏览
drop table if exists dws_traffic_visitor_page_page_view_nd;
create external table dws_traffic_visitor_page_page_view_nd
(
    mid_id          string comment '访客id',
    brand           string comment '手机品牌',
    model           string comment '手机型号',
    operate_system  string comment '操作系统',
    page_id         string comment '页面id',
    during_time_7d  bigint comment '最近7日浏览时长',
    view_count_7d   bigint comment '最近7日访问次数',
    during_time_30d bigint comment '最近30日浏览时长',
    view_count_30d  bigint comment '最近30日访问次数'
) comment '流量域访客页面粒度页面浏览最近n日汇总事实表'
    partitioned by (dt string)
    row format delimited fields terminated by '\t'
    stored as orc
    location '/dw/commerce/dws/dws_traffic_visitor_page_page_view_nd'
    tblproperties ('orc.compress' = 'snappy');

-- 历史至今
-- 交易域
-- 用户粒度订单
drop table if exists dws_trade_user_order_td;
create external table dws_trade_user_order_td
(
    user_id                     string comment '用户id',
    order_date_first            string comment '首次下单日期',
    order_date_last             string comment '末次下单日期',
    order_count_td              bigint comment '下单次数',
    order_num_td                bigint comment '购买商品件数',
    order_original_amount_td    decimal(16,2) comment '原始金额',
    order_activity_amount_td    decimal(16,2) comment '活动优惠金额',
    order_coupon_amount_td      decimal(16,2) comment '优惠券优惠金额',
    order_total_amount_td       decimal(16,2) comment '最终金额'
) comment '交易域用户粒度订单历史至今汇总事实表'
    partitioned by (dt string)
    row format delimited fields terminated by '\t'
    stored as orc
    location '/dw/commerce/dws/dws_trade_user_order_td'
    tblproperties ('orc.compress' = 'snappy');

-- 用户粒度支付
drop table if exists dws_trade_user_payment_td;
create external table dws_trade_user_payment_td
(
    user_id            string comment '用户id',
    payment_date_first string comment '首次支付日期',
    payment_date_last  string comment '末次支付日期',
    payment_count_td   bigint comment '历史支付次数',
    payment_num_td     bigint comment '历史支付商品件数',
    payment_amount_td  decimal(16, 2) comment '历史支付金额'
) comment '交易域用户粒度支付历史至今汇总事实表'
    partitioned by (dt string)
    row format delimited fields terminated by '\t'
    stored as orc
    location '/dw/commerce/dws/dws_trade_user_payment_td'
    tblproperties ('orc.compress' = 'snappy');

-- 用户域
-- 用户粒度登录
drop table if exists dws_user_user_login_td;
create external table dws_user_user_login_td
(
    user_id         string comment '用户id',
    login_date_last string comment '末次登录日期',
    login_count_td  string comment '累计登录次数'
) comment '用户域用户粒度登录历史至今汇总事实表'
    partitioned by (dt string)
    row format delimited fields terminated by '\t'
    stored as orc
    location '/dw/commerce/dws/dws_user_user_login_td'
    tblproperties ('orc.compress' = 'snappy');
