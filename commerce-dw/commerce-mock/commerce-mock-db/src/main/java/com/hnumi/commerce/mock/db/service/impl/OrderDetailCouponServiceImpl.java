package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.bean.OrderDetailCoupon;
import com.hnumi.commerce.mock.db.mapper.OrderDetailCouponMapper;
import com.hnumi.commerce.mock.db.service.OrderDetailCouponService;
import org.springframework.stereotype.Service;

@Service
public class OrderDetailCouponServiceImpl extends ServiceImpl<OrderDetailCouponMapper, OrderDetailCoupon> implements OrderDetailCouponService {

}