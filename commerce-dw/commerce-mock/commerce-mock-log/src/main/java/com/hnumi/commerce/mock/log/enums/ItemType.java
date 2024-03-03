package com.hnumi.commerce.mock.log.enums;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public enum ItemType {

    sku_id("商品skuId"),
    keyword("搜索关键词"),
    sku_ids("多个商品skuId"),
    activity_id("活动id"),
    coupon_id("购物券id");

    private String desc;
}
