package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.SkuInfo;

import java.util.List;

/**
 * <p>
 * 库存单元表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface SkuInfoService extends IService<SkuInfo> {
    SkuInfo getSkuInfoById(List<SkuInfo> skuInfoList, Long skuId);
}
