create database if not exists ${app};
use ${app};
drop table if exists ods_log_inc; -- 日志表
drop table if exists ods_activity_info_full;
drop table if exists ods_activity_rule_full;
drop table if exists ods_base_category1_full;
drop table if exists ods_base_category2_full;
drop table if exists ods_base_category3_full;
drop table if exists ods_base_dic_full;
drop table if exists ods_base_province_full;
drop table if exists ods_base_region_full;
drop table if exists ods_base_trademark_full;
drop table if exists ods_cart_info_full;
drop table if exists ods_cart_info_inc;
drop table if exists ods_comment_info_inc;
drop table if exists ods_coupon_info_full;
drop table if exists ods_coupon_use_inc;
drop table if exists ods_favor_info_inc;
drop table if exists ods_order_detail_activity_inc;
drop table if exists ods_order_detail_coupon_inc;
drop table if exists ods_order_detail_inc;
drop table if exists ods_order_info_inc;
drop table if exists ods_order_refund_info_inc;
drop table if exists ods_order_status_log_inc;
drop table if exists ods_payment_info_inc;
drop table if exists ods_refund_payment_inc;
drop table if exists ods_sku_attr_value_full;
drop table if exists ods_sku_info_full;
drop table if exists ods_sku_sale_attr_value_full;
drop table if exists ods_spu_info_full;
drop table if exists ods_user_info_inc;
-- 日志表
create external table ods_log_inc
(
    common struct<ar:string,ba:string,ch:string,is_new:string,md:string,mid:string,os:string,uid:string,vc:string> comment '公共信息',
    actions array<struct<action_id:string,item:string,item_type:string,ts:bigint>> comment '动作事件',
    displays array<struct<displaytype:string,item:string,item_type:string,`order`:int, pos_id:string>> comment '曝光',
    page struct<during_time:bigint,item:string,item_type:string,last_page_id:string, page_id:string,source_type:string> comment '页面数据',
    err struct<error_code: string,msg:string> comment '错误信息',
    ts bigint comment '时间戳',
    `start` struct<entry:string,loading_time:bigint,open_ad_id:string,open_ad_ms:bigint,open_ad_skip_ms:bigint> comment '启动信息'
) comment '用户行为日志表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_log_inc/';

-- ----------------业务表-----------------
-- 全量：活动信息表
create external table ods_activity_info_full
(
    id            string comment '活动id',
    activity_name string comment '活动名称',
    activity_type string comment '活动类型',
    activity_desc string comment '活动描述',
    start_time    string comment '开始时间',
    end_time      string comment '结束时间',
    create_time   string comment '创建时间'
) comment '活动信息表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_activity_info_full';

-- 全量：活动规则表
create external table ods_activity_rule_full (
  `id` string comment '编号',
  `activity_id` string comment '类型',
  `activity_type` string comment  '活动类型',
  `condition_amount` decimal(16,2) comment '满减金额',
  `condition_num` bigint comment '满减件数',
  `benefit_amount` decimal(16, 2) comment '优惠金额',
  `benefit_discount` decimal(10, 2) comment '优惠折扣',
  `benefit_level` string comment '优惠级别'
) comment '活动规则表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_activity_rule_full';

-- 全量：一级品类
create external table ods_base_category1_full (
  `id` string comment '编号',
  `name` string comment '分类名称'
) comment '一级品类'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_category1_full';

-- 全量：二级品类
create external table ods_base_category2_full (
  `id` string comment '编号',
  `name` string comment '二级分类名称',
  `category1_id` string comment '一级分类id'
) comment '二级分类'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_category2_full';
-- 全量：三级品类
create external table ods_base_category3_full  (
  `id` string comment '编号',
  `name` string comment '三级分类名称',
  `category2_id` string comment '二级分类编号'
) comment '三级分类'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_category3_full';

-- 全量：字典表
create external table ods_base_dic_full  (
  `dic_code` string comment '编号',
  `dic_name` string comment '编码名称',
  `parent_code` string comment '父编号',
  `create_time` string comment '创建日期',
  `operate_time` string comment '修改日期'
) comment '基础字典表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_dic_full';

--全量：省份表
create external table ods_base_province_full  (
  `id` string comment 'id',
  `name` string comment '省名称',
  `region_id` string comment '大区id',
  `area_code` string comment '行政区位码',
  `iso_code` string comment '国际编码',
  `iso_3166_2` string comment 'iso3166编码'
) comment '省份表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_province_full';

-- 全量：地区表
create external table ods_base_region_full  (
  `id` string comment '大区id',
  `region_name` string comment '大区名称'
) comment '地区表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_region_full';

