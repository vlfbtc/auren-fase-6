package com.auren.controller;

import com.auren.model.dto.*;
import com.auren.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final PinService pinService;
    private final EmailService emailService;
    private final AuthService authService;
    private final UserService userService;

    // 1) inicia signup: gera PIN e "envia" email
    @PostMapping("/signup")
    public ResponseEntity<Void> signup(@Valid @RequestBody SignupRequest req) {
        String pin = pinService.startSignup(req);
        emailService.sendSignupPin(req.getEmail(), pin);
        return ResponseEntity.status(201).build();
    }

    // 2) valida PIN
    @PostMapping("/verify-pin")
    public ResponseEntity<Void> verifyPin(@Valid @RequestBody VerifyPinRequest req) {
        boolean ok = pinService.verifyPin(req.getEmail(), req.getPin());
        if (!ok) return ResponseEntity.badRequest().build();
        return ResponseEntity.ok().build();
    }

    // 3) cria senha e usuário
    @PostMapping("/create-password")
    public ResponseEntity<Void> createPassword(@Valid @RequestBody CreatePasswordRequest req) {
        var ps = pinService.getVerified(req.getEmail());
        if (ps == null) return ResponseEntity.badRequest().build();
        authService.completeSignup(req.getEmail(), req.getPassword(), ps);
        pinService.clear(req.getEmail());
        return ResponseEntity.status(201).build();
    }

    // Login → { accessToken, refreshToken }
    @PostMapping("/login")
    public ResponseEntity<JwtResponse> login(@Valid @RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.login(req.getEmail(), req.getPassword()));
    }

    // Refresh → novo accessToken
    @PostMapping("/refresh")
    public ResponseEntity<JwtResponse> refresh(@Valid @RequestBody RefreshRequest req) {
        return ResponseEntity.ok(authService.refresh(req.getRefreshToken()));
    }
}
