package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.UserInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Update;

/**
 * <p>
 * 用户表 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface UserInfoMapper extends BaseMapper<UserInfo> {

    @Update({"truncate table user_info"})
    void truncateUserInfo();
}
