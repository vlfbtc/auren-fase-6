package com.auren.controller;

import com.auren.security.UserPrincipal;
import com.auren.service.AiInsightsService;
import com.auren.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/users/{userId}/insights")
@RequiredArgsConstructor
public class InsightController {

    private final UserService userService;
    private final AiInsightsService ai;

    private boolean allowed(Long pathId, UserPrincipal auth) {
        return auth != null && auth.getId().equals(pathId);
    }

    @GetMapping
    public ResponseEntity<?> getInsights(
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal auth,
            @RequestParam(defaultValue = "6") int months,
            @RequestParam(defaultValue = "10") int topN,
            @RequestParam(defaultValue = "false") boolean refresh
    ) {
        if (!allowed(userId, auth)) return ResponseEntity.status(403).build();
        var user = userService.findById(userId);

        try {
            if (refresh) {
                Map<String, Object> snap = ai.generateSnapshot(user, months, topN);
                return ResponseEntity.ok(snap);
            } else {
                return ai.recent(user)
                        .<ResponseEntity<?>>map(ResponseEntity::ok)
                        .orElseGet(() -> ResponseEntity.ok(ai.generateSnapshot(user, months, topN)));
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of(
                    "status", 500,
                    "message", "Erro ao gerar/obter insights"
            ));
        }
    }
}
