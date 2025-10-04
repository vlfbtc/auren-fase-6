package com.auren.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

@Slf4j
@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        // request id
        final String reqId = UUID.randomUUID().toString().substring(0, 8);
        MDC.put("requestId", reqId);

        // user do contexto de segurança (se autenticado)
        String user = "-";
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && auth.getName() != null) {
            user = auth.getName();
        }
        MDC.put("user", user);

        long start = System.currentTimeMillis();

        // Info úteis do request
        String method = request.getMethod();
        String path = request.getRequestURI();
        String query = request.getQueryString();
        String userAgent = safeHeader(request, "User-Agent");
        String ip = getRemoteAddr(request);

        int status = 500; // default até passar pelo chain
        try {
            filterChain.doFilter(request, response);
            status = response.getStatus();
        } finally {
            long ms = System.currentTimeMillis() - start;
            log.info("{} {}{} -> {} ({} ms) ua='{}' ip={} user={}",
                    method,
                    path,
                    (query != null ? "?" + query : ""),
                    status,
                    ms,
                    userAgent,
                    ip,
                    user);
            MDC.clear();
        }
    }

    private String safeHeader(HttpServletRequest req, String name) {
        try {
            String v = req.getHeader(name);
            return v != null ? v : "-";
        } catch (Exception e) {
            return "-";
        }
    }

    private String getRemoteAddr(HttpServletRequest req) {
        String xfwd = req.getHeader("X-Forwarded-For");
        if (xfwd != null && !xfwd.isBlank()) {
            return xfwd.split(",")[0].trim();
        }
        return req.getRemoteAddr();
    }
}
