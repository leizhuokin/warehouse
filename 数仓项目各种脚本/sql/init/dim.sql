-- 商品维表
use ${app};
drop table if exists dim_sku_full;
create external table dim_sku_full
(
    `id` string COMMENT '库存id(itemID)',
    `price` decimal(10, 0) COMMENT '价格',
    `sku_name` string comment 'sku名称',
    `sku_desc` string COMMENT '商品规格描述',
    `weight` decimal(10, 2) COMMENT '重量',
    `is_sale` string COMMENT '是否销售（1：是 0：否）',
    `spu_id` string COMMENT '商品id',
    `spu_name` string COMMENT '商品名称',
    `tm_id` string COMMENT '编号',
    `tm_name` string COMMENT '属性值',
    `category1_id` string COMMENT '编号',
    `category1_name` string COMMENT '分类名称',
    `category2_id` string COMMENT '编号',
    `category2_name` string COMMENT '分类名称',
    `category3_id` string COMMENT '编号',
    `category3_name` string COMMENT '分类名称',
    attrs array<struct<
        attr_id:string,
        attr_name:string,
        value_name:string
    >> comment 'sku 平台属性',
    sale_attrs array<struct<
        sale_attr_id:string,
        sale_attr_name:string,
        sale_attr_value_name:string
    >> comment 'sku 销售属性'
) comment '商品维表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dim/dim_sku_full'
tblproperties ('orc.compress' = 'snappy');

-- 优惠券维表
   -- 购物券表
   -- ods_base_dic_full
   -- ods_coupon_info_full
drop table if exists dim_coupon_full;
create external table dim_coupon_full
(
  `id` string COMMENT '购物券ID',
  `coupon_name` string COMMENT '购物券名称',
  `coupon_type_code` string COMMENT '购物券类型编号 1 现金券 2 折扣券 3 满减券 4 满件打折券',
  `coupon_type_name` string COMMENT '购物券类型名称',
  `condition_amount` decimal(10, 2) COMMENT '满额数（3）',
  `condition_num` bigint COMMENT '满件数（4）',
  `activity_id` string COMMENT '活动编号',
  `benefit_amount` decimal(16, 2) COMMENT '减金额（1 3）',
  `benefit_discount` decimal(10, 2)  COMMENT '折扣（2 4）',
  `create_time` string COMMENT '创建时间',
  `range_type_code` string COMMENT '范围类型 1、商品(spuid) 2、品类(三级分类id) 3、品牌',
  `range_type_name` string COMMENT '活动范围类型的名称',
  `limit_num` bigint COMMENT '最多领用次数',
  `taken_count` bigint COMMENT '已领用次数',
  `start_time` string COMMENT '可以领取的开始日期',
  `end_time` string COMMENT '可以领取的结束日期',
  `operate_time` string COMMENT '修改时间',
  `expire_time` string COMMENT '过期时间',
  `range_desc` string COMMENT '范围描述',
   benefit_rule string comment '优惠规则：满XX减多少'
) comment '优惠券纬度表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dim/dim_coupon_full'
tblproperties ('orc.compress' = 'snappy');

-- 活动维表
   -- ods_activity_rule_full
   -- ods_activity_info_full
   -- ods_base_dic_full
drop table if exists dim_activity_full;
create external table dim_activity_full
(
    id            string comment '活动ID',
    rule_id       string comment '活动规则ID',
    activity_name string comment '活动名称',
    activity_type_code string comment '活动类型编号',
    activity_type_name string comment '活动类型名称',
    activity_desc string comment '活动描述',
    start_time    string comment '开始时间',
    end_time      string comment '结束时间',
    create_time   string comment '创建时间',
    `condition_amount` decimal(16,2) COMMENT '满减金额',
    `condition_num` bigint COMMENT '满减件数',
    `benefit_amount` decimal(16, 2) COMMENT '优惠金额',
    `benefit_discount` decimal(10, 2) COMMENT '优惠折扣',
    `benefit_level` string COMMENT '优惠级别',
    benefit_rule string comment '优惠规则：满XX减多少'
) comment  '活动信息纬度表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dim/dim_activity_full'
tblproperties ('orc.compress' = 'snappy');

-- 地区维表
   -- ods_base_province_full
   -- ods_base_region_full
drop table if exists dim_province_full;
create external table dim_province_full
(
  `id` string COMMENT 'id',
  `name` string COMMENT '省名称',
  `region_id` string COMMENT '大区id',
  `area_code` string COMMENT '行政区位码',
  `iso_code` string COMMENT '国际编码',
  `iso_3166_2` string COMMENT 'ISO3166编码',
  `region_name` string COMMENT '区域名称'
)comment  '地区纬度表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dim/dim_province_full'
tblproperties ('orc.compress' = 'snappy');
-- 日期维表
   -- 每年生成一次
drop table if exists dim_date;
create external table dim_date
(
    date_id string comment '日期ID',
    week_id string comment '周ID，一年中的第几周',
    week_day string comment '周几',
    day string comment '每个月的第几天',
    month string comment '一年中的第几个月',
    quarter string comment '一年中的第几个季度',
    year string comment '所属年份',
    is_workday string comment '是否为工作日',
    is_holiday string comment '是否为节假日'
)comment  '日期纬度表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dim/dim_date'
tblproperties ('orc.compress' = 'snappy');

-- 一年导入一次


-- 用户维表
drop table if exists dim_user_zip;
create external table dim_user_zip
(
        id  string comment '用户ID',
        login_name string comment '用户名',
        nick_name string comment '昵称',
        name string comment '姓名',
        phone_num string comment '手机号',
        email string comment '邮箱',
        user_level string comment '用户等级',
        birthday string comment '用户生日',
        gender string comment '性别',
        create_time string comment '创建时间',
        operate_time string comment '操作时间',
        status string comment '用户状态',
        start_date string comment '开始使用日期',
        end_date string comment '结束使用日期'
)comment  '用户纬度表'
partitioned by (dt string)
stored as orc
location '/dw/commerce/dim/dim_user_zip'
tblproperties ('orc.compress' = 'snappy');