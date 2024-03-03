package com.hnumi.commerce.mock.db.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hnumi.commerce.mock.db.bean.CommentInfo;

/**
 * <p>
 * 商品评论表 服务类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
public interface CommentInfoService extends IService<CommentInfo> {

    public  void genComments(Boolean ifClear);

}
