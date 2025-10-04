package com.auren.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO enviado pelo app.
 * O campo 'type' vem como STRING: "INCOME" ou "EXPENSE".
 * O amount vem POSITIVO; quem define entrada/saída é o 'type'.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionRequest {

    @NotBlank
    private String description;

    /**
     * "INCOME" ou "EXPENSE" (enviado pelo app).
     */
    @NotBlank
    private String type;

    /**
     * Valor POSITIVO.
     */
    @NotNull
    private BigDecimal amount;

    @NotNull
    private LocalDate date;

    /**
     * Categoria: obrigatória para EXPENSE; pode vir nula para INCOME.
     * (Validação de obrigatoriedade por regra de negócio no service.)
     */
    private String category;
}
