package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.db.bean.*;
import com.hnumi.commerce.mock.db.mapper.CouponInfoMapper;
import com.hnumi.commerce.mock.db.mapper.SkuInfoMapper;
import com.hnumi.commerce.mock.db.mapper.UserInfoMapper;
import com.hnumi.commerce.mock.db.service.CouponInfoService;
import com.hnumi.commerce.mock.db.service.OrderInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 优惠券表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
public class CouponInfoServiceImpl extends ServiceImpl<CouponInfoMapper, CouponInfo> implements CouponInfoService {

}
