package com.hnumi.commerce.mock.db.bean;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Builder;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;
@Data
@Builder
public class OrderDetailActivity implements Serializable {
    private static final long serialVersionUID = 1L;
    @TableId(
            value = "id",
            type = IdType.AUTO
    )
    private Long id;
    private Long orderDetailId;
    private Long activityRuleId;
    private Long skuId;
    private Long activityId;
    private Long orderId;
    @TableField(
            exist = false
    )
    private OrderDetail orderDetail;
    @TableField(
            exist = false
    )
    private OrderInfo orderInfo;
    @TableField(
            exist = false
    )
    private ActivityRule activityRule;
    private Date createTime;
}
