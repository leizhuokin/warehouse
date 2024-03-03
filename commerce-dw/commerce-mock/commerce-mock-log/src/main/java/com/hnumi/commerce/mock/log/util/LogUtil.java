package com.hnumi.commerce.mock.log.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LogUtil {
    private static final Logger log = LoggerFactory.getLogger(LogUtil.class);

    public LogUtil() {
    }

    public static void log(String logString) {
        log.info(logString);
    }
}
