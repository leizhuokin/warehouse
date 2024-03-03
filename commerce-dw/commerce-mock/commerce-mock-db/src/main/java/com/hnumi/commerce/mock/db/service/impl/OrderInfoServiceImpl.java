package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.db.constant.CommerceConstant;
import com.hnumi.commerce.mock.db.mapper.OrderInfoMapper;
import com.hnumi.commerce.mock.db.mapper.SkuInfoMapper;
import com.hnumi.commerce.mock.db.bean.*;
import com.hnumi.commerce.mock.db.service.*;
import com.hnumi.commerce.mock.db.mapper.BaseProvinceMapper;
import com.hnumi.commerce.mock.db.mapper.UserInfoMapper;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 订单表 订单表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class OrderInfoServiceImpl extends ServiceImpl<OrderInfoMapper, OrderInfo> implements OrderInfoService {
    @Autowired
    OrderInfoMapper orderInfoMapper;
    @Autowired
    SkuInfoMapper skuInfoMapper;
    @Autowired
    UserInfoMapper userInfoMapper;
    @Autowired
    BaseProvinceMapper provinceMapper;
    @Autowired
    OrderDetailService orderDetailService;
    @Autowired
    OrderStatusLogService orderStatusLogService;
    @Autowired
    ActivityOrderService activityOrderService;
    @Autowired
    CouponUseServiceImpl couponUseService;
    @Autowired
    OrderDetailCouponService orderDetailCouponService;
    @Autowired
    SkuInfoService skuInfoService;
    @Autowired
    CartInfoService cartInfoService;
    @Value("${mock.date}")
    String mockDate;
    @Value("${mock.order.user-rate:50}")
    String orderUserRate;
    @Value("${mock.order.sku-rate:50}")
    String orderSkuRate;
    @Value("${mock.order.join-activity:0}")
    String joinActivity;
    @Value("${mock.order.use-coupon:0}")
    String useCoupon;

    public OrderInfoServiceImpl() {
    }

    public OrderInfo initOrder(Long userId, Integer provinceTotal, List<Long> cartIdListForUpdate) {
        Date date = ParamUtil.checkDate(this.mockDate);
        Integer orderSkuRateWeight = ParamUtil.checkRatioNum(this.orderSkuRate);
        Integer orderUserWeight = ParamUtil.checkRatioNum(this.orderUserRate);
        RandomBox<Boolean> isOrderUserOptionGroup = new RandomBox(orderUserWeight, 100 - orderUserWeight);
        RandomBox<Boolean> isOrderSkuOptionGroup = new RandomBox(orderSkuRateWeight, 100 - orderSkuRateWeight);
        if (!isOrderUserOptionGroup.getRandBoolValue()) {
            return null;
        } else {
            OrderInfo orderInfo = new OrderInfo();
            orderInfo.setUserId(userId);
            orderInfo.setConsignee(RandomName.genName());
            orderInfo.setConsigneeTel("13" + RandomNumString.getRandNumString(0, 9, 9, ""));
            orderInfo.setCreateTime(date);
            orderInfo.setDeliveryAddress("第" + RandomNum.getRandInt(1, 20) + "大街第" + RandomNum.getRandInt(1, 40) + "号楼" + RandomNum.getRandInt(1, 9) + "单元" + RandomNumString.getRandNumString(1, 9, 3, "") + "门");
            orderInfo.setExpireTime(DateUtils.addMinutes(date, 15));
            orderInfo.setImgUrl("http://img.gmall.com/" + RandomNumString.getRandNumString(1, 9, 6, "") + ".jpg");
            orderInfo.setOrderStatus("1001");
            orderInfo.setOrderComment("描述" + RandomNumString.getRandNumString(1, 9, 6, ""));
            orderInfo.setOutTradeNo(RandomNumString.getRandNumString(1, 9, 15, ""));
            orderInfo.setFeightFee(BigDecimal.valueOf((long)RandomNum.getRandInt(5, 20)));
            int provinceId = RandomNum.getRandInt(1, provinceTotal);
            orderInfo.setProvinceId(provinceId);
            List<CartInfo> userCartList = this.cartInfoService.list((Wrapper)(new QueryWrapper()).eq("user_id", userId));
            List<OrderDetail> orderDetailList = new ArrayList();
            Iterator var13 = userCartList.iterator();

            while(var13.hasNext()) {
                CartInfo cartInfo = (CartInfo)var13.next();
                if (isOrderSkuOptionGroup.getRandBoolValue()) {
                    OrderDetail orderDetail = new OrderDetail();
                    orderDetail.setImgUrl(cartInfo.getImgUrl());
                    orderDetail.setSkuNum(cartInfo.getSkuNum());
                    orderDetail.setSkuName(cartInfo.getSkuName());
                    orderDetail.setSkuId(cartInfo.getSkuId());
                    orderDetail.setOrderPrice(cartInfo.getCartPrice());
                    orderDetail.setCreateTime(date);
                    orderDetail.setSourceId(cartInfo.getSourceId());
                    orderDetail.setSourceType(cartInfo.getSourceType());
                    orderDetail.setCreateTime(date);
                    orderDetailList.add(orderDetail);
                    cartIdListForUpdate.add(cartInfo.getId());
                }
            }

            orderInfo.setOrderDetailList(orderDetailList);
            orderInfo.setUserId(userId + 0L);
            orderInfo.sumTotalAmount();
            orderInfo.setTradeBody(orderInfo.getOrderSubject());
            return orderInfo;
        }
    }

    @Transactional(
            rollbackFor = {Exception.class}
    )
    public void genOrderInfos(boolean ifClear) {
        Boolean joinActivity = ParamUtil.checkBoolean(this.joinActivity);
        Boolean useCoupon = ParamUtil.checkBoolean(this.useCoupon);
        if (useCoupon) {
            this.couponUseService.genCoupon(ifClear);
        }

        if (ifClear) {
            this.remove(new QueryWrapper());
            this.orderDetailService.remove(new QueryWrapper());
            this.orderStatusLogService.remove(new QueryWrapper());
        }

        List<CartInfo> cartInfoList = this.cartInfoService.list((Wrapper)(new QueryWrapper()).select(new String[]{"distinct user_id"}).eq("is_ordered", 0));
        Integer provinceTotal = Math.toIntExact(this.provinceMapper.selectCount(new QueryWrapper()));
        List<OrderInfo> orderInfoList = new ArrayList();
        List<Long> cartIdListForUpdate = new ArrayList();
        Iterator var8 = cartInfoList.iterator();

        while(var8.hasNext()) {
            CartInfo cartInfo = (CartInfo)var8.next();
            OrderInfo orderInfo = this.initOrder(cartInfo.getUserId(), provinceTotal, cartIdListForUpdate);
            if (orderInfo != null && orderInfo.getOrderDetailList() != null && orderInfo.getOrderDetailList().size() > 0) {
                orderInfoList.add(orderInfo);
            }
        }

        CartInfo cartInfo = new CartInfo();
        cartInfo.setIsOrdered(1);
        cartInfo.setOrderTime(new Date());
        this.cartInfoService.update(cartInfo, (Wrapper)(new QueryWrapper()).in("id", cartIdListForUpdate));
        log.warn("共生成订单" + orderInfoList.size() + "条");
        List<OrderDetailActivity> activityOrderList = null;
        if (joinActivity) {
            activityOrderList = this.activityOrderService.genActivityOrder(orderInfoList, ifClear);
        }

        List<CouponUse> couponUseList = null;
        List<OrderDetailCoupon> orderDetailCouponList = null;
        if (useCoupon) {
            Pair<List<CouponUse>, List<OrderDetailCoupon>> couponPair = this.couponUseService.usingCoupon(orderInfoList);
            couponUseList = (List)couponPair.getLeft();
            orderDetailCouponList = (List)couponPair.getRight();
        }

        this.saveBatch(orderInfoList);
        Iterator var17;
        if (activityOrderList != null && activityOrderList.size() > 0) {
            var17 = activityOrderList.iterator();

            while(var17.hasNext()) {
                OrderDetailActivity activityOrder = (OrderDetailActivity)var17.next();
                activityOrder.setOrderId(activityOrder.getOrderInfo().getId());
                activityOrder.setOrderDetailId(activityOrder.getOrderDetail().getId());
            }

            this.activityOrderService.saveActivityOrderList(activityOrderList);
        }

        if (couponUseList != null && couponUseList.size() > 0) {
            var17 = couponUseList.iterator();

            while(var17.hasNext()) {
                CouponUse couponUse = (CouponUse)var17.next();
                couponUse.setOrderId(couponUse.getOrderInfo().getId());
            }

            this.couponUseService.saveCouponUseList(couponUseList);
        }

        if (orderDetailCouponList != null && orderDetailCouponList.size() > 0) {
            var17 = orderDetailCouponList.iterator();

            while(var17.hasNext()) {
                OrderDetailCoupon orderDetailCoupon = (OrderDetailCoupon)var17.next();
                orderDetailCoupon.setOrderId(orderDetailCoupon.getOrderInfo().getId());
                orderDetailCoupon.setOrderDetailId(orderDetailCoupon.getOrderDetail().getId());
            }

            this.orderDetailCouponService.saveBatch(orderDetailCouponList, 100);
        }

        this.orderStatusLogService.genOrderStatusLog(orderInfoList);
    }

    @Transactional(
            rollbackFor = {Exception.class}
    )
    public boolean saveBatch(List<OrderInfo> orderInfoList) {
        super.saveBatch(orderInfoList, 100);
        List orderDetailAllList = new ArrayList();
        Iterator var3 = orderInfoList.iterator();

        while(var3.hasNext()) {
            OrderInfo orderInfo = (OrderInfo)var3.next();
            Long orderId = orderInfo.getId();
            List<OrderDetail> orderDetailList = orderInfo.getOrderDetailList();
            Iterator var7 = orderDetailList.iterator();

            while(var7.hasNext()) {
                OrderDetail orderDetail = (OrderDetail)var7.next();
                orderDetail.setOrderId(orderId);
                orderDetailAllList.add(orderDetail);
            }
        }

        return this.orderDetailService.saveBatch(orderDetailAllList, 100);
    }

    public void updateOrderStatus(List<OrderInfo> orderInfoList) {
        Date date = ParamUtil.checkDate(this.mockDate);
        if (orderInfoList.size() == 0) {
            System.out.println("没有需要更新状态的订单！！ ");
        } else {
            List orderInfoUpdateList = new ArrayList();
            Iterator var4 = orderInfoList.iterator();

            while(var4.hasNext()) {
                OrderInfo orderInfo = (OrderInfo)var4.next();
                OrderInfo orderInfoForUpdate = new OrderInfo();
                orderInfoForUpdate.setId(orderInfo.getId());
                orderInfoForUpdate.setOrderStatus(orderInfo.getOrderStatus());
                orderInfoForUpdate.setOperateTime(date);
                orderInfoUpdateList.add(orderInfoForUpdate);
            }

            System.out.println("状态更新" + orderInfoUpdateList.size() + "个订单");
            this.orderStatusLogService.genOrderStatusLog(orderInfoUpdateList);
            this.saveOrUpdateBatch(orderInfoUpdateList, 100);
        }
    }

    public List<OrderInfo> listWithDetail(Wrapper<OrderInfo> queryWrapper) {
        return this.listWithDetail(queryWrapper, false);
    }

    public List<OrderInfo> listWithDetail(Wrapper<OrderInfo> queryWrapper, Boolean withSkuInfo) {
        List<OrderInfo> orderInfoList = super.list(queryWrapper);

        OrderInfo orderInfo;
        List orderDetailList;
        for(Iterator var4 = orderInfoList.iterator(); var4.hasNext(); orderInfo.setOrderDetailList(orderDetailList)) {
            orderInfo = (OrderInfo)var4.next();
            orderDetailList = this.orderDetailService.list((Wrapper)(new QueryWrapper()).eq("order_id", orderInfo.getId()));
            if (withSkuInfo) {
                Iterator var7 = orderDetailList.iterator();

                while(var7.hasNext()) {
                    OrderDetail orderDetail = (OrderDetail)var7.next();
                    SkuInfo skuInfo = (SkuInfo)this.skuInfoService.getById(orderDetail.getSkuId());
                    orderDetail.setSkuInfo(skuInfo);
                }
            }
        }

        return orderInfoList;
    }

}
