use ${app};
-- dwd层的设计
-- 加购事实表
drop table if exists dwd_trade_cart_add_inc;
create external table dwd_trade_cart_add_inc
(
    id string comment 'id',
    user_id string comment  '用户id',
    sku_id string comment '商品id',
    date_id string comment '时间id',
    create_time string comment '加购时间',
    source_id string comment '来源类型id',
    source_type_code string comment '来源类型编号',
    source_type_name string comment '来源类型名称',
    sku_num int comment '加购的件数'
) comment '交易域-加购事务-事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_trade_cart_add_inc'
tblproperties ('orc.compress' = 'snappy');
-- 下单事实表
drop table if exists dwd_trade_order_detail_inc;
create external table dwd_trade_order_detail_inc
(
    id string comment '编号',
    date_id string comment '下单日期id', -- 用于日期维表的关联
    user_id string comment '用户id',
    sku_id string comment '商品id',
    sku_num bigint comment '商品的数量',
    order_id string comment '订单id',
    province_id string comment '地区id',

    activity_id string comment '参与的活动id',
    activity_rule_id string comment '参与的活动规则id',
    coupon_id string comment '使用的优惠券id',

    create_time string comment '下单时间',
    source_id string comment '来源id',
    source_type_code string comment '来源类型编码',
    source_type_name string comment '来源类型的名称',

    split_total_amount decimal(16,2) comment '最终的价格',
    split_activity_amount decimal(16,2) comment '基于活动优惠的价格',
    split_coupon_amount decimal(16,2) comment '基于优惠券优惠的价格',
    split_original_amount decimal(16,2) comment '真实价格'
)comment '交易域-下单明细事务-事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_trade_order_detail_inc'
tblproperties ('orc.compress' = 'snappy');

-- 取消订单事实表
drop table if exists dwd_trade_order_cancel_detail_inc;
create external table dwd_trade_order_cancel_detail_inc
(
    id string comment '编号',
    date_id string comment '取消订单的日期id', -- 用于日期维表的关联
    user_id string comment '用户id',
    sku_id string comment '商品id',
    sku_num bigint comment '商品的数量',
    order_id string comment '订单id',
    province_id string comment '地区id',

    activity_id string comment '参与的活动id',
    activity_rule_id string comment '参与的活动规则id',
    coupon_id string comment '使用的优惠券id',

    cancel_time string comment '取消订单的时间',
    source_id string comment '来源id',
    source_type_code string comment '来源类型编码',
    source_type_name string comment '来源类型的名称',

    split_total_amount decimal(16,2) comment '最终的价格',
    split_activity_amount decimal(16,2) comment '基于活动优惠的价格',
    split_coupon_amount decimal(16,2) comment '基于优惠券优惠的价格',
    split_original_amount decimal(16,2) comment '真实价格'
)comment '交易域-取消订单明细事务-事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_trade_order_cancel_detail_inc'
tblproperties ('orc.compress' = 'snappy');

-- 支付成功明细实表
drop table if exists dwd_trade_pay_suc_detail_inc;
create external table dwd_trade_pay_suc_detail_inc
(
    id string comment '编号',
    date_id string comment '支付成功的日期id', -- 用于日期维表的关联
    user_id string comment '用户id',
    sku_id string comment '商品id',
    sku_num bigint comment '商品的数量',
    order_id string comment '订单id',
    province_id string comment '地区id',

    activity_id string comment '参与的活动id',
    activity_rule_id string comment '参与的活动规则id',
    coupon_id string comment '使用的优惠券id',

    callback_time string comment '支付成功的时间',
    source_id string comment '来源id',
    source_type_code string comment '来源类型编码',
    source_type_name string comment '来源类型的名称',

    payment_type_code string comment '支付类型编码',
    payment_type_name string comment '支付类型名称',
    split_payment_amount decimal(16,2) comment '支付的价格',
    split_activity_amount decimal(16,2) comment '基于活动优惠的价格',
    split_coupon_amount decimal(16,2) comment '基于优惠券优惠的价格',
    split_original_amount decimal(16,2) comment '支付的原始价格'
)comment '交易域-支付成功明细事务-事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_trade_pay_suc_detail_inc'
tblproperties ('orc.compress' = 'snappy');


