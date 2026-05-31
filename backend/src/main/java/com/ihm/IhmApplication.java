package com.ihm;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class IhmApplication {

    public static void main(String[] args) {
        SpringApplication.run(IhmApplication.class, args);
    }
}
