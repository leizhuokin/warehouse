package com.hnumi.commerce.mock.log;


import com.hnumi.commerce.mock.log.config.AppConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Component;


@Component
public class MockTask {

    @Autowired
    ThreadPoolTaskExecutor poolExecutor;
    public void mainTask() {
        for(int i = 0; i < AppConfig.mock_count; ++i) {
            this.poolExecutor.execute(new Mocker());
            System.out.println("当前已经激活的线程数：" + this.poolExecutor.getActiveCount());
        }

        while(true) {
            try {
                Thread.sleep(1000L);
                if (this.poolExecutor.getActiveCount() == 0) {
                    this.poolExecutor.destroy();
                    return;
                }
            } catch (InterruptedException var2) {
                var2.printStackTrace();
            }
        }
    }
}
