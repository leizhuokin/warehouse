package com.hnumi.commerce.mock.db.buffer;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hnumi.commerce.mock.db.bean.UserInfo;
import com.hnumi.commerce.mock.db.mapper.UserInfoMapper;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Slf4j
public class BufferServiceImpl<M extends BaseMapper<T>, T> extends ServiceImpl<M, T> {
    List dbList = new ArrayList<>();

    public BufferServiceImpl() {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(() -> {
            while(true) {
                Type type = this.getClass().getGenericSuperclass();
                ParameterizedType pt = (ParameterizedType)type;
                Type[] actualTypeArguments = pt.getActualTypeArguments();
                Type actualTypeArgument = actualTypeArguments[1];
                BufferQueue bufferQueue = BufferUtil.getQueue((Class)actualTypeArgument);
                List outputList = bufferQueue.getOutputList();

                while(outputList.isEmpty()) {
                    log.error("当前 {} 队列个数：{}",type,bufferQueue.getInputListSize());
                    if (bufferQueue.getInputListSize() > 1000) {
                        log.warn("交换！！！！！！！！!!!!!!!!!!!!!!!!!!!!!!!!");
                        bufferQueue.swap();
                        outputList = bufferQueue.getOutputList();
                    } else {
                        Thread.sleep(1000L);
                    }
                }

                System.out.println("保存：行数" + outputList.size());
                this.dbList.addAll(outputList);
                System.out.println("总：行数" + this.dbList.size());
                outputList.clear();
            }
        });
    }

    public void saveBatchWithBuffer(T t) {
        BufferQueue<T> queue = BufferUtil.getQueue(t.getClass());
        queue.push(t);
    }

    @Data
    @AllArgsConstructor
    private static class Customer {
        Integer id;
        String name;
    }
}