-- 全量：品牌表
create external table ods_base_trademark_full  (
  `id` string comment '编号',
  `tm_name` string comment '属性值',
  `logo_url` string comment '品牌logo的图片路径'
)  comment '品牌表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_base_trademark_full';

-- 全量：购物车表
create external table ods_cart_info_full  (
  `id` string comment '编号',
  `user_id` string comment '用户id',
  `sku_id` string comment 'skuid',
  `cart_price` decimal(10, 2) comment '放入购物车时价格',
  `sku_num` bigint comment '数量',
  `img_url` string comment '图片文件',
  `sku_name` string comment 'sku名称 (冗余)',
  `is_checked` string comment '是否被选中',
  `create_time` string comment '创建时间',
  `operate_time` string comment '修改时间',
  `is_ordered` string comment '是否已经下单',
  `order_time` string comment '下单时间',
  `source_type` string comment '来源类型',
  `source_id` string comment '来源编号'
)  comment '购物车表 用户登录系统时更新冗余'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_cart_info_full';

-- 全量：优惠券表
create external table ods_coupon_info_full  (
  `id` string comment '购物券编号',
  `coupon_name` string comment '购物券名称',
  `coupon_type` string comment '购物券类型 1 现金券 2 折扣券 3 满减券 4 满件打折券',
  `condition_amount` decimal(10, 2) comment '满额数（3）',
  `condition_num` bigint comment '满件数（4）',
  `activity_id` string comment '活动编号',
  `benefit_amount` decimal(16, 2) comment '减金额（1 3）',
  `benefit_discount` decimal(10, 2)  comment '折扣（2 4）',
  `create_time` string comment '创建时间',
  `range_type` string comment '范围类型 1、商品(spuid) 2、品类(三级分类id) 3、品牌',
  `limit_num` bigint comment '最多领用次数',
  `taken_count` bigint comment '已领用次数',
  `start_time` string comment '可以领取的开始日期',
  `end_time` string comment '可以领取的结束日期',
  `operate_time` string comment '修改时间',
  `expire_time` string comment '过期时间',
  `range_desc` string comment '范围描述'
)  comment '优惠券表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_coupon_info_full';
-- 全量：商品平台属性表
create external table ods_sku_attr_value_full  (
  `id` string comment '编号',
  `attr_id` string comment '属性id（冗余)',
  `value_id` string comment '属性值id',
  `sku_id` string comment 'skuid',
  `attr_name` string comment '属性名',
  `value_name` string comment '属性值名称'
) comment 'sku平台属性值关联表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_sku_attr_value_full';
-- 全量：商品信息表
create external table ods_sku_info_full  (
  `id` string comment '库存id(itemid)',
  `spu_id` string comment '商品id',
  `price` decimal(10, 0) comment '价格',
  `sku_name` string comment 'sku名称',
  `sku_desc` string comment '商品规格描述',
  `weight` decimal(10, 2) comment '重量',
  `tm_id` string comment '品牌(冗余)',
  `category3_id` string comment '三级分类id（冗余)',
  `sku_default_img` string comment '默认显示图片(冗余)',
  `is_sale` string comment '是否销售（1：是 0：否）',
  `create_time` string comment '创建时间'
)  comment '商品表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_sku_info_full';
-- 全量：商品销售属性值表
create external table ods_sku_sale_attr_value_full  (
  `id` string comment 'id',
  `sku_id` string comment '库存单元id',
  `spu_id` string comment 'spu_id(冗余)',
  `sale_attr_value_id` string comment '销售属性值id',
  `sale_attr_id` string comment  '销售属性id',
  `sale_attr_name` string comment '销售属性名称',
  `sale_attr_value_name`  string comment '销售属性值名称'
)  comment 'sku销售属性值'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_sku_sale_attr_value_full';
-- 全量：spu
create external table ods_spu_info_full  (
  `id` string comment '商品id',
  `spu_name` string comment '商品名称',
  `description` string comment '商品描述(后台简述）',
  `category3_id` string comment '三级分类id',
  `tm_id` string comment '品牌id'
) comment 'spu 商品表'
partitioned by (dt string)
row format delimited fields terminated by '\t'
null defined as ''
location '/dw/commerce/ods/ods_spu_info_full';


-- 增量表都是以下格式，需要修改的是data中的内容
-- 购物车增量
create external table ods_cart_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
    id:string,
    user_id:string,
    sku_id:string,
    cart_price:decimal(16,2),
    sku_num:bigint,
    img_url:string,
    sku_name:string,
    is_ordered:string,
    order_time:string,
    `create_time`: string,
    `operate_time`: string,
    source_type:string,
    source_id:string> comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '购物车增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_cart_info_inc';
