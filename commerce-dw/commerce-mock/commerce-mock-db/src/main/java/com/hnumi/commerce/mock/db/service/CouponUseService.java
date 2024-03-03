package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.CouponUse;
import com.hnumi.commerce.mock.db.bean.OrderDetailCoupon;
import com.hnumi.commerce.mock.db.bean.OrderInfo;
import org.apache.commons.lang3.tuple.Pair;

import java.util.List;

/**
 * <p>
 * 优惠券领用表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface CouponUseService extends IService<CouponUse> {

    void genCoupon(Boolean ifClear);

    void usedCoupon(List<OrderInfo> orderInfoList);

    Pair<List<CouponUse>, List<OrderDetailCoupon>> usingCoupon(List<OrderInfo> orderInfoList);

    void saveCouponUseList(List<CouponUse> couponUseList);

}
