package com.ihm.config;

import com.ihm.security.FirstLoginCheckFilter;
import com.ihm.security.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final FirstLoginCheckFilter firstLoginCheckFilter;

    public SecurityConfig(JwtAuthFilter jwtAuthFilter, FirstLoginCheckFilter firstLoginCheckFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.firstLoginCheckFilter = firstLoginCheckFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/api/auth/login",
                    "/api/auth/register",
                    "/api/auth/forgot-password",
                    "/api/auth/reset-password",
                    "/swagger-ui.html",
                    "/swagger-ui/**",
                    "/api-docs/**",
                    "/v3/api-docs/**"
                ).permitAll()
                .requestMatchers(HttpMethod.GET,
                    "/api/evenements/**",
                    "/api/categories/**",
                    "/api/lieux/**",
                    "/api/tickets/*/qrcode"
                ).permitAll()
                .requestMatchers(HttpMethod.POST,
                    "/api/tickets/validate"
                ).permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMINISTRATEUR")
                .requestMatchers(HttpMethod.GET,
                    "/api/organisateur/**",
                    "/api/salles/**",
                    "/api/places/**",
                    "/api/lieux/**",
                    "/api/categories/**"
                ).authenticated()
                .requestMatchers(HttpMethod.POST,
                    "/api/organisateur/**",
                    "/api/places/**",
                    "/api/places/batch",
                    "/api/salles/**",
                    "/api/lieux/**"
                ).authenticated()
                .requestMatchers(HttpMethod.PUT,
                    "/api/organisateur/**",
                    "/api/places/**",
                    "/api/salles/**",
                    "/api/lieux/**"
                ).authenticated()
                .requestMatchers(HttpMethod.DELETE,
                    "/api/organisateur/**",
                    "/api/places/**",
                    "/api/salles/**",
                    "/api/lieux/**"
                ).authenticated()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterAfter(firstLoginCheckFilter, JwtAuthFilter.class);

        return http.build();
    }
}
