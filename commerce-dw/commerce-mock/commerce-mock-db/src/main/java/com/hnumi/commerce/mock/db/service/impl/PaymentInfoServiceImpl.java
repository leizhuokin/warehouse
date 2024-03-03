package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.db.constant.CommerceConstant;
import com.hnumi.commerce.mock.db.mapper.PaymentInfoMapper;
import com.hnumi.commerce.mock.db.bean.OrderInfo;
import com.hnumi.commerce.mock.db.bean.PaymentInfo;
import com.hnumi.commerce.mock.db.service.CouponUseService;
import com.hnumi.commerce.mock.db.service.OrderInfoService;
import com.hnumi.commerce.mock.db.service.OrderStatusLogService;
import com.hnumi.commerce.mock.db.service.PaymentInfoService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 支付流水表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class PaymentInfoServiceImpl extends ServiceImpl<PaymentInfoMapper, PaymentInfo> implements PaymentInfoService {
    @Autowired
    OrderInfoService orderInfoService;
    @Autowired
    OrderStatusLogService orderStatusLogService;
    @Autowired
    CouponUseService couponUseService;
    @Value("${mock.date}")
    String mockDate;
    @Value("${mock.payment.rate:70}")
    String ifPaymentRate;
    @Value("${mock.payment.payment-type:30:60:10}")
    String paymentTypeRate;
    public void genPayments(Boolean ifClear) {
        Date date = ParamUtil.checkDate(this.mockDate);
        int ifPaymentWeight = ParamUtil.checkRatioNum(this.ifPaymentRate);
        Integer[] paymentTypeRateWeight = ParamUtil.checkRate(this.paymentTypeRate, 3);
        RandomBox<Boolean> ifPayment = new RandomBox<>(new RanOpt[]{new RanOpt(true, ifPaymentWeight), new RanOpt(false, 100 - ifPaymentWeight)});
        RandomBox<String> paymentOptionGroup = new RandomBox<>(new RanOpt[]{new RanOpt("1101", paymentTypeRateWeight[0]), new RanOpt("1102", paymentTypeRateWeight[1]), new RanOpt("1103", paymentTypeRateWeight[2])});
        if (ifClear) {
            this.remove(new QueryWrapper());
        }

        QueryWrapper<OrderInfo> orderInfoQueryWrapper = new QueryWrapper<>();
        orderInfoQueryWrapper.eq("order_status", "1001");
        orderInfoQueryWrapper.orderByAsc("id");
        List<OrderInfo> orderInfoList = this.orderInfoService.listWithDetail(orderInfoQueryWrapper);
        List<PaymentInfo> paymentList = new ArrayList<>();
        if (orderInfoList.size() == 0) {
            log.info("没有需要支付的订单！！ ");
        } else {
            List<OrderInfo> orderListForUpdate = new ArrayList<>(orderInfoList.size());
            List<OrderInfo> orderListForCancel = new ArrayList<>(orderInfoList.size());
           orderInfoList.forEach(orderInfo -> {
               if (ifPayment.getRandBoolValue()) {
                   PaymentInfo paymentInfo = new PaymentInfo();
                   paymentInfo.setOrderId(orderInfo.getId());
                   paymentInfo.setPaymentStatus("1601");
                   paymentInfo.setTotalAmount(orderInfo.getTotalAmount());
                   paymentInfo.setUserId(orderInfo.getUserId());
                   paymentInfo.setOutTradeNo(orderInfo.getOutTradeNo());
                   paymentInfo.setTradeNo(RandomNumString.getRandNumString(1, 9, 34, ""));
                   paymentInfo.setPaymentType(paymentOptionGroup.getRandStringValue());
                   paymentInfo.setSubject(orderInfo.getTradeBody());
                   paymentInfo.setCreateTime(date);
                   paymentList.add(paymentInfo);
                   orderListForUpdate.add(orderInfo);
               } else {
                   orderInfo.setOrderStatus("1003");
                   orderListForCancel.add(orderInfo);
               }
           });

            this.orderInfoService.updateOrderStatus(orderListForUpdate);
            this.saveBatch(paymentList, 100);
            this.callbackPayment(date, paymentList, orderListForUpdate);
            this.couponUseService.usedCoupon(orderListForUpdate);
            log.warn("共有" + paymentList.size() + "订单完成支付");
            this.orderInfoService.updateOrderStatus(orderListForCancel);
            log.warn("共有" + orderListForCancel.size() + "订单放弃支付");
        }
    }

    public void callbackPayment(Date date, List<PaymentInfo> paymentInfoList, List<OrderInfo> orderInfoList) {
        paymentInfoList.forEach(paymentInfo -> {
            paymentInfo.setCallbackTime(DateUtils.addSeconds(date, 20));
            paymentInfo.setPaymentStatus("1602");
            paymentInfo.setCallbackContent(RandomStringUtils.randomAlphabetic(10));
        });
        this.saveOrUpdateBatch(paymentInfoList, 1000);
        orderInfoList.forEach(orderInfo -> {
            orderInfo.setOrderStatus("1002");
        });
        this.orderInfoService.saveOrUpdateBatch(orderInfoList, 1000);
    }

}
