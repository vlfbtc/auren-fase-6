package com.auren.service;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import oracle.jdbc.OracleTypes;

@Slf4j
@Service
@RequiredArgsConstructor
public class OraclePlsqlService {

    private final DataSource dataSource;
    private final JdbcTemplate jdbcTemplate;

    /** Function: get_monthly_balance(p_user_id,p_month,p_year) -> NUMBER */
    public BigDecimal getMonthlyBalance(long userId, int month, int year) {
        String sql = "SELECT get_monthly_balance(?, ?, ?) FROM dual";
        BigDecimal result = jdbcTemplate.queryForObject(sql, new Object[]{userId, month, year}, BigDecimal.class);
        return result != null ? result : BigDecimal.ZERO;
    }

    /** Function: get_tx_summary_json(p_user_id) -> CLOB (String) */
    public String getTxSummaryJson(long userId) {
        String sql = "SELECT get_tx_summary_json(?) FROM dual";
        return jdbcTemplate.queryForObject(sql, new Object[]{userId}, String.class);
    }

    /** Procedure: log_high_value_tx(p_tx_id, p_threshold) */
    public void logHighValueTx(long txId, BigDecimal threshold) {
        try (Connection conn = dataSource.getConnection();
             CallableStatement call = conn.prepareCall("{ CALL log_high_value_tx(?, ?) }")) {
            call.setLong(1, txId);
            call.setBigDecimal(2, threshold);
            call.execute();
        } catch (SQLException e) {
            log.error("Erro ao chamar log_high_value_tx", e);
        }
    }

    /** DTO do relatório por categoria (procedure get_category_report) */
    @Data @AllArgsConstructor
    public static class CategoryReportRow {
        private String category;
        private BigDecimal totalSpent;
        private BigDecimal totalReceived;
        private int totalTransactions;
    }

    /** Procedure: get_category_report(p_user_id, p_report OUT SYS_REFCURSOR) */
    public List<CategoryReportRow> getCategoryReport(long userId) {
        List<CategoryReportRow> rows = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             CallableStatement call = conn.prepareCall("{ CALL get_category_report(?, ?) }")) {
            call.setLong(1, userId);
            call.registerOutParameter(2, OracleTypes.CURSOR);
            call.execute();
            try (ResultSet rs = (ResultSet) call.getObject(2)) {
                while (rs.next()) {
                    rows.add(new CategoryReportRow(
                            rs.getString("CATEGORY"),
                            rs.getBigDecimal("TOTAL_SPENT"),
                            rs.getBigDecimal("TOTAL_RECEIVED"),
                            rs.getInt("TOTAL_TRANSACTIONS")
                    ));
                }
            }
        } catch (SQLException e) {
            log.error("Erro ao chamar get_category_report", e);
        }
        return rows;
    }
}
