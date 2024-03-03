package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.CouponUse;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * <p>
 * 优惠券领用表 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface CouponUseMapper extends BaseMapper<CouponUse> {
    @Select({"select * from coupon_use where coupon_status='1401'"})
    @Results(
            id = "couponMap",
            value = {@Result(
                    id = true,
                    column = "id",
                    property = "id"
            ), @Result(
                    property = "couponId",
                    column = "coupon_id"
            ), @Result(
                    property = "orderId",
                    column = "order_id"
            ), @Result(
                    property = "couponStatus",
                    column = "coupon_status"
            ), @Result(
                    property = "getTime",
                    column = "get_time"
            ), @Result(
                    property = "usingTime",
                    column = "expire_time"
            ), @Result(
                    property = "usedTime",
                    column = "userd_time"
            ), @Result(
                    property = "expireTime",
                    column = "expire_time"
            ), @Result(
                    property = "createTime",
                    column = "create_time"
            ), @Result(
                    property = "couponInfo",
                    column = "coupon_id",
                    one = @One(
                            select = "com.hnumi.commerce.mock.db.mapper.CouponInfoMapper.selectById"
                    )
            ), @Result(
                    property = "couponRangeList",
                    column = "coupon_id",
                    many = @Many(
                            select = "com.hnumi.commerce.mock.db.mapper.CouponRangeMapper.selectById"
                    )
            )}
    )
    List<CouponUse> selectUnusedCouponUseListWithInfo();
}
