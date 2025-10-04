package com.auren.controller;

import com.auren.model.Transaction;
import com.auren.model.dto.TransactionRequest;
import com.auren.security.UserPrincipal;
import com.auren.service.TransactionService;
import com.auren.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/users/{userId}/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final UserService userService;
    private final TransactionService txService;

    private boolean checkAccess(Long pathUserId, UserPrincipal auth) {
        return auth != null && auth.getId().equals(pathUserId);
    }

    @GetMapping
    public ResponseEntity<List<Transaction>> list(
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal auth,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false, defaultValue = "50") Integer limit
    ) {
        if (!checkAccess(userId, auth)) return ResponseEntity.status(403).build();

        LocalDate today = LocalDate.now();
        if (to == null)   to = today;
        if (from == null) from = to.minusMonths(6).withDayOfMonth(1);
        
        var user = userService.findById(userId);
        return ResponseEntity.ok(txService.list(user, from, to, limit));
    }

    @PostMapping
    public ResponseEntity<Transaction> create(
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal auth,
            @Valid @RequestBody TransactionRequest req
    ) {
        if (!checkAccess(userId, auth)) return ResponseEntity.status(403).build();
        var user = userService.findById(userId);
        var created = txService.create(user, req);
        return ResponseEntity.status(201).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Transaction> update(
            @PathVariable Long userId,
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal auth,
            @Valid @RequestBody TransactionRequest req
    ) {
        if (!checkAccess(userId, auth)) return ResponseEntity.status(403).build();
        var user = userService.findById(userId);
        var updated = txService.update(user, id, req);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long userId,
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal auth
    ) {
        if (!checkAccess(userId, auth)) return ResponseEntity.status(403).build();
        var user = userService.findById(userId);
        txService.delete(user, id);
        return ResponseEntity.noContent().build();
    }
}
