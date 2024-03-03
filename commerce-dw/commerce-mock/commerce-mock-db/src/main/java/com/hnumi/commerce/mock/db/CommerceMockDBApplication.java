package com.hnumi.commerce.mock.db;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableTransactionManagement
public class CommerceMockDBApplication {

    public static void main(String[] args) throws InterruptedException {
        ConfigurableApplicationContext context = SpringApplication.run(CommerceMockDBApplication.class, args);
        MockTask mockTask = context.getBean(MockTask.class);
        mockTask.mainTask();
    }
}
