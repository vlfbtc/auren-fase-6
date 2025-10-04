package com.auren.health;

import com.auren.service.OraclePlsqlService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OraclePlsqlHealth implements HealthIndicator {

    private final OraclePlsqlService plsql;

    @Override
    public Health health() {
        try {
            String json = plsql.getTxSummaryJson(1L); // smoke test
            return Health.up()
                    .withDetail("oracle", "UP")
                    .withDetail("plsql:get_tx_summary_json", (json != null ? "ok" : "null"))
                    .build();
        } catch (Exception e) {
            return Health.down(e).withDetail("oracle", "DOWN").build();
        }
    }
}
