package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.mapper.CouponUseMapper;
import com.hnumi.commerce.mock.db.bean.*;
import com.hnumi.commerce.mock.common.util.ParamUtil;
import com.hnumi.commerce.mock.db.service.CouponInfoService;
import com.hnumi.commerce.mock.db.service.CouponUseService;
import com.hnumi.commerce.mock.db.service.SkuInfoService;
import com.hnumi.commerce.mock.db.service.UserInfoService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.*;

/**
 * <p>
 * 优惠券领用表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class CouponUseServiceImpl extends ServiceImpl<CouponUseMapper, CouponUse> implements CouponUseService {
    @Autowired
    CouponInfoService couponInfoService;
    @Autowired
    SkuInfoService skuInfoService;
    @Autowired
    UserInfoService userInfoService;
    @Autowired
    CouponUseMapper couponUseMapper;
    @Value("${mock.date}")
    String mockDate;
    @Value("${mock.coupon.user-count:1000}")
    String userCount;

    public CouponUseServiceImpl() {
    }

    public void genCoupon(Boolean ifClear) {
        Date date = ParamUtil.checkDate(this.mockDate);
        long userCount = ParamUtil.checkCount(this.userCount);
        if (ifClear) {
            this.remove(new QueryWrapper());
        }

        QueryWrapper<UserInfo> userInfoQueryWrapper = new QueryWrapper();
        userInfoQueryWrapper.last("limit " + userCount);
        long userTotal = this.userInfoService.count(userInfoQueryWrapper);
        List<CouponInfo> couponInfoList = this.couponInfoService.list(new QueryWrapper());
        userCount = Math.min(userTotal, userCount);
        List<CouponUse> couponUseList = new ArrayList();
        Iterator var8 = couponInfoList.iterator();

        while(var8.hasNext()) {
            CouponInfo couponInfo = (CouponInfo)var8.next();

            for(int userId = 1; userId <= userCount; ++userId) {
                CouponUse couponUse = new CouponUse();
                couponUse.setCouponStatus("1401");
                couponUse.setGetTime(date);
                couponUse.setExpireTime(couponInfo.getExpireTime());
                couponUse.setUserId((long)userId + 0L);
                couponUse.setCouponId(couponInfo.getId());
                couponUseList.add(couponUse);
            }
        }

        log.warn("共优惠券" + couponUseList.size() + "张");
        this.saveBatch(couponUseList);
    }

    public Pair<List<CouponUse>, List<OrderDetailCoupon>> usingCoupon(List<OrderInfo> orderInfoList) {
        List<CouponUse> couponUseListForUpdate = new ArrayList();
        Date date = ParamUtil.checkDate(this.mockDate);
        List<CouponUse> unUsedCouponList = this.couponUseMapper.selectUnusedCouponUseListWithInfo();
        List<SkuInfo> skuInfoList = this.skuInfoService.list(new QueryWrapper());
        List<OrderDetailCoupon> allOrderDetailCouponList = new ArrayList();
        int orderCount = 0;
        Iterator var8 = orderInfoList.iterator();

        while(true) {
            OrderInfo orderInfo;
            CouponUse couponUse;
            List matchedOrderDetailCouponList;
            do {
                do {
                    ArrayList curOrderDetailCouponList;
                    do {
                        if (!var8.hasNext()) {
                            log.warn("共有" + orderCount + "订单参与活动条");
                            return new ImmutablePair(couponUseListForUpdate, allOrderDetailCouponList);
                        }

                        orderInfo = (OrderInfo)var8.next();
                        List<OrderDetail> orderDetailList = orderInfo.getOrderDetailList();
                        curOrderDetailCouponList = new ArrayList();
                        Iterator var12 = orderDetailList.iterator();

                        while(var12.hasNext()) {
                            OrderDetail orderDetail = (OrderDetail)var12.next();
                            Iterator var14 = unUsedCouponList.iterator();

                            while(var14.hasNext()) {
                                couponUse = (CouponUse)var14.next();
                                if (orderInfo.getUserId().equals(couponUse.getUserId())) {
                                    orderDetail.setSkuInfo(this.skuInfoService.getSkuInfoById(skuInfoList, orderDetail.getSkuId()));
                                    boolean isMatched = this.matchCouponByRange(orderDetail, couponUse);
                                    if (isMatched) {
                                        OrderDetailCoupon orderDetailCoupon = OrderDetailCoupon.builder().skuId(orderDetail.getSkuId()).createTime(date).orderInfo(orderInfo).orderDetail(orderDetail).couponId(couponUse.getCouponInfo().getId()).couponInfo(couponUse.getCouponInfo()).couponUse(couponUse).build();
                                        curOrderDetailCouponList.add(orderDetailCoupon);
                                    }
                                }
                            }
                        }
                    } while(curOrderDetailCouponList.size() <= 0);

                    matchedOrderDetailCouponList = this.matchRule(orderInfo, curOrderDetailCouponList);
                } while(matchedOrderDetailCouponList == null);
            } while(matchedOrderDetailCouponList.size() <= 0);

            Iterator var19 = matchedOrderDetailCouponList.iterator();

            while(var19.hasNext()) {
                OrderDetailCoupon orderDetailCoupon = (OrderDetailCoupon)var19.next();
                couponUse = orderDetailCoupon.getCouponUse();
                couponUse.setOrderInfo(orderInfo);
                couponUse.setCouponStatus("1402");
                couponUse.setUsingTime(date);
                couponUseListForUpdate.add(couponUse);
            }

            ++orderCount;
            allOrderDetailCouponList.addAll(matchedOrderDetailCouponList);
            orderInfo.sumTotalAmount();
        }
    }

    public void saveCouponUseList(List<CouponUse> couponUseList) {
        this.saveOrUpdateBatch(couponUseList, 100);
    }

    private Map<Long, OrderCouponSum> genOrderCouponSumMap(List<OrderDetailCoupon> orderDetailCouponList) {
        Map<Long, OrderCouponSum> orderCouponSumMap = new HashMap();
        Iterator var3 = orderDetailCouponList.iterator();

        while(var3.hasNext()) {
            OrderDetailCoupon orderDetailCoupon = (OrderDetailCoupon)var3.next();
            OrderCouponSum orderCouponSum = (OrderCouponSum)orderCouponSumMap.get(orderDetailCoupon.getCouponId());
            OrderDetail orderDetail;
            BigDecimal orderDetailAmount;
            if (orderCouponSum != null) {
                orderDetail = orderDetailCoupon.getOrderDetail();
                orderDetailAmount = orderDetail.getOrderPrice().multiply(BigDecimal.valueOf(orderDetail.getSkuNum()));
                orderCouponSum.setOrderDetailAmountSum(orderCouponSum.getOrderDetailAmountSum().add(orderDetailAmount));
                orderCouponSum.setSkuNumSum(orderCouponSum.getSkuNumSum() + orderDetail.getSkuNum());
                orderCouponSum.getOrderDetailCouponList().add(orderDetailCoupon);
            } else {
                orderDetail = orderDetailCoupon.getOrderDetail();
                orderDetailAmount = orderDetail.getOrderPrice().multiply(BigDecimal.valueOf(orderDetail.getSkuNum()));
                OrderCouponSum orderCouponSumNew = new OrderCouponSum(orderDetailCoupon.getCouponId(), orderDetailAmount, orderDetail.getSkuNum(), new ArrayList(Arrays.asList(orderDetailCoupon)), orderDetailCoupon.getCouponInfo(), BigDecimal.ZERO);
                orderCouponSumMap.put(orderDetailCoupon.getCouponId(), orderCouponSumNew);
            }
        }

        return orderCouponSumMap;
    }

    private List<OrderDetailCoupon> matchRule(OrderInfo orderInfo, List<OrderDetailCoupon> orderDetailCouponList) {
        Map<Long, OrderCouponSum> orderCouponSumMap = this.genOrderCouponSumMap(orderDetailCouponList);
        OrderCouponSum maxAmountCouponSum = null;
        Iterator var5 = orderCouponSumMap.values().iterator();

        while(true) {
            OrderCouponSum orderCouponSum;
            label70:
            do {
                while(var5.hasNext()) {
                    orderCouponSum = (OrderCouponSum)var5.next();
                    if (orderCouponSum.getCouponInfo().getCouponType().equals("3201") && orderCouponSum.orderDetailAmountSum.compareTo(orderCouponSum.getCouponInfo().getConditionAmount()) >= 0) {
                        orderCouponSum.setReduceAmount(orderCouponSum.getCouponInfo().getBenefitAmount());
                        continue label70;
                    }

                    if (orderCouponSum.getCouponInfo().getCouponType().equals("3202") && orderCouponSum.getSkuNumSum().compareTo(orderCouponSum.getCouponInfo().getConditionNum()) >= 0) {
                        orderCouponSum.setReduceAmount(orderCouponSum.getOrderDetailAmountSum().multiply(orderCouponSum.getCouponInfo().getBenefitDiscount()));
                        if (maxAmountCouponSum == null || orderCouponSum.getReduceAmount().compareTo(maxAmountCouponSum.getReduceAmount()) > 0) {
                            maxAmountCouponSum = orderCouponSum;
                        }
                    }
                }

                if (maxAmountCouponSum == null) {
                    return null;
                }

                List<OrderDetailCoupon> curOrderDetailCouponList = maxAmountCouponSum.getOrderDetailCouponList();
                OrderDetailCoupon orderDetailCoupon;
                BigDecimal orderPrice;
                BigDecimal skuNum;
                BigDecimal splitDetailAmount;
                BigDecimal couponReduceAmount;
                BigDecimal splitCouponAmountSum;
                if (maxAmountCouponSum.getCouponInfo().getCouponType().equals("3201")) {
                    orderInfo.setCouponReduceAmount(maxAmountCouponSum.getReduceAmount());
                    splitCouponAmountSum = BigDecimal.ZERO;

                    for(int i = 0; i < curOrderDetailCouponList.size(); ++i) {
                        orderDetailCoupon = (OrderDetailCoupon)curOrderDetailCouponList.get(i);
                        if (i < curOrderDetailCouponList.size() - 1) {
                            orderPrice = orderDetailCoupon.getOrderDetail().getOrderPrice();
                            skuNum = BigDecimal.valueOf(orderDetailCoupon.getOrderDetail().getSkuNum());
                            splitDetailAmount = orderPrice.multiply(skuNum);
                            couponReduceAmount = orderInfo.getCouponReduceAmount();
                            BigDecimal splitCouponAmount = couponReduceAmount.multiply(splitDetailAmount).divide(maxAmountCouponSum.getOrderDetailAmountSum(), 2, RoundingMode.HALF_UP);
                            orderDetailCoupon.getOrderDetail().setSplitCouponAmount(splitCouponAmount);
                            splitCouponAmountSum = splitCouponAmountSum.add(splitCouponAmount);
                        } else {
                            orderPrice = orderInfo.getCouponReduceAmount().subtract(splitCouponAmountSum);
                            orderDetailCoupon.getOrderDetail().setSplitCouponAmount(orderPrice);
                        }
                    }
                } else if (maxAmountCouponSum.getCouponInfo().getCouponType().equals("3202")) {
                    splitCouponAmountSum = BigDecimal.ZERO;
                    Iterator var16 = curOrderDetailCouponList.iterator();

                    while(var16.hasNext()) {
                        orderDetailCoupon = (OrderDetailCoupon)var16.next();
                        orderPrice = orderDetailCoupon.getOrderDetail().getOrderPrice();
                        skuNum = BigDecimal.valueOf(orderDetailCoupon.getOrderDetail().getSkuNum());
                        splitDetailAmount = orderPrice.multiply(skuNum);
                        couponReduceAmount = splitDetailAmount.multiply(maxAmountCouponSum.couponInfo.getBenefitDiscount(), new MathContext(2, RoundingMode.HALF_UP));
                        orderDetailCoupon.getOrderDetail().setSplitCouponAmount(couponReduceAmount);
                        splitCouponAmountSum.add(couponReduceAmount);
                    }

                    orderInfo.setCouponReduceAmount(splitCouponAmountSum);
                }

                return maxAmountCouponSum.getOrderDetailCouponList();
            } while(maxAmountCouponSum != null && orderCouponSum.getReduceAmount().compareTo(maxAmountCouponSum.getReduceAmount()) <= 0);

            maxAmountCouponSum = orderCouponSum;
        }
    }

    public void usedCoupon(List<OrderInfo> orderInfoList) {
        Date date = ParamUtil.checkDate(this.mockDate);
        List<Long> orderIdList = new ArrayList();
        Iterator var4 = orderInfoList.iterator();

        while(var4.hasNext()) {
            OrderInfo orderInfo = (OrderInfo)var4.next();
            orderIdList.add(orderInfo.getId());
        }

        CouponUse couponUse = new CouponUse();
        couponUse.setUsedTime(date);
        couponUse.setCouponStatus("1403");
        this.update(couponUse, (Wrapper)(new QueryWrapper()).in("order_id", orderIdList));
    }

    public boolean matchCouponByRange(OrderDetail orderDetail, CouponUse couponUse) {
        List<CouponRange> couponRangeList = couponUse.getCouponRangeList();
        Iterator var4 = couponRangeList.iterator();

        CouponRange couponRange;
        do {
            if (!var4.hasNext()) {
                return false;
            }

            couponRange = (CouponRange)var4.next();
            if (couponRange.getRangeType().equals("3301") && couponRange.getRangeId().equals(orderDetail.getSkuInfo().getCategory3Id())) {
                return true;
            }

            if (couponRange.getRangeType().equals("3302") && couponRange.getRangeId().equals(orderDetail.getSkuInfo().getTmId())) {
                return true;
            }
        } while(!couponRange.getRangeType().equals("3303") || !couponRange.getRangeId().equals(orderDetail.getSkuInfo().getSpuId()));

        return true;
    }

    @Data
    @AllArgsConstructor
    class OrderCouponSum {
        private Long couponId = 0L;
        private BigDecimal orderDetailAmountSum;
        private Long skuNumSum;
        private List<OrderDetailCoupon> orderDetailCouponList;
        private CouponInfo couponInfo;
        private BigDecimal reduceAmount;
    }

}
