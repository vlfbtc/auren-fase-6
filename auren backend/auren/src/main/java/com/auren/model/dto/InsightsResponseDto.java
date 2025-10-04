package com.auren.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Schema(description = "Snapshot de insights entregue ao app")
public class InsightsResponseDto {
  public LocalDate from;
  public LocalDate to;
  public BigDecimal totalIncome;
  public BigDecimal totalExpense;
  public List<InsightsCategoryDto> categories;
  public List<InsightsTipDto> tips;
  public List<InsightsContentDto> content;
}
