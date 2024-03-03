package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.mapper.SpuInfoMapper;
import com.hnumi.commerce.mock.db.bean.SpuInfo;
import com.hnumi.commerce.mock.db.service.SpuInfoService;
import org.springframework.stereotype.Service;

/**
 * <p>
 * 商品表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
public class SpuInfoServiceImpl extends ServiceImpl<SpuInfoMapper, SpuInfo> implements SpuInfoService {

}