-- 交易域退单事务事实表
drop table if exists dwd_trade_order_refund_inc;
create external table dwd_trade_order_refund_inc
(
    id                      string comment '编号',
    user_id                 string comment '用户id',
    order_id                string comment '订单id',
    sku_id                  string comment '商品id',
    province_id             string comment '地区id',
    date_id                 string comment '日期id',
    create_time             string comment '退单时间',
    refund_type_code        string comment '退单类型编码',
    refund_type_name        string comment '退单类型名称',
    refund_reason_type_code string comment '退单原因类型编码',
    refund_reason_type_name string comment '退单原因类型名称',
    refund_reason_txt       string comment '退单原因描述',
    refund_num              bigint comment '退单件数',
    refund_amount           decimal(16, 2) comment '退单金额'
) comment '交易域退单事务事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_trade_order_refund_inc'
    tblproperties ("orc.compress" = "snappy");

-- 交易域退款成功
drop table if exists dwd_trade_refund_pay_suc_inc;
create external table dwd_trade_refund_pay_suc_inc
(
    id                string comment '编号',
    user_id           string comment '用户id',
    order_id          string comment '订单编号',
    sku_id            string comment 'sku编号',
    province_id       string comment '地区id',
    payment_type_code string comment '支付类型编码',
    payment_type_name string comment '支付类型名称',
    date_id           string comment '日期id',
    callback_time     string comment '支付成功时间',
    refund_num        decimal(16, 2) comment '退款件数',
    refund_amount     decimal(16, 2) comment '退款金额'
) comment '交易域提交退款成功事务事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_trade_refund_pay_suc_inc'
    tblproperties ("orc.compress" = "snappy");

-- 交易域-购物车周期性快照-事实表
drop table if exists dwd_trade_cart_full;
create external table dwd_trade_cart_full
(
    id string comment '编号',
    user_id string comment '用户id',
    sku_id string comment '商品id',
    sku_name string comment '商品的名称',
    sku_num bigint comment '加购的件数'
)comment '交易域购物车周期性快照事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_trade_cart_full'
tblproperties ('orc.compress' = 'snappy');

-- 工具域-优惠券领取事务-事实表
drop table if exists dwd_tool_coupon_get_inc;
create external table dwd_tool_coupon_get_inc
(
    id string comment '编号',
    coupon_id string comment '优惠券id',
    user_id string comment '用户id',
    date_id string comment '时间id',
    get_time string comment '领取时间'
)comment '工具域-优惠券领取事务-事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_tool_coupon_get_inc'
tblproperties ('orc.compress' = 'snappy');

-- 工具域-使用优惠券下单事务-事实表
drop table if exists dwd_tool_coupon_order_inc;
create external table dwd_tool_coupon_order_inc
(
    id string comment '编号',
    coupon_id string comment '优惠券id',
    user_id string comment '用户id',
    date_id string comment '时间id',
    order_id string comment '订单',
    order_time string comment '下单时间'
)comment '工具域-使用优惠券下单事务-事实表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
stored as orc
location '/dw/commerce/dwd/dwd_tool_coupon_order_inc'
tblproperties ('orc.compress' = 'snappy');

-- 工具域优惠券使用支付事实表
drop table if exists dwd_tool_coupon_pay_inc;
create external table dwd_tool_coupon_pay_inc
(
    id           string comment '编号',
    coupon_id    string comment '优惠券id',
    user_id      string comment 'user_id',
    order_id     string comment 'order_id',
    date_id      string comment '日期id',
    payment_time string comment '使用下单时间'
) comment '优惠券使用支付事务事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_tool_coupon_pay_inc/'
    tblproperties ("orc.compress" = "snappy");

