package com.auren.service;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.auren.model.User;

import lombok.AllArgsConstructor;
import lombok.Data;

@Service
public class RefreshTokenService {

    @Value("${app.jwt.refresh-token.ttl-days}")
    private long refreshTtlDays;

    private final Map<String, TokenRecord> store = new ConcurrentHashMap<>();

    /** Emite um refresh token (UUID) e guarda em memória com expiração. */
    public String issue(User user) {
        var token = UUID.randomUUID().toString();
        store.put(token, new TokenRecord(
                user.getId(),
                Instant.now().plusSeconds(refreshTtlDays * 24 * 3600)
        ));
        return token;
    }

    /** Valida e retorna o userId do refresh token, ou null se inválido/expirado. */
    public Long validateAndGetUserId(String refreshToken) {
        var rec = store.get(refreshToken);
        if (rec == null) return null;
        if (rec.getExpiresAt().isBefore(Instant.now())) {
            store.remove(refreshToken);
            return null;
        }
        return rec.getUserId();
    }

    public void revoke(String refreshToken) {
        store.remove(refreshToken);
    }

    public void revokeAllForUser(Long userId) {
        store.entrySet().removeIf(e -> e.getValue().getUserId().equals(userId));
    }

    @Data
    @AllArgsConstructor
    public static class TokenRecord {
        private Long userId;
        private Instant expiresAt;
    }
}
