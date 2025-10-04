package com.auren.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

@RestController
@RequestMapping("/api/v1/users/{userId}/alerts")
@RequiredArgsConstructor
public class AlertController {

    private final JdbcTemplate jdbc;

    /**
     * Lista os alertas mais recentes do usuário.
     *
     * Exemplo de uso:
     *   GET /api/v1/users/21/alerts?limit=10
     *   Authorization: Bearer <token>
     */
    @GetMapping
    public List<AlertDto> list(@PathVariable Long userId,
                               @RequestParam(defaultValue = "10") Integer limit) {

        // saneamento de limite para evitar abuso:
        final int lim = Math.max(1, Math.min(limit == null ? 10 : limit, 100));

        // OBS Oracle: para preservar a ordenação ao paginar, usamos subselect + ROWNUM
        final String sql = """
            SELECT id, transaction_id, threshold, created_at
            FROM (
                SELECT id, transaction_id, threshold, created_at
                FROM alerts
                WHERE user_id = ?
                ORDER BY created_at DESC
            )
            WHERE ROWNUM <= ?
            """;

        return jdbc.query(sql, (rs, rowNum) -> {
            Long id = rs.getLong("id");
            Long txId = rs.getLong("transaction_id");
            BigDecimal threshold = rs.getBigDecimal("threshold");

            Timestamp ts = rs.getTimestamp("created_at");
            OffsetDateTime createdAt = (ts != null)
                    ? ts.toInstant().atOffset(ZoneOffset.UTC)
                    : null;

            return new AlertDto(id, txId, threshold, createdAt);
        }, userId, lim);
    }

    /** DTO simples para resposta do endpoint. */
    public record AlertDto(
            Long id,
            Long transactionId,
            BigDecimal threshold,
            OffsetDateTime createdAt
    ) {}
}