-- 评论表增量
create external table ods_comment_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id:string,
        user_id:string,
        nick_name:string,
        head_img:string,
        sku_id:string,
        spu_id:string,
        order_id:string,
        appraise:string,
        comment_txt:string,
        create_time:string,
        operate_time:string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '评论增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_comment_info_inc';
-- 优惠券领用增量表
create external table ods_coupon_use_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id:string,
        coupon_id:string,
        user_id:string,
        order_id:string,
        coupon_status:string,
        create_time:string,
        get_time:string,
        using_time:string,
        used_time:string,
        expire_time:string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '优惠券领用增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_coupon_use_inc';

-- 收藏记录增量表
create external table ods_favor_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        user_id: string,
        sku_id: string,
        spu_id: string,
        is_cancel: string,
        create_time: string,
        cancel_time: string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '收藏记录增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_favor_info_inc';


-- 订单明细增量表
create external table ods_order_detail_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        order_id:string,
        sku_id:string,
        sku_name:string,
        img_url:string,
        order_price: decimal(10,2),
        sku_num:bigint,
        create_time:string,
        source_type:string,
        source_id:string,
        split_total_amount:decimal(16, 2),
        split_activity_amount:decimal(16, 2),
        split_coupon_amount: decimal(16, 2)
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '订单明细增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_order_detail_inc';

-- 订单明细-活动增量表
create external table ods_order_detail_activity_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id:string,
        order_id:string,
        order_detail_id:string,
        activity_id:string,
        activity_rule_id:string,
        sku_id:string,
        create_time:string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '订单明细-活动增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_order_detail_activity_inc';


-- 订单明细-优惠券增量表
create external table ods_order_detail_coupon_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id:string,
        order_id:string,
        order_detail_id:string,
        coupon_id:string,
        coupon_use_id:string,
        sku_id:string,
        create_time:string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '订单明细-优惠券增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_order_detail_coupon_inc';


-- 订单增量表
create external table ods_order_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id:string,
        consignee:string,
        consignee_tel:string,
        total_amount:decimal(10, 2),
        order_status:string,
        user_id:string,
        payment_way:string,
        delivery_address:string,
        order_comment:string,
        out_trade_no:string,
        trade_body:string,
        create_time:string,
        operate_time:string,
        expire_time:string,
        process_status:string,
        tracking_no:string,
        parent_order_id:string,
        img_url:string,
        province_id:string,
        activity_reduce_amount:decimal(16, 2),
        coupon_reduce_amount:decimal(16, 2),
        original_total_amount:decimal(16, 2),
        feight_fee:decimal(16, 2),
        feight_fee_reduce:decimal(16, 2),
        province_id :string,
        refundable_time:string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '订单增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_order_info_inc';

-- 退单增量表
create external table ods_order_refund_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        user_id: string,
        order_id: string,
        sku_id: string,
        refund_type: string,
        refund_num: bigint,
        refund_amount: decimal(16, 2),
        refund_reason_type: string,
        refund_reason_txt: string,
        refund_status: string,
        create_time: string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '退单增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_order_refund_info_inc';

-- 订单状态增量表
create external table ods_order_status_log_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        order_id: string,
        order_status: string,
        operate_time: string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '订单状态增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_order_status_log_inc';



-- 支付信息增量表
create external table ods_payment_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        out_trade_no: string,
        order_id: string,
        user_id: string,
        payment_type: string,
        trade_no: string,
        total_amount: decimal(10, 2),
        subject: string,
        payment_status: string,
        create_time: string,
        callback_time: string,
        callback_content: string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '支付信息增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_payment_info_inc';

-- 退款记录增量表
create external table ods_refund_payment_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        out_trade_no: string,
        order_id: string,
        sku_id: string,
        payment_type: string,
        trade_no: string,
        total_amount: decimal(10, 2),
        subject: string,
        refund_status: string,
        create_time: string,
        callback_time: string,
        callback_content: string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '退款记录增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_refund_payment_inc';

-- 用户信息增量表
create external table ods_user_info_inc
(
    type string comment '变动类型',
    ts bigint comment '时间戳',
    data struct<
        id: string,
        login_name: string,
        nick_name: string,
        passwd: string,
        name: string,
        phone_num: string,
        email: string,
        head_img: string,
        user_level: string,
        birthday: string,
        gender: string,
        create_time: string,
        operate_time: string,
        status: string
    > comment '最终数据',
    old map<string,string> comment '旧的数据'
) comment '退款记录增量表'
partitioned by (dt string)
row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
location '/dw/commerce/ods/ods_user_info_inc';