package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.PaymentInfo;

/**
 * <p>
 * 支付流水表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface PaymentInfoService extends IService<PaymentInfo> {
    void genPayments(Boolean ifClear);
}
