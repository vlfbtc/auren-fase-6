package com.auren.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data @AllArgsConstructor
public class JwtResponse {
    private String accessToken;
    private String refreshToken;
    private Long userId;
}