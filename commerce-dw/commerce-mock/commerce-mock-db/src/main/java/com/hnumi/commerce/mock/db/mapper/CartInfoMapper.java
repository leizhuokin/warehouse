package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.CartInfo;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 购物车表 用户登录系统时更新冗余 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface CartInfoMapper extends BaseMapper<CartInfo> {

}
