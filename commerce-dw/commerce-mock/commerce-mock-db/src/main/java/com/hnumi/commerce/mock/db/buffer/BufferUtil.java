package com.hnumi.commerce.mock.db.buffer;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class BufferUtil {
    private static Map<Class, BufferQueue> bufferMap = new ConcurrentHashMap<>();

    public BufferUtil() {
    }

    public static BufferQueue getQueue(Class clazz) {
        BufferQueue bufferQueue = bufferMap.get(clazz);
        if (bufferQueue == null) {
            bufferQueue = new BufferQueue();
            bufferMap.put(clazz, bufferQueue);
        }
        return bufferQueue;
    }
}