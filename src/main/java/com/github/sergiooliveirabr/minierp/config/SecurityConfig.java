package com.github.sergiooliveirabr.minierp.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .anyRequest().permitAll()
            )

            .headers(headers -> headers
                .contentSecurityPolicy(csp -> csp
                    .policyDirectives(
                        "default-src 'self'; " +
                        "script-src 'self' https://cdn.jsdelivr.net; " +
                        "style-src 'self' https://cdn.jsdelivr.net; " +
                        "font-src 'self'; " +
                        "img-src 'self' data:; " +
                        "object-src 'none'; " +
                        "connect-src 'self'; " +
                        "frame-src 'none';"
                   )
                )
            );

        return http.build();
    }
}
