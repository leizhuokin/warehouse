package com.hnumi.commerce.mock.log.util;



import com.hnumi.commerce.mock.log.config.AppConfig;
import okhttp3.*;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

public class HttpUtil {
    private static OkHttpClient client;

    private HttpUtil() {
    }

    public static OkHttpClient getInstance() {
        if (client == null) {
            Class var0 = HttpUtil.class;
            synchronized(HttpUtil.class) {
                if (client == null) {
                    client = new OkHttpClient();
                }
            }
        }

        return client;
    }

    public static void get(String json) {
        String encodeJson = "";

        try {
            encodeJson = URLEncoder.encode(json, "utf-8");
        } catch (UnsupportedEncodingException var11) {
            var11.printStackTrace();
        }

        String url = AppConfig.mock_url + "?param=" + encodeJson;
        Request request = (new Request.Builder()).url(url).get().build();
        Call call = getInstance().newCall(request);
        Response response = null;
        long start = System.currentTimeMillis();

        try {
            response = call.execute();
            long end = System.currentTimeMillis();
            System.out.println(response.body().string() + " used:" + (end - start) + " ms");
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException("发送失败...检查网络地址...");
        }
    }

    public static void post(String json) {
        System.out.println(json);
        RequestBody requestBody = RequestBody.create(MediaType.parse("application/json; charset=utf-8"), json);
        Request request = (new Request.Builder()).url(AppConfig.mock_url).post(requestBody).build();
        Call call = getInstance().newCall(request);
        Response response = null;
        long start = System.currentTimeMillis();

        try {
            response = call.execute();
            long end = System.currentTimeMillis();
            System.out.println(response.body().string() + " used:" + (end - start) + " ms");
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException("发送失败...检查网络地址...");
        }
    }
}
