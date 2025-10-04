package com.auren;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import com.auren.ai.GeminiProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableConfigurationProperties(GeminiProperties.class)
public class AurenApplication {

	public static void main(String[] args) {
		SpringApplication.run(AurenApplication.class, args);
	}

}