package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.bean.RefundPayment;
import com.hnumi.commerce.mock.db.mapper.RefundPaymentMapper;
import com.hnumi.commerce.mock.db.service.RefundPaymentService;
import org.springframework.stereotype.Service;

@Service
public class RefundPaymentImpl extends ServiceImpl<RefundPaymentMapper, RefundPayment> implements RefundPaymentService {

}