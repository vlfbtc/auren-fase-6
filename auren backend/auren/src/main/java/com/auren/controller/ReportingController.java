package com.auren.controller;

import com.auren.security.UserPrincipal;
import com.auren.service.OraclePlsqlService;
import com.auren.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/users/{userId}/reports")
@RequiredArgsConstructor
public class ReportingController {

    private final UserService userService;
    private final OraclePlsqlService plsql;

    private boolean allowed(Long pathUserId, UserPrincipal auth) {
        return auth != null && auth.getId().equals(pathUserId);
    }

    @GetMapping("/monthly-balance")
    public ResponseEntity<?> monthlyBalance(
            @PathVariable Long userId,
            @RequestParam Integer month,
            @RequestParam Integer year,
            @AuthenticationPrincipal UserPrincipal auth
    ) {
        if (!allowed(userId, auth)) return ResponseEntity.status(403).build();
        BigDecimal saldo = plsql.getMonthlyBalance(userId, month, year);
        return ResponseEntity.ok(Map.of(
                "userId", userId,
                "month", month,
                "year", year,
                "balance", saldo
        ));
    }

    @GetMapping("/db-summary")
    public ResponseEntity<?> dbSummary(
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal auth
    ) {
        if (!allowed(userId, auth)) return ResponseEntity.status(403).build();
        String json = plsql.getTxSummaryJson(userId);
        return ResponseEntity.ok(Map.of("userId", userId, "summary", json));
    }

    @GetMapping("/category-report")
    public ResponseEntity<?> categoryReport(
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal auth
    ) {
        if (!allowed(userId, auth)) return ResponseEntity.status(403).build();
        List<OraclePlsqlService.CategoryReportRow> rows = plsql.getCategoryReport(userId);
        return ResponseEntity.ok(rows);
    }
}
