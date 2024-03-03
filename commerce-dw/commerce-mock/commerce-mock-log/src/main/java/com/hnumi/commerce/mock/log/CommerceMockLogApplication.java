package com.hnumi.commerce.mock.log;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
public class CommerceMockLogApplication {
    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(CommerceMockLogApplication.class, args);
        MockTask mockTask = context.getBean(MockTask.class);
        mockTask.mainTask();
    }
}
