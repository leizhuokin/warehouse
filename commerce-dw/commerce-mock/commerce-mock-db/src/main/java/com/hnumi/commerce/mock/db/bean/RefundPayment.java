package com.hnumi.commerce.mock.db.bean;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;
@Data
public class RefundPayment {
    @TableId(
            value = "id",
            type = IdType.AUTO
    )
    Long id;
    String outTradeNo;
    Long orderId;
    Long skuId;
    String paymentType;
    BigDecimal totalAmount;
    String subject;
    String refundStatus;
    Date createTime;
    Date callbackTime;
    String callbackContent;

}
