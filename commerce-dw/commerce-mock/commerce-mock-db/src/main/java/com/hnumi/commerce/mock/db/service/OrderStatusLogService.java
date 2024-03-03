package com.hnumi.commerce.mock.db.service;


import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.OrderInfo;
import com.hnumi.commerce.mock.db.bean.OrderStatusLog;

import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface OrderStatusLogService extends IService<OrderStatusLog> {
    public void  genOrderStatusLog(List<OrderInfo> orderInfoList);

}
