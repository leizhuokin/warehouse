package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.PaymentInfo;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 支付流水表 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface PaymentInfoMapper extends BaseMapper<PaymentInfo> {

}
