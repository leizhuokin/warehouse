package com.hnumi.commerce.mock.db.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hnumi.commerce.mock.db.bean.CommentInfo;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 商品评论表 Mapper 接口
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Mapper
public interface CommentInfoMapper extends BaseMapper<CommentInfo> {

}
