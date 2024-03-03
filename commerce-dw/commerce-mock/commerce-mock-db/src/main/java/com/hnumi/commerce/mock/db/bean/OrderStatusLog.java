package com.hnumi.commerce.mock.db.bean;

import com.baomidou.mybatisplus.annotation.IdType;
import java.util.Date;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.io.Serializable;

/**
 * <p>
 * 
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Data
public class OrderStatusLog implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private String orderStatus;

    private Date operateTime;




    @Override
    public String toString() {
        return "OrderStatusLog{" +
        "id=" + id +
        ", orderId=" + orderId +
        ", orderStatus=" + orderStatus +
        ", operateTime=" + operateTime +
        "}";
    }
}
