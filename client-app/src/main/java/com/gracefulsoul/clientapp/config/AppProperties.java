package com.gracefulsoul.clientapp.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    
    private String name;
    private String version;
    private String environment;
    
    private Database database = new Database();
    private Security security = new Security();

    @Data
    public static class Database {
        private String url;
        private String username;
        private String password;
        private int maxPoolSize;
    }

    @Data
    public static class Security {
        private String jwtSecret;
        private long jwtExpiration;
        private String apiKey;
    }
}
