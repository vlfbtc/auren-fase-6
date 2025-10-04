package com.auren.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreatePasswordRequest {
    @Email @NotBlank private String email;
    @NotBlank @Size(min=6, message="Senha deve conter ao menos 6 caracteres")
    private String password;
}
