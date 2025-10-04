package com.auren.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Soma de despesas por categoria")
public class InsightsCategoryDto {
  @Schema(example = "Moradia")
  public String category;

  @Schema(example = "1234.56")
  public BigDecimal amount;

  public InsightsCategoryDto() {}
  public InsightsCategoryDto(String category, BigDecimal amount) {
    this.category = category; this.amount = amount;
  }
}