-- 互动域
drop table if exists dwd_interaction_favor_add_inc;
create external table dwd_interaction_favor_add_inc
(
    id          string comment '编号',
    user_id     string comment '用户id',
    sku_id      string comment 'sku_id',
    date_id     string comment '日期id',
    create_time string comment '收藏时间'
) comment '收藏事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_interaction_favor_add_inc/'
    tblproperties ("orc.compress" = "snappy");

-- 评价
drop table if exists dwd_interaction_comment_inc;
create external table dwd_interaction_comment_inc
(
    id            string comment '编号',
    user_id       string comment '用户id',
    sku_id        string comment 'sku_id',
    order_id      string comment '订单id',
    date_id       string comment '日期id',
    create_time   string comment '评价时间',
    appraise_code string comment '评价编码',
    appraise_name string comment '评价名称'
) comment '评价事务事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_interaction_comment_inc/'
    tblproperties ("orc.compress" = "snappy");

-- 流量域-页面浏览事务事实表
drop table if exists dwd_traffic_page_view_inc;
create external table dwd_traffic_page_view_inc
(
    date_id string comment '时间id',
    province_id string comment '省份id',
    brand string comment '手机品牌',
    channel string comment '渠道',
    is_new string comment '是否首次启动',
    model string comment '手机型号',
    mid_id string comment '设备id',
    operate_system string comment '操作系统',
    version_code string comment 'app版本',
    user_id string comment '用户id',
    page_item string comment '目标id',
    page_item_type string comment '目标类型',
    last_page_id string comment '上一页的页面id',
    page_id string comment '当前页面的id',
    source_type string comment '来源类型',
    view_time string comment '跳入时间',
    session_id string comment '会话id',
    during_time string comment '持续时间'
)comment '流量域-页面浏览事务事实表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dwd/dwd_traffic_page_view_inc'
 tblproperties ("orc.compress" = "snappy");

-- 流量域-app启动事务事实表
drop table if exists dwd_traffic_start_inc;
create external table dwd_traffic_start_inc
(
    date_id string comment '时间id',
    province_id string comment '省份id',
    brand string comment '手机品牌',
    channel string comment '渠道',
    is_new string comment '是否首次启动',
    model string comment '手机型号',
    mid_id string comment '设备id',
    operate_system string comment '操作系统',
    version_code string comment 'app版本',
    user_id string comment '用户id',
    entry string comment 'icon,notice',
    open_ad_id string comment '广告业id',
    loading_time_ms bigint comment '启动加载时间',
    open_ad_ms bigint comment '广告播放时间',
    open_ad_skip_ms bigint comment '用户跳过广告的时间点'
) comment '流量域——app启动事务事实表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dwd/dwd_traffic_start_inc'
 tblproperties ("orc.compress" = "snappy");

-- 动作
drop table if exists dwd_traffic_action_inc;
create external table dwd_traffic_action_inc
(
    province_id      string comment '省份id',
    brand            string comment '手机品牌',
    channel          string comment '渠道',
    is_new           string comment '是否首次启动',
    model            string comment '手机型号',
    mid_id           string comment '设备id',
    operate_system   string comment '操作系统',
    user_id          string comment '会员id',
    version_code     string comment 'app版本号',
    during_time      bigint comment '持续时间毫秒',
    page_item        string comment '目标id ',
    page_item_type   string comment '目标类型',
    last_page_id     string comment '上页类型',
    page_id          string comment '页面id ',
    source_type      string comment '来源类型',
    action_id        string comment '动作id',
    action_item      string comment '目标id ',
    action_item_type string comment '目标类型',
    date_id          string comment '日期id',
    action_time      string comment '动作发生时间'
) comment '动作日志表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_traffic_action_inc'
    tblproperties ('orc.compress' = 'snappy');

