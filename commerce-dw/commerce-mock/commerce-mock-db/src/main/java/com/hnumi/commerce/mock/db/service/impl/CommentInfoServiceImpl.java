package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.db.constant.CommerceConstant;
import com.hnumi.commerce.mock.db.mapper.SkuInfoMapper;
import com.hnumi.commerce.mock.db.bean.CommentInfo;
import com.hnumi.commerce.mock.db.bean.OrderDetail;
import com.hnumi.commerce.mock.db.bean.OrderInfo;
import com.hnumi.commerce.mock.db.bean.SkuInfo;
import com.hnumi.commerce.mock.db.mapper.CommentInfoMapper;
import com.hnumi.commerce.mock.db.mapper.UserInfoMapper;
import com.hnumi.commerce.mock.db.service.CommentInfoService;
import com.hnumi.commerce.mock.db.service.OrderInfoService;
import lombok.extern.slf4j.Slf4j;
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
 * 商品评论表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class CommentInfoServiceImpl extends ServiceImpl<CommentInfoMapper, CommentInfo> implements CommentInfoService {
    @Autowired
    SkuInfoMapper skuInfoMapper;
    @Autowired
    UserInfoMapper userInfoMapper;
    @Autowired
    OrderInfoService orderInfoService;
    @Value("${mock.date}")
    String mockDate;
    @Value("${mock.comment.appraise-rate:30:10:10:50}")
    String appraiseRate;

    public CommentInfoServiceImpl() {
    }

    public void genComments(Boolean ifClear) {
        if (ifClear) {
            this.remove(new QueryWrapper());
        }

        Integer userTotal = this.userInfoMapper.selectCount(new QueryWrapper()).intValue();
        List<CommentInfo> commentInfoList = new ArrayList();
        List<OrderInfo> orderInfoFinishList = this.orderInfoService.listWithDetail((Wrapper)(new QueryWrapper()).eq("order_status", "1004"), true);
        Iterator var5 = orderInfoFinishList.iterator();

        while(var5.hasNext()) {
            OrderInfo orderInfo = (OrderInfo)var5.next();
            Iterator var7 = orderInfo.getOrderDetailList().iterator();

            while(var7.hasNext()) {
                OrderDetail orderDetail = (OrderDetail)var7.next();
                Long userId = (long) RandomNum.getRandInt(1, userTotal) + 0L;
                commentInfoList.add(this.initCommentInfo(orderDetail.getSkuInfo(), orderInfo, userId));
            }
        }

        log.warn("共生成评价" + commentInfoList.size() + "条");
        this.saveBatch(commentInfoList, 100);
    }

    public CommentInfo initCommentInfo(SkuInfo skuInfo, OrderInfo orderInfo, Long userId) {
        Date date = ParamUtil.checkDate(this.mockDate);
        Integer[] appraiseRateWeight = ParamUtil.checkRate(this.appraiseRate, new int[]{4});
        RandomBox<String> appraiseOptionGroup = new RandomBox(new RanOpt[]{new RanOpt("1201", appraiseRateWeight[0]), new RanOpt("1202", appraiseRateWeight[1]), new RanOpt("1203", appraiseRateWeight[2]), new RanOpt("1204", appraiseRateWeight[3])});
        CommentInfo commentInfo = new CommentInfo();
        commentInfo.setOrderId(orderInfo.getId());
        commentInfo.setSkuId(skuInfo.getId());
        commentInfo.setSpuId(skuInfo.getSpuId());
        commentInfo.setUserId(userId);
        commentInfo.setCommentTxt("评论内容：" + RandomNumString.getRandNumString(1, 9, 50, ""));
        commentInfo.setCreateTime(date);
        commentInfo.setAppraise(appraiseOptionGroup.getRandStringValue());
        return commentInfo;
    }
}
