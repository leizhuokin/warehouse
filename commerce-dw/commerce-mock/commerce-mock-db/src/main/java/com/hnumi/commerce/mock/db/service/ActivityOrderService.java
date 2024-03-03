package com.hnumi.commerce.mock.db.service;


import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.OrderDetailActivity;
import com.hnumi.commerce.mock.db.bean.OrderInfo;

import java.util.List;


/**
 * <p>
 * 活动与订单关联表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface ActivityOrderService extends IService<OrderDetailActivity> {

    List<OrderDetailActivity> genActivityOrder(List<OrderInfo> orderInfoList, Boolean ifClear);

    void saveActivityOrderList(List<OrderDetailActivity> activityOrderList);

}
