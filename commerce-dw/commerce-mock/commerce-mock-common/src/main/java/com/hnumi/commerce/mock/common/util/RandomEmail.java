package com.hnumi.commerce.mock.common.util;

public class RandomEmail {

        private static final String[] email_suffix = "@gmail.com,@yahoo.com,@msn.com,@hotmail.com,@aol.com,@ask.com,@live.com,@qq.com,@0355.net,@163.com,@163.net,@263.net,@3721.net,@yeah.net,@googlemail.com,@126.com,@sina.com,@sohu.com,@yahoo.com.cn".split(",");
        public static String base = "abcdefghijklmnopqrstuvwxyz0123456789";

        public static int getNum(int start, int end) {
            return (int) (Math.random() * (end - start + 1) + start);
        }

        /**
         * 返回Email
         *
         * @param lMin 最小长度
         * @param lMax 最大长度
         * @return /
         */
        public static String getEmail(int lMin, int lMax) {
            int length = getNum(lMin, lMax);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < length; i++) {
                int number = (int) (Math.random() * base.length());
                sb.append(base.charAt(number));
            }
            sb.append(email_suffix[(int) (Math.random() * email_suffix.length)]);
            return sb.toString();
        }
    }

