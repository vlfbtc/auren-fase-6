package com.auren.service;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;

import com.auren.model.dto.SignupRequest;

import lombok.AllArgsConstructor;
import lombok.Data;

@Service
public class PinService {

    private final Map<String, PendingSignup> pending = new ConcurrentHashMap<>();
    private final Random random = new Random();

    /**
     * Inicia fluxo de cadastro, gera e armazena um PIN por 10 minutos.
     * Retorna o PIN (no ambiente real você enviaria por e-mail).
     */
    public String startSignup(SignupRequest req) {
        String pin = String.format("%06d", random.nextInt(1_000_000));
        var now = Instant.now();
        pending.put(req.getEmail().toLowerCase(), new PendingSignup(
                req.getFirstName(),
                req.getLastName(),
                req.getEmail().toLowerCase(),
                req.getBirthDate(),
                pin,
                now.plusSeconds(10 * 60),
                false
        ));
        return pin;
    }

    /** Valida o PIN. Se expirado ou errado, retorna false. */
    public boolean verifyPin(String email, String pin) {
        var p = pending.get(email.toLowerCase());
        if (p == null) return false;
        if (p.getExpiresAt().isBefore(Instant.now())) {
            pending.remove(email.toLowerCase());
            return false;
        }
        if (!p.getPin().equals(pin)) return false;
        p.setVerified(true);
        return true;
    }

    /** Retorna o cadastro pendente já verificado (PIN ok), ou null caso contrário. */
    public PendingSignup getVerified(String email) {
        var p = pending.get(email.toLowerCase());
        if (p == null || !p.isVerified()) return null;
        return p;
    }

    public void clear(String email) {
        pending.remove(email.toLowerCase());
    }

    @Data
    @AllArgsConstructor
    public static class PendingSignup {
        private String firstName;
        private String lastName;
        private String email;
        private LocalDate birthDate;
        private String pin;
        private Instant expiresAt;
        private boolean verified;
    }
}