package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.db.bean.RefundPayment;
import com.hnumi.commerce.mock.db.constant.CommerceConstant;
import com.hnumi.commerce.mock.db.mapper.OrderRefundInfoMapper;
import com.hnumi.commerce.mock.db.bean.OrderDetail;
import com.hnumi.commerce.mock.db.bean.OrderInfo;
import com.hnumi.commerce.mock.db.bean.OrderRefundInfo;
import com.hnumi.commerce.mock.db.service.OrderInfoService;
import com.hnumi.commerce.mock.db.service.OrderRefundInfoService;
import com.hnumi.commerce.mock.db.service.OrderStatusLogService;
import com.hnumi.commerce.mock.db.service.RefundPaymentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 退单表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class OrderRefundInfoServiceImpl extends ServiceImpl<OrderRefundInfoMapper, OrderRefundInfo> implements OrderRefundInfoService {

    @Autowired
    OrderInfoService orderInfoService;
    @Autowired
    OrderStatusLogService orderStatusLogService;
    @Autowired
    RefundPaymentService refundPaymentService;
    @Value("${mock.date}")
    String mockDate;
    @Value("${mock.refund.rate:30}")
    String ifRefundRate;
    RandomBox<String> refundTypeOptionGroup = new RandomBox(new RanOpt[]{new RanOpt("1501", 30), new RanOpt("1502", 60)});
    @Value("${mock.refund.reason-rate}")
    String refundReasonRate;

    public OrderRefundInfoServiceImpl() {
    }

    public void genRefundsOrFinish(Boolean ifClear) {
        if (ifClear) {
            this.remove(new QueryWrapper());
            this.refundPaymentService.remove(new QueryWrapper());
        }

        Date date = ParamUtil.checkDate(this.mockDate);
        Integer ifRefundRateWeight = ParamUtil.checkRatioNum(this.ifRefundRate);
        RandomBox<Boolean> ifRefund = new RandomBox(new RanOpt[]{new RanOpt(true, ifRefundRateWeight), new RanOpt(false, 100 - ifRefundRateWeight)});
        Integer[] refundReasonRateArr = ParamUtil.checkRate(this.refundReasonRate, new int[]{7});
        RandomBox<String> refundReasonOptionGroup = new RandomBox(new RanOpt[]{new RanOpt("1301", refundReasonRateArr[0]), new RanOpt("1304", refundReasonRateArr[1]), new RanOpt("1303", refundReasonRateArr[2]), new RanOpt("1305", refundReasonRateArr[3]), new RanOpt("1302", refundReasonRateArr[4]), new RanOpt("1306", refundReasonRateArr[5]), new RanOpt("1307", refundReasonRateArr[6])});
        QueryWrapper<OrderInfo> orderInfoQueryWrapper = new QueryWrapper();
        orderInfoQueryWrapper.in("order_status", new Object[]{"1002", "1004"});
        orderInfoQueryWrapper.orderByAsc("id");
        List<OrderInfo> orderInfoList = this.orderInfoService.listWithDetail(orderInfoQueryWrapper);
        List<OrderRefundInfo> orderRefundInfoList = new ArrayList();
        List<RefundPayment> refundPaymentList = new ArrayList();
        List<OrderInfo> orderInfoListForUpdate = new ArrayList();
        if (orderInfoList.size() == 0) {
            log.warn("没有需要退款或完结的订单！！ ");
        } else {
            Iterator var12 = orderInfoList.iterator();

            while(var12.hasNext()) {
                OrderInfo orderInfo = (OrderInfo)var12.next();
                if (ifRefund.getRandBoolValue()) {
                    OrderRefundInfo orderRefundInfo = new OrderRefundInfo();
                    orderRefundInfo.setOrderId(orderInfo.getId());
                    OrderDetail orderDetail = (OrderDetail)orderInfo.getOrderDetailList().get(0);
                    orderRefundInfo.setRefundAmount(orderDetail.getOrderPrice().multiply(BigDecimal.valueOf(orderDetail.getSkuNum())));
                    orderRefundInfo.setSkuId(orderDetail.getSkuId());
                    orderRefundInfo.setUserId(orderInfo.getUserId());
                    orderRefundInfo.setRefundNum(orderDetail.getSkuNum());
                    orderRefundInfo.setCreateTime(date);
                    orderRefundInfo.setRefundReasonTxt("退款原因具体：" + RandomNumString.getRandNumString(0, 9, 10, ""));
                    orderRefundInfo.setRefundType(this.refundTypeOptionGroup.getRandStringValue());
                    orderRefundInfo.setRefundReasonType(refundReasonOptionGroup.getRandStringValue());
                    orderRefundInfoList.add(orderRefundInfo);
                    RefundPayment refundPayment = new RefundPayment();
                    refundPayment.setOrderId(orderInfo.getId());
                    refundPayment.setSkuId(orderRefundInfo.getSkuId());
                    refundPayment.setPaymentType("1101");
                    refundPayment.setRefundStatus("0701");
                    refundPayment.setTotalAmount(orderRefundInfo.getRefundAmount());
                    refundPayment.setCreateTime(date);
                    refundPayment.setCallbackTime(date);
                    refundPayment.setOutTradeNo(RandomNumString.getRandNumString(1, 9, 15, ""));
                    refundPayment.setSubject("退款");
                    refundPaymentList.add(refundPayment);
                    orderInfo.setOrderStatus("1005");
                    orderInfoListForUpdate.add(orderInfo);
                } else if (orderInfo.getOrderStatus().equals("1002")) {
                    orderInfo.setOrderStatus("1004");
                    orderInfoListForUpdate.add(orderInfo);
                }
            }

            this.orderInfoService.updateOrderStatus(orderInfoListForUpdate);
            log.warn("共生成退款" + orderRefundInfoList.size() + "条");
            this.saveBatch(orderRefundInfoList);
            this.refundPaymentService.saveBatch(refundPaymentList);
            log.warn("共生成退款支付明细" + orderRefundInfoList.size() + "条");
            this.refundApprove();
        }
    }

    public void refundApprove() {
        List<OrderRefundInfo> appprovingOrderRefundList = this.list((Wrapper)(new QueryWrapper()).eq("refund_status", "0701"));
        Iterator var2 = appprovingOrderRefundList.iterator();

        while(var2.hasNext()) {
            OrderRefundInfo orderRefundInfo = (OrderRefundInfo)var2.next();
            orderRefundInfo.setRefundStatus("0702");
        }

        this.saveOrUpdateBatch(appprovingOrderRefundList, 1000);
        List<OrderRefundInfo> appprovedOrderRefundList = this.list((Wrapper)(new QueryWrapper()).eq("refund_status", "0702"));
        Iterator var7 = appprovedOrderRefundList.iterator();

        while(var7.hasNext()) {
            OrderRefundInfo orderRefundInfo = (OrderRefundInfo)var7.next();
            orderRefundInfo.setRefundStatus("0705");
        }

        this.saveOrUpdateBatch(appprovedOrderRefundList, 1000);
        List<OrderInfo> appprovingOrderList = this.orderInfoService.list((Wrapper)(new QueryWrapper()).eq("order_status", "1005"));
        Iterator var9 = appprovingOrderList.iterator();

        while(var9.hasNext()) {
            OrderInfo orderInfo = (OrderInfo)var9.next();
            orderInfo.setOrderStatus("1006");
        }

        this.orderInfoService.saveOrUpdateBatch(appprovingOrderList, 1000);
        log.warn("共完成退款" + appprovingOrderList.size() + "条");
    }
}
