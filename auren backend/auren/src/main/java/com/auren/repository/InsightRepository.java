package com.auren.repository;

import com.auren.model.dto.InsightsDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class InsightRepository {

    private final JdbcTemplate jdbc;

    private static final RowMapper<InsightsDto> ROW_MAPPER = (rs, n) -> {
        InsightsDto dto = new InsightsDto();
        dto.setId(rs.getLong("id"));
        // campos textuais não existem na view -> null
        dto.setTitle(null);
        dto.setDescription(null);
        dto.setCategory(null);
        dto.setPriority(null);
        dto.setContentType(null);
        try {
            dto.setArticleId(rs.getString("article_id"));
        } catch (Exception ignored) {
            dto.setArticleId(null);
        }
        Timestamp ts = rs.getTimestamp("created_at");
        dto.setCreatedAt(ts != null ? ts.toInstant().atOffset(ZoneOffset.UTC) : null);
        return dto;
    };

    public List<InsightsDto> findLastByUser(Long userId, int limit) {
        String sql =
                "SELECT id, user_id, payload_json, created_at, tx_hash, " +
                "       /* artigo pode não existir na view */ NULL AS article_id " +
                "  FROM insights " +
                " WHERE user_id = ? " +
                " ORDER BY created_at DESC " +
                " FETCH FIRST ? ROWS ONLY";
        return jdbc.query(sql, ROW_MAPPER, userId, limit);
    }

    public Optional<InsightsDto> findLastOneByUser(Long userId) {
        String sql =
                "SELECT id, user_id, payload_json, created_at, tx_hash, " +
                "       NULL AS article_id " +
                "  FROM insights " +
                " WHERE user_id = ? " +
                " ORDER BY created_at DESC " +
                " FETCH FIRST 1 ROWS ONLY";
        List<InsightsDto> list = jdbc.query(sql, ROW_MAPPER, userId);
        return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
    }
}
