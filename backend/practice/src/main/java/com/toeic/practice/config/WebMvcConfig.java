package com.toeic.practice.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Map /api/media/** to the data/downloads directory
        Path dataDir = Paths.get("data/downloads").toAbsolutePath().normalize();
        if (!java.nio.file.Files.exists(dataDir)) {
            dataDir = Paths.get("../../data/downloads").toAbsolutePath().normalize();
        }
        String resourceLocation = "file:" + dataDir.toString() + "/";
        
        registry.addResourceHandler("/api/media/**")
                .addResourceLocations(resourceLocation);
    }
}

