package com.hnumi.commerce.mock.common.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ParamUtil {

    public ParamUtil() {
    }

    public static Integer checkRatioNum(String rate) {
        try {
            int rateNum = Integer.parseInt(rate);
            if (rateNum >= 0 && rateNum <= 100) {
                return rateNum;
            } else {
                throw new RuntimeException("输入的比率必须为0 - 100 的数字");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("输入的比率必须为0 - 100 的数字");
        }
    }

    /**
     * 校验日期格式
     * @param dateString 字符串类型的日期
     * @return Date对象
     */
    public static Date checkDate(String dateString) {
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
        SimpleDateFormat datetimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        try {
            String timeString = timeFormat.format(new Date());
            String datetimeString = dateString + " " + timeString;
            return datetimeFormat.parse(datetimeString);
        } catch (ParseException e) {
            e.printStackTrace();
            throw new RuntimeException("必须为日期型格式 例如： 2020-02-02");
        }
    }

    public static Boolean checkBoolean(String bool) {
        if (!"1".equals(bool) && !"true".equals(bool)) {
            if (!"0".equals(bool) && !"false".equals(bool)) {
                throw new RuntimeException("是非型参数请填写：1或0 ， true 或 false");
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    public static Integer[] checkRate(String rateString, int... rateCount) {
        try {
            String[] rateArray = rateString.split(":");
            if (rateCount != null && rateCount.length > 0 && rateArray.length != rateCount[0]) {
                throw new RuntimeException("请按比例个数不足 ");
            } else {
                Integer[] rateNumArr = new Integer[rateArray.length];

                for(int i = 0; i < rateArray.length; ++i) {
                    Integer rate = checkRatioNum(rateArray[i]);
                    rateNumArr[i] = rate;
                }

                return rateNumArr;
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("请按比例填写 如   75:10:15");
        }
    }

    public static String[] checkArray(String str) {
        if (str == null) {
            throw new RuntimeException("搜索词为空");
        } else {
            return str.split(",");
        }
    }

    public static Integer checkCount(String count) {
        try {
            if (count == null) {
                return 0;
            } else {
                return Integer.valueOf(count.trim());
            }
        } catch (Exception e) {
            throw new RuntimeException("输入的数据必须为数字");
        }
    }

    public static void main(String[] args) {
        System.out.println(checkDate("2019-13-1123"));
        System.out.println("ok");
    }
}
