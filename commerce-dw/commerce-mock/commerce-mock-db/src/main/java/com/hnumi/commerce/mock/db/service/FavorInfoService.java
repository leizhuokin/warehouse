package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.FavorInfo;

/**
 * <p>
 * 商品收藏表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface FavorInfoService extends IService<FavorInfo> {

    public void  genFavors(Boolean ifClear);

}
