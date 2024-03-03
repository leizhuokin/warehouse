package com.hnumi.commerce.mock.db.bean;

import lombok.Data;

@Data
public class CouponRange {
    Long id;
    Long couponId;
    String rangeType;
    Long rangeId;
}