-- 曝光
drop table if exists dwd_traffic_display_inc;
create external table dwd_traffic_display_inc
(
    province_id       string comment '省份id',
    brand             string comment '手机品牌',
    channel           string comment '渠道',
    is_new            string comment '是否首次启动',
    model             string comment '手机型号',
    mid_id            string comment '设备id',
    operate_system    string comment '操作系统',
    user_id           string comment '会员id',
    version_code      string comment 'app版本号',
    during_time       bigint comment 'app版本号',
    page_item         string comment '目标id ',
    page_item_type    string comment '目标类型',
    last_page_id      string comment '上页类型',
    page_id           string comment '页面id ',
    source_type       string comment '来源类型',
    date_id           string comment '日期id',
    display_time      string comment '曝光时间',
    display_type      string comment '曝光类型',
    display_item      string comment '曝光对象id ',
    display_item_type string comment 'app版本号',
    display_order     bigint comment '曝光顺序',
    display_pos_id    bigint comment '曝光位置'
) comment '曝光日志表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_traffic_display_inc'
    tblproperties ('orc.compress' = 'snappy');

-- 错误事实表
drop table if exists dwd_traffic_error_inc;
create external table dwd_traffic_error_inc
(
    province_id     string comment '地区编码',
    brand           string comment '手机品牌',
    channel         string comment '渠道',
    is_new          string comment '是否首次启动',
    model           string comment '手机型号',
    mid_id          string comment '设备id',
    operate_system  string comment '操作系统',
    user_id         string comment '会员id',
    version_code    string comment 'app版本号',
    page_item       string comment '目标id ',
    page_item_type  string comment '目标类型',
    last_page_id    string comment '上页类型',
    page_id         string comment '页面id ',
    source_type     string comment '来源类型',
    entry           string comment 'icon手机图标  notice 通知',
    loading_time    string comment '启动加载时间',
    open_ad_id      string comment '广告页id ',
    open_ad_ms      string comment '广告总共播放时间',
    open_ad_skip_ms string comment '用户跳过广告时点',
    actions         array<struct<action_id:string,item:string,item_type:string,ts:bigint>> comment '动作信息',
    displays        array<struct<display_type :string,item :string,item_type :string,`order` :string,pos_id
                                   :string>> comment '曝光信息',
    date_id         string comment '日期id',
    error_time      string comment '错误时间',
    error_code      string comment '错误码',
    error_msg       string comment '错误信息'
) comment '错误日志表'
    partitioned by (dt string)
    row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
    --stored as orc
    location '/dw/commerce/dwd/dwd_traffic_error_inc'
    --tblproperties ('orc.compress' = 'snappy')
;

-- 用户域
drop table if exists dwd_user_register_inc;
create external table dwd_user_register_inc
(
    user_id        string comment '用户id',
    date_id        string comment '日期id',
    create_time    string comment '注册时间',
    channel        string comment '应用下载渠道',
    province_id    string comment '省份id',
    version_code   string comment '应用版本',
    mid_id         string comment '设备id',
    brand          string comment '设备品牌',
    model          string comment '设备型号',
    operate_system string comment '设备操作系统'
) comment '用户域用户注册事务事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_user_register_inc'
    tblproperties ("orc.compress" = "snappy");

drop table if exists dwd_user_login_inc;
create external table dwd_user_login_inc
(
    user_id        string comment '用户id',
    date_id        string comment '日期id',
    login_time     string comment '登录时间',
    channel        string comment '应用下载渠道',
    province_id    string comment '省份id',
    version_code   string comment '应用版本',
    mid_id         string comment '设备id',
    brand          string comment '设备品牌',
    model          string comment '设备型号',
    operate_system string comment '设备操作系统'
) comment '用户域用户登录事务事实表'
    partitioned by (dt string)
    stored as orc
    location '/dw/commerce/dwd/dwd_user_login_inc/'
    tblproperties ("orc.compress" = "snappy");