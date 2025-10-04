package com.auren.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Parâmetros de geração")
public class InsightsGenerateRequest {
  @Schema(example = "6", description = "Meses de janela")
  public Integer months = 6;

  @Schema(example = "10", description = "Máximo de itens em tips")
  public Integer topN = 10;
}
