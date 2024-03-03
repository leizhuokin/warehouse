package com.hnumi.commerce.mock.db.bean;

import lombok.Data;

import java.math.BigDecimal;
import java.io.Serializable;

/**
 * <p>
 * 优惠规则
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Data
public class ActivityRule implements Serializable {

    private static final long serialVersionUID = 1L;
    private Long id;
    private Long activityId;
    private BigDecimal conditionAmount;
    private Long conditionNum;
    private BigDecimal benefitAmount;
    private BigDecimal benefitDiscount;
    private Long benefitLevel;
    private String activityType;
}
