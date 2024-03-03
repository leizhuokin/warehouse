package com.hnumi.commerce.mock.db.bean;

import java.math.BigDecimal;
import com.baomidou.mybatisplus.annotation.IdType;
import java.util.Date;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.io.Serializable;
import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 订单表 订单表
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Data
public class OrderInfo implements Serializable {

    private static final long serialVersionUID = 1L;
    @TableId(
            value = "id",
            type = IdType.AUTO
    )
    private Long id;
    private String consignee;
    private String consigneeTel;
    private BigDecimal totalAmount;
    private String orderStatus;
    private Long userId;
    private String deliveryAddress;
    private String orderComment;
    private String outTradeNo;
    private String tradeBody;
    private Date createTime;
    private Date operateTime;
    private Date expireTime;
    private String trackingNo;
    private Long parentOrderId;
    private String imgUrl;
    private Integer provinceId;
    private BigDecimal originalTotalAmount;
    private BigDecimal feightFee;
    private BigDecimal activityReduceAmount;
    private BigDecimal couponReduceAmount;
    @TableField(
            exist = false
    )
    private List<OrderDetail> orderDetailList;

    public void sumTotalAmount() {
        this.activityReduceAmount = this.activityReduceAmount == null ? BigDecimal.ZERO : this.activityReduceAmount;
        this.couponReduceAmount = this.couponReduceAmount == null ? BigDecimal.ZERO : this.couponReduceAmount;
        this.feightFee = this.feightFee == null ? BigDecimal.ZERO : this.feightFee;
        this.originalTotalAmount = this.originalTotalAmount == null ? BigDecimal.ZERO : this.originalTotalAmount;
        this.totalAmount = this.totalAmount == null ? BigDecimal.ZERO : this.totalAmount;
        BigDecimal totalAmount = BigDecimal.ZERO;

        BigDecimal splitTotalamount;
        for(Iterator var2 = this.orderDetailList.iterator(); var2.hasNext(); totalAmount = totalAmount.add(splitTotalamount)) {
            OrderDetail orderDetail = (OrderDetail)var2.next();
            BigDecimal splitActivityAmount = orderDetail.getSplitActivityAmount() == null ? BigDecimal.ZERO : orderDetail.getSplitActivityAmount();
            BigDecimal couponReduceAmount = orderDetail.getSplitCouponAmount() == null ? BigDecimal.ZERO : orderDetail.getSplitCouponAmount();
            splitTotalamount = orderDetail.getOrderPrice().multiply(new BigDecimal(orderDetail.getSkuNum()));
            splitTotalamount = splitTotalamount.subtract(splitActivityAmount).subtract(couponReduceAmount);
            orderDetail.setSplitTotalAmount(splitTotalamount);
        }

        this.originalTotalAmount = totalAmount;
        this.totalAmount = this.originalTotalAmount.subtract(this.activityReduceAmount).subtract(this.couponReduceAmount).add(this.feightFee);
    }

    public String getOrderSubject() {
        String body = "";
        if (this.orderDetailList != null && this.orderDetailList.size() > 0) {
            body = ((OrderDetail)this.orderDetailList.get(0)).getSkuName();
        }

        body = body + "等" + this.getTotalSkuNum() + "件商品";
        return body;
    }

    public Long getTotalSkuNum() {
        Long totalNum = 0L;

        OrderDetail orderDetail;
        for(Iterator var2 = this.orderDetailList.iterator(); var2.hasNext(); totalNum = totalNum + orderDetail.getSkuNum()) {
            orderDetail = (OrderDetail)var2.next();
        }

        return totalNum;
    }

}
