package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.ActivitySku;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 活动参与商品 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface ActivitySkuMapper extends BaseMapper<ActivitySku> {

}
