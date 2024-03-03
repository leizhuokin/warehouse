package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.mapper.SkuInfoMapper;
import com.hnumi.commerce.mock.db.bean.SkuInfo;
import com.hnumi.commerce.mock.db.service.SkuInfoService;
import org.springframework.stereotype.Service;

import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 库存单元表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
public class SkuInfoServiceImpl extends ServiceImpl<SkuInfoMapper, SkuInfo> implements SkuInfoService {
    public SkuInfo getSkuInfoById(List<SkuInfo> skuInfoList, Long skuId) {
        Iterator var3 = skuInfoList.iterator();

        SkuInfo skuInfo;
        do {
            if (!var3.hasNext()) {
                return null;
            }

            skuInfo = (SkuInfo)var3.next();
        } while(!skuInfo.getId().equals(skuId));

        return skuInfo;
    }
}
