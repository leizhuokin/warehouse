package com.hnumi.commerce.mock.db;

import com.hnumi.commerce.mock.db.service.*;
import com.hnumi.commerce.mock.common.util.ParamUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@Slf4j
public class MockTask {


    @Autowired
    OrderInfoService orderInfoService;
    @Autowired
    CartInfoService cartInfoService;
    @Autowired
    UserInfoService userInfoService;
    @Autowired
    PaymentInfoService paymentInfoService;
    @Autowired
    OrderRefundInfoService orderRefundInfoService;
    @Autowired
    CouponUseService couponUseService;
    @Autowired
    FavorInfoService favorInfoService;
    @Autowired
    ActivityOrderService activityOrderService;
    @Autowired
    CommentInfoService commentInfoService;
    @Value("${mock.clear:0}")
    String ifClear;
    @Value("${mock.clear.user:0}")
    String ifClearUser;

    public MockTask() {
    }

    public void mainTask() throws InterruptedException {
        log.warn("--------开始生成数据--------");
        Boolean ifClear = ParamUtil.checkBoolean(this.ifClear);
        log.warn("--------开始生成用户数据--------");
        this.userInfoService.genUserInfos(ParamUtil.checkBoolean(this.ifClearUser));
        log.warn("--------开始生成收藏数据--------");
        this.favorInfoService.genFavors(ifClear);
        log.warn("--------开始生成购物车数据--------");
        this.cartInfoService.genCartInfo(ifClear);
        log.warn("--------开始生成订单数据--------");
        this.orderInfoService.genOrderInfos(ifClear);
        log.warn("--------开始生成支付数据--------");
        this.paymentInfoService.genPayments(ifClear);
        log.warn("--------开始生成退单数据--------");
        this.orderRefundInfoService.genRefundsOrFinish(ifClear);
        log.warn("--------开始生成评价数据--------");
        this.commentInfoService.genComments(ifClear);
    }



    /**
     * 生成用户
     */

    public void genUsers(){
        userInfoService.genUserInfos( true);
    }


    /**
     * 购物车
     */

    public void genCarts(){
        cartInfoService.genCartInfo(true);
    }

    /**
     * 下单
     */

    public void genOrders(){
        //  couponUseService.genCoupon(20,   true);  //领取购物券

        orderInfoService.genOrderInfos( true );
    }





    /**
     * 支付
     */

    public void genPayments(){
        paymentInfoService.genPayments(true);
    }

    /**
     * 退单
     */

    public void genRefundOrFinish(){
        orderRefundInfoService.genRefundsOrFinish(true);
    }

    /**
     * 评价
     */

    public void genCommonInfo(){
        commentInfoService.genComments( true);
    }


    /**
     * 收藏
     */

    public void genFavor(){
        favorInfoService.genFavors(true);
    }
}
