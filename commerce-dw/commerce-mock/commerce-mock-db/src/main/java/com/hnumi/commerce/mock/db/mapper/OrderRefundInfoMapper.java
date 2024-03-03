package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.OrderRefundInfo;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 退单表 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface OrderRefundInfoMapper extends BaseMapper<OrderRefundInfo> {

}
