package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.CartInfo;

/**
 * <p>
 * 购物车表 用户登录系统时更新冗余 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface CartInfoService extends IService<CartInfo> {

    public void  genCartInfo(boolean ifClear);

}
