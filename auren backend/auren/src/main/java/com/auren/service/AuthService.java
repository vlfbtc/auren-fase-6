package com.auren.service;

import com.auren.model.User;
import com.auren.model.dto.JwtResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserService userService;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;

    public JwtResponse login(String email, String password) {
        var user = userService.findByEmail(email);
        if (!userService.checkPassword(user, password)) {
            throw new IllegalArgumentException("Credenciais inválidas");
        }
        var access = jwtService.generateAccessToken(user);
        var refresh = refreshTokenService.issue(user);
        return new JwtResponse(access, refresh, user.getId());
    }

    public JwtResponse refresh(String refreshToken) {
        Long userId = refreshTokenService.validateAndGetUserId(refreshToken);
        if (userId == null) throw new IllegalArgumentException("Refresh token inválido ou expirado");
        var user = userService.findById(userId);
        var newAccess = jwtService.generateAccessToken(user);
        
        return new JwtResponse(newAccess, refreshToken, user.getId());
    }

    public User completeSignup(String email, String password, PinService.PendingSignup ps) {
        var user = userService.createUser(ps.getFirstName(), ps.getLastName(), email, ps.getBirthDate(), password);
        // opcional: limpar outros refresh tokens do usuário
        refreshTokenService.revokeAllForUser(user.getId());
        return user;
    }
}