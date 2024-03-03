package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.OrderInfo;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 订单表 订单表 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface OrderInfoMapper extends BaseMapper<OrderInfo> {

}
