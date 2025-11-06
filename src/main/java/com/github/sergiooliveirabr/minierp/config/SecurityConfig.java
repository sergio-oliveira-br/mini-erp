package com.github.sergiooliveirabr.minierp.config;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.SessionCookieConfig;
import org.springframework.boot.web.servlet.ServletContextInitializer;
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
                        "script-src-attr 'self'; " +
                        "script-src 'self' https://cdn.jsdelivr.net; " +
                        "script-src-elem 'self' https://cdn.jsdelivr.net; " +
                        "style-src 'self' https://cdn.jsdelivr.net; " +
                        "style-src-elem 'self' https://cdn.jsdelivr.net; " +
                        "style-src-attr 'self'; " +
                        "font-src 'self'; " +
                        "img-src 'self' data:; " +
                        "object-src 'none'; " +
                        "connect-src 'self'; " +
                        "child-src 'none'; " +
                        "frame-src 'none'; " +
                        "frame-ancestors 'none'; " +
                        "base-uri 'self'; " +
                        "form-action 'self'; " +
                        "manifest-src 'self'; " +
                        "media-src 'self'; " +
                        "worker-src 'self'; " +
                        "navigate-to 'self'; " +
                        "prefetch-src 'self'; " +
                        "require-sri-for script style;"
                    )
                )
            );
        return http.build();
    }

    // Setting cookies
    @Bean
    public ServletContextInitializer servletContextInitializer() {

        return new ServletContextInitializer() {
            
            @Override
            public void onStartup(ServletContext servletContext) throws ServletException {

                SessionCookieConfig sessionCookieConfig = servletContext.getSessionCookieConfig();

                sessionCookieConfig.setHttpOnly(true);
                sessionCookieConfig.setPath("/");
                sessionCookieConfig.setName("JSESSIONID");
                sessionCookieConfig.setAttribute("SameSite", "Lax");
            }
        };
    }
}
