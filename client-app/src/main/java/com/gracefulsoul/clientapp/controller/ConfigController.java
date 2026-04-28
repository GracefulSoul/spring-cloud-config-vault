package com.gracefulsoul.clientapp.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gracefulsoul.clientapp.config.AppProperties;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/config")
@RequiredArgsConstructor
public class ConfigController {

    private final AppProperties appProperties;

    @Value("${app.name:Not Set}")
    private String appName;

    @Value("${app.version:Not Set}")
    private String appVersion;

    @Value("${app.environment:Not Set}")
    private String environment;

    @GetMapping("/properties")
    public ResponseEntity<Map<String, Object>> getProperties() {
        Map<String, Object> response = new HashMap<>();
        
        Map<String, Object> app = new HashMap<>();
        app.put("name", appProperties.getName());
        app.put("version", appProperties.getVersion());
        app.put("environment", appProperties.getEnvironment());
        
        Map<String, Object> database = new HashMap<>();
        database.put("url", appProperties.getDatabase().getUrl());
        database.put("username", appProperties.getDatabase().getUsername());
        database.put("maxPoolSize", appProperties.getDatabase().getMaxPoolSize());
        
        Map<String, Object> security = new HashMap<>();
        security.put("jwtExpiration", appProperties.getSecurity().getJwtExpiration());
        security.put("apiKeyExists", appProperties.getSecurity().getApiKey() != null && 
                                      !appProperties.getSecurity().getApiKey().isEmpty());
        
        response.put("app", app);
        response.put("database", database);
        response.put("security", security);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, String>> getStatus() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("appName", appName);
        response.put("appVersion", appVersion);
        response.put("environment", environment);
        
        return ResponseEntity.ok(response);
    }
}
