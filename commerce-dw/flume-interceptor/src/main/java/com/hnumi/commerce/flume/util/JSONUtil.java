package com.hnumi.commerce.flume.util;

import com.alibaba.fastjson2.JSONException;
import com.alibaba.fastjson2.JSONObject;

public class JSONUtil {
    /*
     * 通过异常判断是否是json字符串
     * 是：返回true  不是：返回false
     * */
    public static boolean isJSON(String log){
        try {
            JSONObject.parseObject(log);
            return true;
        }catch (JSONException e){
            return false;
        }
    }
}
