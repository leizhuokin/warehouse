package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.bean.ActivitySku;
import com.hnumi.commerce.mock.db.mapper.ActivitySkuMapper;
import com.hnumi.commerce.mock.db.service.ActivitySkuService;
import org.springframework.stereotype.Service;

/**
 * <p>
 * 活动参与商品 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
public class ActivitySkuServiceImpl extends ServiceImpl<ActivitySkuMapper, ActivitySku> implements ActivitySkuService {

}
