package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hnumi.commerce.mock.db.bean.*;
import com.hnumi.commerce.mock.common.util.ParamUtil;
import com.hnumi.commerce.mock.db.mapper.ActivityOrderMapper;
import com.hnumi.commerce.mock.db.service.ActivityOrderService;
import com.hnumi.commerce.mock.db.service.ActivityRuleService;
import com.hnumi.commerce.mock.db.service.ActivitySkuService;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * <p>
 * 活动与订单关联表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class ActivityOrderServiceImpl extends ServiceImpl<ActivityOrderMapper, OrderDetailActivity> implements ActivityOrderService {

    @Autowired
    ActivitySkuService activitySkuService;

    @Autowired
    ActivityRuleService activityRuleService;
    @Value("${mock.date}")
    String mockDate;


    public List<OrderDetailActivity>   genActivityOrder(List<OrderInfo> orderInfoList , Boolean ifClear){
        Date date = ParamUtil.checkDate(this.mockDate);
        if (ifClear) {
            this.remove(new QueryWrapper());
        }

        List<ActivitySku> activitySkuList = this.activitySkuService.list(new QueryWrapper<>());
        List<ActivityRule> activityRuleList = this.activityRuleService.list(new QueryWrapper<>());
        List<OrderDetailActivity> allOrderactivityList = new ArrayList<>();
        AtomicInteger orderCount = new AtomicInteger();
        orderInfoList.forEach(orderInfo -> {
            List<OrderDetailActivity> curOrderactivityList = new ArrayList<>();
            List<OrderDetail> orderDetailList = orderInfo.getOrderDetailList();
            orderDetailList.forEach(orderDetail -> {
                activitySkuList.forEach(activitySku -> {
                    if (orderDetail.getSkuId().equals(activitySku.getSkuId())) {
                        curOrderactivityList.add(OrderDetailActivity.builder().skuId(orderDetail.getSkuId()).orderDetail(orderDetail).orderInfo(orderInfo).createTime(date).activityId(activitySku.getActivityId()).build());
                    }
                });
            });

            if (curOrderactivityList.size() > 0) {
                List<OrderDetailActivity> matchedOrderDetailActivitieList = this.matchRule(orderInfo, curOrderactivityList, activityRuleList);
                if (matchedOrderDetailActivitieList.size() > 0) {
                    orderCount.incrementAndGet();
                    allOrderactivityList.addAll(matchedOrderDetailActivitieList);
                    orderInfo.sumTotalAmount();
                }
            }
        });

        log.warn("共有" + orderCount + "订单参与活动条");
        return allOrderactivityList;


    }

    private List<OrderDetailActivity> matchRule(OrderInfo orderInfo, List<OrderDetailActivity> activityOrderList, List<ActivityRule> activityRuleList) {
        List<OrderDetailActivity> matchedActivityOrderList = new ArrayList();
        Map<Long, OrderActivitySum> orderActivitySumMap = this.genOrderActivitySumList(activityOrderList);
        Iterator var6 = orderActivitySumMap.values().iterator();

        while(true) {
            OrderActivitySum orderActivitySum;
            ActivityRule matchedRule;
            label54:
            do {
                if (!var6.hasNext()) {
                    return matchedActivityOrderList;
                }

                orderActivitySum = (OrderActivitySum)var6.next();
                matchedRule = null;
                Iterator var9 = activityRuleList.iterator();

                while(true) {
                    while(true) {
                        ActivityRule activityRule;
                        do {
                            do {
                                if (!var9.hasNext()) {
                                    continue label54;
                                }

                                activityRule = (ActivityRule)var9.next();
                            } while(!orderActivitySum.getActivityId().equals(activityRule.getActivityId()));
                        } while(matchedRule != null && activityRule.getBenefitLevel() < matchedRule.getBenefitLevel());

                        if (activityRule.getActivityType().equals("3101") && orderActivitySum.getOrderDetailAmountSum().compareTo(activityRule.getConditionAmount()) >= 0) {
                            matchedRule = activityRule;
                        } else if (activityRule.getActivityType().equals("3102") && orderActivitySum.getSkuNumSum().compareTo(activityRule.getConditionNum()) >= 0) {
                            matchedRule = activityRule;
                        }
                    }
                }
            } while(matchedRule == null);

            List<OrderDetailActivity> orderDetailActivityList = orderActivitySum.getOrderDetailActivityList();
            Iterator var12 = orderDetailActivityList.iterator();

            while(var12.hasNext()) {
                OrderDetailActivity orderDetailActivity = (OrderDetailActivity)var12.next();
                orderDetailActivity.setActivityRule(matchedRule);
                orderDetailActivity.setActivityRuleId(matchedRule.getId());
                matchedActivityOrderList.add(orderDetailActivity);
            }

            this.calOrderActivityReduceAmount(orderInfo, orderActivitySum, matchedRule);
        }
    }

    private Map<Long, OrderActivitySum> genOrderActivitySumList(List<OrderDetailActivity> activityOrderList) {
        Map<Long, OrderActivitySum> orderActivitySumMap = new HashMap<>();
        activityOrderList.forEach(orderDetailActivity -> {
            OrderActivitySum orderActivitySum = orderActivitySumMap.get(orderDetailActivity.getActivityId());
            OrderDetail orderDetail;
            BigDecimal orderDetailAmount;
            if (orderActivitySum != null) {
                orderDetail = orderDetailActivity.getOrderDetail();
                orderDetailAmount = orderDetail.getOrderPrice().multiply(BigDecimal.valueOf(orderDetail.getSkuNum()));
                orderActivitySum.setOrderDetailAmountSum(orderActivitySum.getOrderDetailAmountSum().add(orderDetailAmount));
                orderActivitySum.setSkuNumSum(orderActivitySum.getSkuNumSum() + orderDetail.getSkuNum());
                orderActivitySum.getOrderDetailActivityList().add(orderDetailActivity);
            } else {
                orderDetail = orderDetailActivity.getOrderDetail();
                orderDetailAmount = orderDetail.getOrderPrice().multiply(BigDecimal.valueOf(orderDetail.getSkuNum()));
                OrderActivitySum orderActivitySumNew = new OrderActivitySum(orderDetailActivity.getActivityId(), orderDetailAmount, orderDetail.getSkuNum(), new ArrayList(Arrays.asList(orderDetailActivity)));
                orderActivitySumMap.put(orderDetailActivity.getActivityId(), orderActivitySumNew);
            }
        });
        return orderActivitySumMap;
    }

    private void calOrderActivityReduceAmount(OrderInfo orderInfo, OrderActivitySum orderActivitySum, ActivityRule matchedRule) {
        OrderDetailActivity orderDetailActivity;
        BigDecimal orderPrice;
        BigDecimal skuNum;
        BigDecimal splitDetailAmount;
        BigDecimal activityReduceAmount;
        if (matchedRule.getActivityType().equals("3101")) {
            orderInfo.setActivityReduceAmount(orderInfo.getActivityReduceAmount().add(matchedRule.getBenefitAmount()));
            List<OrderDetailActivity> orderDetailActivityList = orderActivitySum.getOrderDetailActivityList();
            BigDecimal splitActivityAmountSum = BigDecimal.ZERO;

            for(int i = 0; i < orderDetailActivityList.size(); ++i) {
                orderDetailActivity = (OrderDetailActivity)orderDetailActivityList.get(i);
                if (i < orderDetailActivityList.size() - 1) {
                    orderPrice = orderDetailActivity.getOrderDetail().getOrderPrice();
                    skuNum = BigDecimal.valueOf(orderDetailActivity.getOrderDetail().getSkuNum());
                    splitDetailAmount = orderPrice.multiply(skuNum);
                    activityReduceAmount = orderInfo.getActivityReduceAmount();
                    BigDecimal splitActivityAmount = activityReduceAmount.multiply(splitDetailAmount).divide(orderActivitySum.getOrderDetailAmountSum(), 2, RoundingMode.HALF_UP);
                    orderDetailActivity.getOrderDetail().setSplitActivityAmount(splitActivityAmount);
                    splitActivityAmountSum = splitActivityAmountSum.add(splitActivityAmount);
                } else {
                    orderPrice = orderInfo.getActivityReduceAmount().subtract(splitActivityAmountSum);
                    orderDetailActivity.getOrderDetail().setSplitActivityAmount(orderPrice);
                }
            }
        } else if (matchedRule.getActivityType().equals("3102")) {
            BigDecimal reduceAmount = BigDecimal.ZERO;
            List<OrderDetailActivity> orderDetailActivityList = orderActivitySum.getOrderDetailActivityList();
            Iterator var15 = orderDetailActivityList.iterator();

            while(var15.hasNext()) {
                orderDetailActivity = (OrderDetailActivity)var15.next();
                orderPrice = orderDetailActivity.getOrderDetail().getOrderPrice();
                skuNum = BigDecimal.valueOf(orderDetailActivity.getOrderDetail().getSkuNum());
                splitDetailAmount = orderPrice.multiply(skuNum);
                activityReduceAmount = splitDetailAmount.multiply(matchedRule.getBenefitDiscount(), new MathContext(2, RoundingMode.HALF_UP));
                orderDetailActivity.getOrderDetail().setSplitActivityAmount(activityReduceAmount);
                reduceAmount.add(activityReduceAmount);
            }

            orderInfo.setActivityReduceAmount(reduceAmount);
        }

    }

    public void saveActivityOrderList(List<OrderDetailActivity> activityOrderList) {
        this.saveBatch(activityOrderList, 100);
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    static class OrderActivitySum {
        Long activityId = 0L;
        BigDecimal orderDetailAmountSum;
        Long skuNumSum = 0L;
        List<OrderDetailActivity> orderDetailActivityList = new ArrayList<>();

    }
}
