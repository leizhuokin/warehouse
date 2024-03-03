package com.hnumi.commerce.mock.db.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.db.bean.UserInfo;
import com.hnumi.commerce.mock.db.mapper.UserInfoMapper;
import com.hnumi.commerce.mock.db.service.UserInfoService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * <p>
 * 用户表 服务实现类
 * </p>
 *
 * @author zhangwen
 * @since 2020-01-10
 */
@Service
@Slf4j
public class UserInfoServiceImpl extends ServiceImpl<UserInfoMapper, UserInfo> implements UserInfoService {

    @Autowired
    UserInfoMapper userInfoMapper;


    @Value("${mock.user.count}")
    String  userCountString;

    @Value("${mock.date}")
    String mockDate;

    @Value("${mock.user.male-rate:50}")
    String maleRate;


    @Value("${mock.user.update-rate:20}")
    String updateRate;

    public void  genUserInfos( Boolean ifClear){

        Integer count = ParamUtil.checkCount(userCountString);
        Date date = ParamUtil.checkDate(mockDate);

        List<UserInfo>  userInfoList=new ArrayList<>();
        if(ifClear){
            userInfoMapper.truncateUserInfo();
        }else{
            updateUsers(date);
        }

        for (int i = 0; i < count; i++) {
            userInfoList.add(initUserInfo(date)) ;
        }
        userInfoList.forEach(this::save);
        log.warn("共生成{}名用户",userInfoList.size());

    }
    public UserInfo initUserInfo(Date date) {
        Integer maleRateWeight = ParamUtil.checkRatioNum(this.maleRate);
        UserInfo userInfo = new UserInfo();
        String email = RandomEmail.getEmail(6, 12);
        String loginName = email.split("@")[0];
        userInfo.setLoginName(loginName);
        userInfo.setEmail(email);
        userInfo.setBirthday(DateUtils.addMonths(date, -1 * RandomNum.getRandInt(180, 660)));
        userInfo.setCreateTime(date);
        userInfo.setUserLevel((new RandomBox(new RanOpt[]{new RanOpt("1", 7), new RanOpt("2", 2), new RanOpt("3", 1)})).getRandStringValue());
        userInfo.setPhoneNum("13" + RandomNumString.getRandNumString(1, 9, 9, ""));
        return userInfo;
    }

    public void fixUserInfo(List<UserInfo> userInfoList) {
        Iterator var2 = userInfoList.iterator();

        while(var2.hasNext()) {
            UserInfo userInfo = (UserInfo)var2.next();
            String gender = "";
            if (userInfo.getId() % 2L == 0L) {
                gender = "F";
            } else {
                gender = "M";
            }

            if (userInfo.getId() % 3L != 0L) {
                userInfo.setGender(gender);
            }

            String lastName = RandomName.insideLastName(gender);
            userInfo.setName(RandomName.getChineseFamilyName() + lastName);
            userInfo.setNickName(RandomName.getNickName(gender, lastName));
        }

    }

    public void updateUsers(Date date) {
        Integer updateRateWeight = ParamUtil.checkRatioNum(this.updateRate);
        if (updateRateWeight != 0) {
            int count = Math.toIntExact(this.count(new QueryWrapper()));
            String userIds = RandomNumString.getRandNumString(1, count, count * updateRateWeight / 100, ",", false);
            List<UserInfo> userInfoList = this.list((Wrapper)(new QueryWrapper()).inSql("id", userIds));

            UserInfo userInfo;
            for(Iterator var6 = userInfoList.iterator(); var6.hasNext(); userInfo.setOperateTime(date)) {
                userInfo = (UserInfo)var6.next();
                int randInt = RandomNum.getRandInt(2, 7);
                String gender = "";
                if (userInfo.getId() % 2L == 0L) {
                    gender = "F";
                } else {
                    gender = "M";
                }

                String email;
                if (randInt % 2 == 0) {
                    email = RandomName.insideLastName(gender);
                    userInfo.setNickName(RandomName.getNickName(gender, email));
                }

                if (randInt % 3 == 0) {
                    userInfo.setUserLevel((new RandomBox(new RanOpt[]{new RanOpt("1", 7), new RanOpt("2", 2), new RanOpt("3", 1)})).getRandStringValue());
                }

                if (randInt % 5 == 0) {
                    email = RandomEmail.getEmail(6, 12);
                    userInfo.setEmail(email);
                }

                if (randInt % 7 == 0) {
                    userInfo.setPhoneNum("13" + RandomNumString.getRandNumString(1, 9, 9, ""));
                }
            }

            log.warn("共有{}名用户发生变更", userInfoList.size());
            this.saveOrUpdateBatch(userInfoList);
        }
    }

}
