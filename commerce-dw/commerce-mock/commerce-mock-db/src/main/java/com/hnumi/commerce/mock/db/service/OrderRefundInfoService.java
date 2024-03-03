package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.OrderRefundInfo;

/**
 * <p>
 * 退单表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface OrderRefundInfoService extends IService<OrderRefundInfo> {

    void  genRefundsOrFinish(Boolean ifClear);
}
