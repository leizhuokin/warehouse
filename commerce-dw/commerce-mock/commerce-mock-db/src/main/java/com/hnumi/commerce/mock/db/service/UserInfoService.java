package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.UserInfo;

/**
 * <p>
 * 用户表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface UserInfoService extends IService<UserInfo> {

    void  genUserInfos(Boolean ifClear);

}
